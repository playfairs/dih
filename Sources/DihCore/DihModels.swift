import Foundation

public enum DihUpgradeID: String, CaseIterable, Codable, Identifiable, Sendable {
    case betterGrip
    case stickyButton
    case slowerDih
    case magnetHands
    case reflexes
    case quickHands
    case comboTraining
    case hotlineEfficiency
    case fasterHotline
    case betterAdvice
    case dedicatedOperator
    case automatedHotline
    case hotlineMultiplier
    case cloneDiscount
    case cloneCapacity
    case cloneRewards
    case cloneCoordination
    case cloneMultiplier
    case luckyDih
    case criticalCatch
    case pointMultiplier
    case streakMastery
    case goldenDih
    case secondChance
    case arcadeLuck
    case escapePrediction
    case biggerTarget
    case combo

    public var id: String { rawValue }
}

public struct DihUpgradeDefinition: Identifiable, Sendable {
    public let id: DihUpgradeID
    public let name: String
    public let description: String
    public let icon: String
    public let baseCost: Int
    public let growth: Double
    public let maximumLevel: Int?
    public let unlockText: String
    public let tier: DihUpgradeTier
    public let prerequisites: [(DihUpgradeID, Int)]
    public let minimumCatches: Int
    public let minimumPoints: Int

    public init(id: DihUpgradeID, name: String, description: String, icon: String, baseCost: Int, growth: Double, maximumLevel: Int?, unlockText: String, tier: DihUpgradeTier = .basic, prerequisites: [(DihUpgradeID, Int)] = [], minimumCatches: Int = 0, minimumPoints: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.baseCost = baseCost
        self.growth = growth
        self.maximumLevel = maximumLevel
        self.unlockText = unlockText
        self.tier = tier
        self.prerequisites = prerequisites
        self.minimumCatches = minimumCatches
        self.minimumPoints = minimumPoints
    }

    public var identity: DihUpgradeID { id }
    public var identifier: String { id.rawValue }

