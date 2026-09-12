import Combine
import Foundation

@MainActor
public final class DihGame: ObservableObject {
  @Published public private(set) var save = DihSaveData()
  @Published public private(set) var offlineSummary: String?
  @Published public private(set) var toast: String?
  @Published public private(set) var scorePopup: String?
  @Published public private(set) var scorePopupID = 0
  @Published public private(set) var passiveProgress = 0.0
  @Published public private(set) var effectiveTargetScale = 1.0
  @Published public var buttonPosition = CGPoint(x: 250, y: 210)
  @Published public var buttonText = "click me"
  @Published public var message = "Catch me."

  public let persistence: DihPersistence
  public let settings: DihSettings
  private var passiveTask: Task<Void, Never>?
  private var lastTick = Date()
  private var sessionCloneWindows = 0
  private var loaded = false
  private var lastButtonMove = Date.distantPast

  private let buttonNames = ["catch me", "nope", "again", "try again", "lol", ">:)"]
  private let reactions = [
    "HEY!", "STOP!", "HOW DID YOU CATCH ME?", "NOOO", "AGAIN?",
    "I WASN'T READY", "CHEATER", "...", ">:(", "HELP",
  ]
  private let advice = [
    "The vibes are confusing, but the snacks are good.",
    "Your future contains a button. It will run away.",
    "Do one small thing, then dramatically announce it.",
    "The universe says: maybe close one browser tab.",
    "You are doing great. Suspiciously great.",
    "A wise person once said: ship it and observe.",
    "`nox run` is probably how you are seeing this",
  ]

