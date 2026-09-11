import Combine
import Foundation

@MainActor
public final class DihGame: ObservableObject {
    @Published public private(set) var save = DihSaveData()
    @Published public private(set) var offlineSummary: String?
    @Published public private(set) var toast: String?
    @Published public private(set) var passiveProgress = 0.0
    @Published public var buttonPosition = CGPoint(x: 250, y: 210)
    @Published public var buttonText = "click me"
    @Published public var message = "Catch me."

    public let persistence: DihPersistence
    private var passiveTask: Task<Void, Never>?
    private var lastTick = Date()
    private var sessionCloneWindows = 0
    private var loaded = false

    private let buttonNames = ["catch me", "nope", "again", "try again", "lol", ">:)"]
    private let reactions = [
        "HEY!", "STOP!", "HOW DID YOU CATCH ME?", "NOOO", "AGAIN?",
        "I WASN'T READY", "CHEATER", "...", ">:(", "HELP"
    ]
    private let advice = [
        "The vibes are confusing, but the snacks are good.",
        "Your future contains a button. It will run away.",
        "Do one small thing, then dramatically announce it.",
        "The universe says: maybe close one browser tab.",
        "You are doing great. Suspiciously great.",
        "A wise person once said: ship it and observe."
    ]

    public init(persistence: DihPersistence = DihPersistence()) {
        self.persistence = persistence
        loadProgress()
        passiveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.tick()
            }
        }
    }

    deinit {
        passiveTask?.cancel()
    }

    public var points: Int { save.points }
    public var currentStreak: Int { save.currentStreak }
    public var bestStreak: Int { save.bestStreak }
    public var totalCatches: Int { save.totalCatches }
    public var totalAttempts: Int { save.totalAttempts }
    public var bestScore: Int { save.bestScore }
    public var totalUpgrades: Int { save.upgrades.values.reduce(0, +) }
    public var accuracy: Double {
        guard save.totalAttempts > 0 else { return 0 }
        return Double(save.totalCatches) / Double(save.totalAttempts)
    }
    public var averagePointsPerMinute: Double {
        guard save.totalTimePlayed > 0 else { return 0 }
        return Double(save.totalPointsEarned) / save.totalTimePlayed * 60
    }
    public var helperActive: Bool { save.helperActive }
    public var helperLevel: Int { DihEconomy.level(for: .hotlineEfficiency, in: save) }
    public var payoutAmount: Int { DihEconomy.passivePointsPerInterval(in: save) }
    public var payoutInterval: TimeInterval { DihEconomy.passiveInterval(in: save) }
    public var secondsUntilPayout: TimeInterval {
        max(0, payoutInterval * (1 - passiveProgress))
    }
    public var targetScale: Double { DihEconomy.targetScale(in: save) }
    public var unlockedAchievements: [DihAchievementID] {
        save.achievements.compactMap(DihAchievementID.init(rawValue:))
    }

    public func definition(for id: DihUpgradeID) -> DihUpgradeDefinition {
        DihUpgradeDefinition.definition(for: id)
    }

    public func level(for id: DihUpgradeID) -> Int {
        DihEconomy.level(for: id, in: save)
    }

    public func cost(for id: DihUpgradeID) -> Int {
        DihEconomy.cost(for: id, level: level(for: id))
    }

    public func isUnlocked(_ id: DihUpgradeID) -> Bool {
        DihEconomy.isUnlocked(id, in: save)
    }

    @discardableResult
    public func caught(in size: CGSize, isClone: Bool = false) -> Bool {
        guard loaded else { return false }

        save.totalAttempts += 1
        save.totalCatches += 1
        save.currentStreak += 1
        save.bestStreak = max(save.bestStreak, save.currentStreak)

        var reward = DihEconomy.pointsPerCatch(in: save) + DihEconomy.comboBonus(in: save)
        if Double.random(in: 0...1) < DihEconomy.bonusChance(in: save) {
            reward += 2
            message = "LUCKY! +\(reward)"
        } else {
            message = reactions.randomElement() ?? "Nice."
        }
        addPoints(reward)
        save.bestScore = max(save.bestScore, save.points)

        if isClone {
            save.cloneCatches += 1
        }
        evaluateAchievements()

        let shouldOpenClone = !isClone && sessionCloneWindows < DihEconomy.cloneLimit(in: save) && Int.random(in: 0..<DihEconomy.cloneChance(in: save)) == 0
        if shouldOpenClone {
            sessionCloneWindows += 1
            save.totalCloneWindowsOpened += 1
            message = "I brought a friend."
        }
        buttonText = buttonNames.randomElement() ?? "catch me"
        moveButton(in: size)
        persist()
        return shouldOpenClone
    }

    public func runAway(from size: CGSize) {
        guard loaded else { return }
        guard Double.random(in: 0...1) < DihEconomy.runAwayChance(in: save) else {
            message = "I predicted that."
            return
        }

        save.totalEscapes += 1
        save.currentStreak = 0
        message = "RUN!"
        buttonPosition = randomPosition(in: size)
        persist()
    }

    public func callHotline() -> String {
        save.totalHotlineCalls += 1
        save.helperActive = true
        let result = advice.randomElement() ?? "The hotline has misplaced its advice."
        message = result
        evaluateAchievements()
        persist()
        return result
    }

    @discardableResult
    public func purchase(_ id: DihUpgradeID) -> Bool {
        guard isUnlocked(id) else { return false }
        let definition = definition(for: id)
        let currentLevel = level(for: id)
        guard definition.maximumLevel.map({ currentLevel < $0 }) ?? true else { return false }
        let price = cost(for: id)
        guard save.points >= price else { return false }

        save.points -= price
        save.upgrades[id.rawValue, default: 0] += 1
        toast = "Bought \(definition.name) level \(currentLevel + 1)."
        evaluateAchievements()
        persist()
        return true
    }

    public func clearToast() {
        toast = nil
    }

    public func resetProgress() {
        let newSave = DihSaveData()
        save = newSave
        offlineSummary = nil
        toast = "Progress reset. The button is smug again."
        buttonText = "click me"
        message = "Catch me."
        buttonPosition = CGPoint(x: 250, y: 210)
        sessionCloneWindows = 0
        Task {
            await persistence.deleteSave()
            await persistence.save(newSave)
        }
    }

    public func saveNow() {
        persist()
    }

    private func loadProgress() {
        Task { [weak self] in
            guard let self else { return }
            let loadedSave = await persistence.load()
            applyLoadedSave(loadedSave)
        }
    }

    private func applyLoadedSave(_ loadedSave: DihSaveData) {
        save = loadedSave
        let now = Date()
        if loadedSave.helperActive {
            let elapsed = min(max(0, now.timeIntervalSince(loadedSave.lastUpdate)), DihEconomy.maximumOfflineDuration)
            let payouts = Int(elapsed / DihEconomy.passiveInterval(in: loadedSave))
            if payouts > 0 {
                let generated = payouts * DihEconomy.passivePointsPerInterval(in: loadedSave)
                addPoints(generated)
                save.passivePointsGenerated += generated
                offlineSummary = "You were gone for \(Self.formatDuration(elapsed)). Your hotline generated \(generated) points."
                evaluateAchievements()
            }
        }
        save.lastUpdate = now
        lastTick = now
        loaded = true
        persist()
    }

    private func tick() {
        guard loaded else { return }
        let now = Date()
        save.totalTimePlayed += max(0, now.timeIntervalSince(lastTick))
        lastTick = now
        let elapsed = now.timeIntervalSince(save.lastUpdate)
        passiveProgress = min(1, elapsed / payoutInterval)
        guard save.helperActive, elapsed >= payoutInterval else { return }

        let payouts = Int(elapsed / payoutInterval)
        let generated = payouts * payoutAmount
        save.lastUpdate = save.lastUpdate.addingTimeInterval(Double(payouts) * payoutInterval)
        addPoints(generated)
        save.passivePointsGenerated += generated
        passiveProgress = 0
        evaluateAchievements()
        persist()
    }

    private func addPoints(_ amount: Int) {
        save.points += max(0, amount)
        save.totalPointsEarned += max(0, amount)
    }

    private func moveButton(in size: CGSize) {
        buttonPosition = randomPosition(in: size)
    }

    private func randomPosition(in size: CGSize) -> CGPoint {
        let inset = CGFloat(80 * targetScale)
        let x = CGFloat.random(in: inset...max(inset + 1, size.width - inset))
        let y = CGFloat.random(in: 120...max(121, size.height - 55))
        return CGPoint(x: x, y: y)
    }

    private func evaluateAchievements() {
        let checks: [(DihAchievementID, Bool)] = [
            (.firstCatch, save.totalCatches >= 1), (.catches10, save.totalCatches >= 10),
            (.catches100, save.totalCatches >= 100), (.catches1000, save.totalCatches >= 1000),
            (.firstUpgrade, totalUpgrades >= 1), (.firstHotlineCall, save.totalHotlineCalls >= 1),
            (.firstPassivePoint, save.passivePointsGenerated >= 1), (.passive100, save.passivePointsGenerated >= 100),
            (.points10000, save.totalPointsEarned >= 10_000), (.streak10, save.bestStreak >= 10),
            (.streak50, save.bestStreak >= 50), (.clone10, save.totalCloneWindowsOpened >= 10)
        ]
        for (achievement, isComplete) in checks where isComplete && !save.achievements.contains(achievement.rawValue) {
            save.achievements.append(achievement.rawValue)
            toast = "Achievement: \(achievement.title)"
        }
    }

    private func persist() {
        save.lastSaved = Date()
        let snapshot = save
        Task { await persistence.save(snapshot) }
    }

    private static func formatDuration(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(max(1, minutes))m"
    }
}