    public static let all: [DihUpgradeDefinition] = [
        .init(id: .betterGrip, name: "Better Grip", description: "The button hesitates before escaping.", icon: "hand.raised.fill", baseCost: 8, growth: 1.55, maximumLevel: 8, unlockText: "Available immediately"),
        .init(id: .biggerTarget, name: "Bigger Target", description: "Makes the target more forgiving.", icon: "arrow.up.left.and.arrow.down.right", baseCost: 10, growth: 1.6, maximumLevel: 8, unlockText: "Available immediately"),
        .init(id: .quickHands, name: "Quick Hands", description: "Adds one point to every catch.", icon: "bolt.fill", baseCost: 12, growth: 1.7, maximumLevel: 10, unlockText: "Available immediately"),
        .init(id: .magnetHands, name: "Magnet Hands", description: "Expands the effective clickable area.", icon: "scope", baseCost: 18, growth: 1.7, maximumLevel: 8, unlockText: "Requires Bigger Target Lv. 2", prerequisites: [(.biggerTarget, 2)]),
        .init(id: .stickyButton, name: "Sticky Button", description: "Reduces movement frequency after a catch.", icon: "pin.fill", baseCost: 24, growth: 1.7, maximumLevel: 8, unlockText: "Requires Better Grip Lv. 2", tier: .advanced, prerequisites: [(.betterGrip, 2)], minimumCatches: 10),
        .init(id: .slowerDih, name: "Slower Dih", description: "Makes escapes less frantic.", icon: "tortoise.fill", baseCost: 28, growth: 1.75, maximumLevel: 8, unlockText: "Requires Sticky Button Lv. 2", tier: .advanced, prerequisites: [(.stickyButton, 2)], minimumCatches: 25),
        .init(id: .escapePrediction, name: "Escape Prediction", description: "Reduces surprise escapes.", icon: "eye.fill", baseCost: 16, growth: 1.65, maximumLevel: 8, unlockText: "Catch 15 buttons", minimumCatches: 15),
        .init(id: .reflexes, name: "Reflexes", description: "Makes hover escapes much less likely.", icon: "hare.fill", baseCost: 45, growth: 1.8, maximumLevel: 8, unlockText: "Requires Escape Prediction Lv. 3", tier: .expert, prerequisites: [(.escapePrediction, 3)], minimumCatches: 50),
        .init(id: .comboTraining, name: "Combo Training", description: "Improves streak rewards.", icon: "figure.run", baseCost: 32, growth: 1.75, maximumLevel: 8, unlockText: "Catch 10 buttons", minimumCatches: 10),
        .init(id: .combo, name: "Combo", description: "Long streaks add extra points.", icon: "flame.fill", baseCost: 25, growth: 1.8, maximumLevel: 8, unlockText: "Requires Combo Training Lv. 2", tier: .advanced, prerequisites: [(.comboTraining, 2)], minimumCatches: 20),
        .init(id: .hotlineEfficiency, name: "Hotline Efficiency", description: "Your helper earns more per payout.", icon: "phone.badge.waveform.fill", baseCost: 15, growth: 1.65, maximumLevel: 10, unlockText: "Call the hotline once"),
        .init(id: .fasterHotline, name: "Faster Hotline", description: "Shortens the helper wait.", icon: "gauge.with.dots.needle.67percent", baseCost: 20, growth: 1.7, maximumLevel: 8, unlockText: "Call the hotline once"),
        .init(id: .betterAdvice, name: "Better Advice", description: "Advice earns a small passive bonus.", icon: "lightbulb.fill", baseCost: 35, growth: 1.75, maximumLevel: 8, unlockText: "Requires Hotline Efficiency Lv. 2", tier: .advanced, prerequisites: [(.hotlineEfficiency, 2)]),
        .init(id: .dedicatedOperator, name: "Dedicated Operator", description: "Raises the offline earnings cap.", icon: "person.crop.circle.badge.checkmark", baseCost: 50, growth: 1.8, maximumLevel: 5, unlockText: "Requires Faster Hotline Lv. 3", tier: .expert, prerequisites: [(.fasterHotline, 3)], minimumPoints: 100),
        .init(id: .automatedHotline, name: "Automated Hotline", description: "Greatly improves passive generation.", icon: "gearshape.2.fill", baseCost: 80, growth: 1.9, maximumLevel: 5, unlockText: "Requires Dedicated Operator Lv. 2", tier: .elite, prerequisites: [(.dedicatedOperator, 2)], minimumPoints: 500),
        .init(id: .hotlineMultiplier, name: "Hotline Multiplier", description: "Multiplies helper payouts.", icon: "multiply.circle.fill", baseCost: 110, growth: 2, maximumLevel: 5, unlockText: "Requires Automated Hotline Lv. 2", tier: .elite, prerequisites: [(.automatedHotline, 2)], minimumPoints: 1_000),
        .init(id: .cloneDiscount, name: "Clone Discount", description: "Clones appear more often.", icon: "square.on.square", baseCost: 10, growth: 1.7, maximumLevel: 6, unlockText: "Open a clone window"),
        .init(id: .cloneCapacity, name: "Clone Capacity", description: "Allows more clone windows.", icon: "rectangle.stack.badge.plus", baseCost: 30, growth: 1.8, maximumLevel: 8, unlockText: "Requires Clone Discount Lv. 2", tier: .advanced, prerequisites: [(.cloneDiscount, 2)]),
        .init(id: .cloneRewards, name: "Clone Rewards", description: "Clone catches pay more.", icon: "gift.fill", baseCost: 40, growth: 1.8, maximumLevel: 8, unlockText: "Catch in a clone window", tier: .advanced, minimumCatches: 30),
        .init(id: .cloneCoordination, name: "Clone Coordination", description: "Clone buttons become easier.", icon: "person.2.fill", baseCost: 55, growth: 1.85, maximumLevel: 6, unlockText: "Requires Clone Rewards Lv. 2", tier: .expert, prerequisites: [(.cloneRewards, 2)]),
        .init(id: .cloneMultiplier, name: "Clone Multiplier", description: "Multiplies clone rewards.", icon: "square.3.layers.3d", baseCost: 100, growth: 2, maximumLevel: 5, unlockText: "Requires Clone Coordination Lv. 2", tier: .elite, prerequisites: [(.cloneCoordination, 2)], minimumPoints: 1_000),
        .init(id: .luckyDih, name: "Lucky Dih", description: "Adds a chance for bonus points.", icon: "sparkles", baseCost: 18, growth: 1.75, maximumLevel: 10, unlockText: "Catch 20 buttons", minimumCatches: 20),
        .init(id: .criticalCatch, name: "Critical Catch", description: "Rare catches pay a large bonus.", icon: "burst.fill", baseCost: 60, growth: 1.9, maximumLevel: 8, unlockText: "Requires Lucky Dih Lv. 3", tier: .expert, prerequisites: [(.luckyDih, 3)], minimumPoints: 250),
        .init(id: .pointMultiplier, name: "Point Multiplier", description: "Increases all active catch rewards.", icon: "xmark.circle.fill", baseCost: 75, growth: 1.9, maximumLevel: 6, unlockText: "Earn 1,000 lifetime points", tier: .expert, minimumPoints: 1_000),
        .init(id: .streakMastery, name: "Streak Mastery", description: "Makes streaks more valuable.", icon: "chart.line.uptrend.xyaxis", baseCost: 90, growth: 1.9, maximumLevel: 6, unlockText: "Reach a 25 catch streak", tier: .expert, minimumCatches: 25),
        .init(id: .goldenDih, name: "Golden Dih", description: "Unlocks rare golden catches.", icon: "crown.fill", baseCost: 150, growth: 2, maximumLevel: 3, unlockText: "Earn 10,000 lifetime points", tier: .elite, minimumPoints: 10_000),
        .init(id: .secondChance, name: "Second Chance", description: "Sometimes protects your streak.", icon: "arrow.uturn.backward.circle.fill", baseCost: 70, growth: 1.9, maximumLevel: 5, unlockText: "Reach a 25 catch streak", tier: .expert, minimumCatches: 25),
        .init(id: .arcadeLuck, name: "Arcade Luck", description: "Improves rare event odds.", icon: "dice.fill", baseCost: 125, growth: 2, maximumLevel: 6, unlockText: "Earn 5,000 lifetime points", tier: .elite, minimumPoints: 5_000)
    ]