  public init(persistence: DihPersistence = DihPersistence(), settings: DihSettings = DihSettings())
  {
    self.persistence = persistence
    self.settings = settings
    effectiveTargetScale = DihEconomy.effectiveTargetScale(in: save, largerButton: settings.data.largerButton)
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
  public var helperActive: Bool { save.ownedHelpers > 0 }
  public var helperLevel: Int { DihHelperSystem.level(in: save) }
  public var payoutAmount: Int { DihHelperSystem.payout(in: save) }
  public var payoutInterval: TimeInterval { DihHelperSystem.interval(in: save) }
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

  public func refreshDerivedScale() {
    effectiveTargetScale = DihEconomy.effectiveTargetScale(
      in: save, largerButton: settings.data.largerButton)
  }

  @discardableResult
  public func caught(in arena: CGRect, buttonSize: CGSize, isClone: Bool = false) -> Bool {
    guard loaded else { return false }

    save.totalAttempts += 1
    save.totalCatches += 1
    save.currentStreak += 1
    save.bestStreak = max(save.bestStreak, save.currentStreak)

    var reward = DihEconomy.pointsPerCatch(in: save) + DihEconomy.comboBonus(in: save)
    if isClone { reward *= DihEconomy.cloneRewardMultiplier(in: save) }
    if Double.random(in: 0...1) < DihEconomy.bonusChance(in: save) {
      reward += 2
      save.rareCatches += 1
      message = "LUCKY! +\(reward)"
    } else {
      message = reactions.randomElement() ?? "Nice."
    }
    if !settings.data.showReactions { message = "" }
    if Double.random(in: 0...1) < DihEconomy.criticalChance(in: save) {
      reward *= 5
      save.criticalCatches += 1
      message = "CRITICAL! +\(reward)"
    }
    if Double.random(in: 0...1) < DihEconomy.goldenChance(in: save) {
      reward *= 10
      save.goldenCatches += 1
      save.rareCatches += 1
      message = "GOLDEN DIH! +\(reward)"
    }
    addPoints(reward)
    scorePopup = "+\(reward)"
    scorePopupID += 1
    let popupID = scorePopupID
    Task { [weak self] in
      try? await Task.sleep(for: .milliseconds(700))
      guard let self, scorePopupID == popupID else { return }
      scorePopup = nil
    }
    save.bestScore = max(save.bestScore, save.points)

    if isClone {
      save.cloneCatches += 1
    }
    evaluateAchievements()

    let shouldOpenClone =
      settings.data.cloneWindowsEnabled && !isClone
      && sessionCloneWindows
        < min(settings.data.maximumCloneWindows, DihEconomy.cloneLimit(in: save))
      && Int.random(in: 0..<DihEconomy.cloneChance(in: save)) == 0
    if shouldOpenClone {
      sessionCloneWindows += 1
      save.totalCloneWindowsOpened += 1
      message = "I brought a friend."
    }
    buttonText = buttonNames.randomElement() ?? "catch me"
    moveButton(in: arena, buttonSize: buttonSize)
    objectWillChange.send()
    persist()
    return shouldOpenClone
  }

  public func runAway(from arena: CGRect, buttonSize: CGSize) {
    guard loaded else { return }
    guard settings.data.movementEnabled && settings.data.fleeBehaviorEnabled else { return }
    var escapeChance = DihEconomy.runAwayChance(in: save)
    if settings.data.slowerButton { escapeChance *= 0.7 }
    switch settings.data.difficulty {
    case .relaxed: escapeChance *= 0.75
    case .normal: break
    case .spicy: escapeChance *= 1.2
    }
    guard Double.random(in: 0...1) < min(1, escapeChance) else {
      message = "I predicted that."
      return
    }

    save.totalEscapes += 1
    if Double.random(in: 0...1) >= DihEconomy.secondChance(in: save) {
      save.currentStreak = 0
    } else {
      message = "SECOND CHANCE!"
    }
    if message != "SECOND CHANCE!" { message = "RUN!" }
    moveButton(in: arena, buttonSize: buttonSize)
    objectWillChange.send()
    persist()
  }

  public func autonomousMoveIfNeeded(in arena: CGRect, buttonSize: CGSize) {
    guard loaded,
      settings.data.movementEnabled,
      !settings.data.reducedMovement,
      Date().timeIntervalSince(lastButtonMove) >= DihEconomy.movementDelay(in: save),
      Double.random(in: 0...1) < DihEconomy.autonomousMovementChance(in: save)
    else { return }

    message = settings.data.showReactions ? "I moved on my own." : ""
    moveButton(in: arena, buttonSize: buttonSize)
    objectWillChange.send()
    persist()
  }

  public func updateButtonPosition(in arena: CGRect, buttonSize: CGSize) {
    var nextPosition = DihArena.clampedCenter(
      in: arena, buttonSize: buttonSize, desired: buttonPosition)
    if settings.data.reducedMovement {
      nextPosition = DihArena.clampedCenter(
        in: arena, buttonSize: buttonSize, desired: CGPoint(x: arena.midX, y: arena.midY))
    }
    guard nextPosition != buttonPosition else { return }
    buttonPosition = nextPosition
  }

  public func callHotline() -> String {
    let nextCost = DihEconomy.helperCost(forOwned: save.ownedHelpers)
    guard save.points >= nextCost else {
      let result = "Not enough points for another helper."
      message = result
      objectWillChange.send()
      persist()
      return result
    }

    save.points -= nextCost
    save.ownedHelpers += 1
    save.totalHotlineCalls += 1

    let result = advice.randomElement() ?? "The hotline has misplaced its advice."
    message = result
    evaluateAchievements()
    objectWillChange.send()
    persist()
    return result
  }

  @discardableResult
  public func purchase(_ id: DihUpgradeID, quantity: Int = 1) -> Bool {
    guard isUnlocked(id) else { return false }
    let definition = definition(for: id)
    let currentLevel = level(for: id)
    guard quantity > 0 else { return false }
    guard currentLevel < definition.maximumLevel else { return false }

    let purchased = DihEconomy.purchase(id, quantity: quantity, in: &save)
    guard purchased > 0 else { return false }

    let newLevel = level(for: id)
    toast = "Bought \(definition.name) level \(newLevel)."
    refreshDerivedScale()
    evaluateAchievements()
    objectWillChange.send()
    persist()
    return true
  }

  public func clearToast() {
    toast = nil
  }

  public func resetProgress() {
    let resetCount = save.resetCount + 1
    let newSave = DihSaveData()
    save = newSave
    save.resetCount = resetCount
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
    refreshDerivedScale()
    let now = Date()
    if loadedSave.ownedHelpers > 0 {
      let elapsed = min(
        max(0, now.timeIntervalSince(loadedSave.lastUpdate)),
        DihEconomy.offlineDuration(in: loadedSave))
      let payoutCount = DihEconomy.passivePayoutCount(for: elapsed, in: loadedSave)
      if payoutCount > 0 {
        let generated = payoutCount * DihEconomy.passivePointsPerInterval(in: loadedSave)
        let awarded = DihEconomy.awardPassivePayout(in: &save, generated: generated)
        save.totalOfflinePoints += awarded
        offlineSummary =
          "You were gone for \(Self.formatDuration(elapsed)). Your hotline generated \(awarded) points."
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
    save.longestSession = max(save.longestSession, save.totalTimePlayed)
    lastTick = now
    let elapsed = now.timeIntervalSince(save.lastUpdate)
    let payoutInterval = DihEconomy.passiveInterval(in: save)
    passiveProgress = min(1, elapsed / payoutInterval)

    guard save.ownedHelpers > 0 else { return }
    let payoutCount = DihEconomy.passivePayoutCount(for: elapsed, in: save)
    guard payoutCount > 2 else { return }

    let generated = payoutCount * DihEconomy.passivePointsPerInterval(in: save)
    let awarded = DihEconomy.awardPassivePayout(in: &save, generated: generated)
    save.totalHotlinePayouts += payoutCount
    save.lastUpdate = payoutInterval > 1
      ? save.lastUpdate.addingTimeInterval(Double(payoutCount) * payoutInterval)
      : now
    if settings.data.showPassiveNotifications {
      toast = "The hotline generated +\(awarded) points."
    }
    refreshDerivedScale()
    passiveProgress = 0
    evaluateAchievements()
    persist()
  }

  private func addPoints(_ amount: Int) {
    save.points += max(0, amount)
    save.totalPointsEarned += max(0, amount)
  }

  private func moveButton(in arena: CGRect, buttonSize: CGSize) {
    guard settings.data.movementEnabled else { return }
    let now = Date()
    guard now.timeIntervalSince(lastButtonMove) >= DihEconomy.movementDelay(in: save) else {
      return
    }
    lastButtonMove = now
    buttonPosition = randomPosition(in: arena, buttonSize: buttonSize)
  }

  private func randomPosition(in arena: CGRect, buttonSize: CGSize) -> CGPoint {
    var generator = SystemRandomNumberGenerator()
    return DihArena.randomCenter(in: arena, buttonSize: buttonSize, generator: &generator)
  }

  private func evaluateAchievements() {
    for achievement in DihAchievementSystem.newlyCompleted(in: save, totalUpgrades: totalUpgrades) {
      guard !save.achievements.contains(achievement.rawValue) else { continue }
      save.achievements.append(achievement.rawValue)
      if settings.data.achievementNotificationsEnabled {
        toast = "Achievement: \(achievement.title)"
      }
    }
  }

  private func persist() {
    save.lastSaved = Date()
    let snapshot = save
    Task { await persistence.save(snapshot, settings: settings.data) }
  }

  private static func formatDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = Int(duration / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours > 0 { return "\(hours)h \(minutes)m" }
    return "\(max(1, minutes))m"
  }
}