    public static func definition(for id: DihUpgradeID) -> DihUpgradeDefinition {
        all.first { $0.id == id } ?? all[0]
    }

}

public enum DihUpgradeTier: String, Codable, CaseIterable, Sendable {
    case basic = "Basic"
    case advanced = "Advanced"
    case expert = "Expert"
    case elite = "Elite"
}

public enum DihAchievementID: String, CaseIterable, Codable, Sendable {
    case firstCatch, catches10, catches100, catches1000
    case firstUpgrade, firstHotlineCall, firstPassivePoint, passive100
    case points10000, streak10, streak50, clone10, firstOffline, upgradeCollector
    case goldenCatch, criticalCatch, millionaire, upgradeEverything

    public var title: String {
        switch self {
        case .firstCatch: "First Contact"
        case .catches10: "Getting the Hang of It"
        case .catches100: "Professional Button Catcher"
        case .catches1000: "Please Go Outside"
        case .firstUpgrade: "Retail Therapy"
        case .firstHotlineCall: "On Hold"
        case .firstPassivePoint: "Money While Sleeping"
        case .passive100: "The Hotline Works"
        case .points10000: "Pointy Situation"
        case .streak10: "Unreasonably Consistent"
        case .streak50: "The Button Is Sweating"
        case .clone10: "It Has Friends Now"
        case .firstOffline: "Welcome Back"
        case .upgradeCollector: "Upgrade Collector"
        case .goldenCatch: "Golden Catch"
        case .criticalCatch: "Critical Condition"
        case .millionaire: "Millionaire"
        case .upgradeEverything: "Everything Is Fine"
        }
    }

    public var icon: String {
        switch self {
        case .firstCatch, .catches10, .catches100, .catches1000: "target"
        case .firstUpgrade: "cart.fill"
        case .firstHotlineCall, .passive100, .firstPassivePoint: "phone.fill"
        case .points10000: "star.fill"
        case .streak10, .streak50: "flame.fill"
        case .clone10: "square.on.square"
        case .firstOffline: "moon.stars.fill"
        case .upgradeCollector: "shippingbox.fill"
        case .goldenCatch: "crown.fill"
        case .criticalCatch: "burst.fill"
        case .millionaire: "banknote.fill"
        case .upgradeEverything: "checkmark.seal.fill"
        }
    }
}

public struct DihSaveData: Codable, Sendable {
    public static let currentVersion = 1

    public var version: Int = Self.currentVersion
    public var points = 0
    public var totalPointsEarned = 0
    public var totalCatches = 0
    public var totalAttempts = 0
    public var bestScore = 0
    public var currentStreak = 0
    public var bestStreak = 0
    public var totalTimePlayed: TimeInterval = 0
    public var passivePointsGenerated = 0
    public var totalHotlineCalls = 0
    public var totalCloneWindowsOpened = 0
    public var cloneCatches = 0
    public var totalEscapes = 0
    public var totalOfflinePoints = 0
    public var totalHotlinePayouts = 0
    public var rareCatches = 0
    public var criticalCatches = 0
    public var goldenCatches = 0
    public var longestSession: TimeInterval = 0
    public var resetCount = 0
    public var upgrades: [String: Int] = [:]
    public var achievements: [String] = []
    public var helperActive = false
    public var lastSaved = Date()
    public var lastUpdate = Date()

    public init() {}

    private enum CodingKeys: String, CodingKey {
        case version, points, totalPointsEarned, totalCatches, totalAttempts, bestScore
        case currentStreak, bestStreak, totalTimePlayed, passivePointsGenerated
        case totalHotlineCalls, totalCloneWindowsOpened, cloneCatches, totalEscapes
        case totalOfflinePoints, totalHotlinePayouts, rareCatches, criticalCatches
        case goldenCatches, longestSession, resetCount, upgrades, achievements
        case helperActive, lastSaved, lastUpdate
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        version = try values.decodeIfPresent(Int.self, forKey: .version) ?? Self.currentVersion
        points = try values.decodeIfPresent(Int.self, forKey: .points) ?? 0
        totalPointsEarned = try values.decodeIfPresent(Int.self, forKey: .totalPointsEarned) ?? points
        totalCatches = try values.decodeIfPresent(Int.self, forKey: .totalCatches) ?? 0
        totalAttempts = try values.decodeIfPresent(Int.self, forKey: .totalAttempts) ?? totalCatches
        bestScore = try values.decodeIfPresent(Int.self, forKey: .bestScore) ?? points
        currentStreak = try values.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        bestStreak = try values.decodeIfPresent(Int.self, forKey: .bestStreak) ?? currentStreak
        totalTimePlayed = try values.decodeIfPresent(TimeInterval.self, forKey: .totalTimePlayed) ?? 0
        passivePointsGenerated = try values.decodeIfPresent(Int.self, forKey: .passivePointsGenerated) ?? 0
        totalHotlineCalls = try values.decodeIfPresent(Int.self, forKey: .totalHotlineCalls) ?? 0
        totalCloneWindowsOpened = try values.decodeIfPresent(Int.self, forKey: .totalCloneWindowsOpened) ?? 0
        cloneCatches = try values.decodeIfPresent(Int.self, forKey: .cloneCatches) ?? 0
        totalEscapes = try values.decodeIfPresent(Int.self, forKey: .totalEscapes) ?? 0
        totalOfflinePoints = try values.decodeIfPresent(Int.self, forKey: .totalOfflinePoints) ?? 0
        totalHotlinePayouts = try values.decodeIfPresent(Int.self, forKey: .totalHotlinePayouts) ?? 0
        rareCatches = try values.decodeIfPresent(Int.self, forKey: .rareCatches) ?? 0
        criticalCatches = try values.decodeIfPresent(Int.self, forKey: .criticalCatches) ?? 0
        goldenCatches = try values.decodeIfPresent(Int.self, forKey: .goldenCatches) ?? 0
        longestSession = try values.decodeIfPresent(TimeInterval.self, forKey: .longestSession) ?? 0
        resetCount = try values.decodeIfPresent(Int.self, forKey: .resetCount) ?? 0
        upgrades = try values.decodeIfPresent([String: Int].self, forKey: .upgrades) ?? [:]
        achievements = try values.decodeIfPresent([String].self, forKey: .achievements) ?? []
        helperActive = try values.decodeIfPresent(Bool.self, forKey: .helperActive) ?? false
        lastSaved = try values.decodeIfPresent(Date.self, forKey: .lastSaved) ?? Date()
        lastUpdate = try values.decodeIfPresent(Date.self, forKey: .lastUpdate) ?? lastSaved
    }
}