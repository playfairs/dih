import Foundation

public enum DihUpgradeID: String, CaseIterable, Codable, Identifiable, Sendable {
    case betterGrip
    case quickHands
    case hotlineEfficiency
    case fasterHotline
    case cloneDiscount
    case luckyDih
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

    public var identity: DihUpgradeID { id }
    public var identifier: String { id.rawValue }

    public static let all: [DihUpgradeDefinition] = [
        .init(id: .betterGrip, name: "Better Grip", description: "The button hesitates a little longer before escaping.", icon: "hand.raised.fill", baseCost: 8, growth: 1.55, maximumLevel: 8, unlockText: "Available immediately"),
        .init(id: .biggerTarget, name: "Bigger Target", description: "Makes the target more forgiving without making it proud.", icon: "arrow.up.left.and.arrow.down.right", baseCost: 10, growth: 1.6, maximumLevel: 8, unlockText: "Available immediately"),
        .init(id: .quickHands, name: "Quick Hands", description: "Adds one point to every successful catch.", icon: "bolt.fill", baseCost: 12, growth: 1.7, maximumLevel: 10, unlockText: "Available immediately"),
        .init(id: .hotlineEfficiency, name: "Hotline Efficiency", description: "Your helper earns more points per payout.", icon: "phone.badge.waveform.fill", baseCost: 15, growth: 1.65, maximumLevel: 10, unlockText: "Call the hotline once"),
        .init(id: .fasterHotline, name: "Faster Hotline", description: "Shortens the wait between helper payouts.", icon: "gauge.with.dots.needle.67percent", baseCost: 20, growth: 1.7, maximumLevel: 8, unlockText: "Call the hotline once"),
        .init(id: .escapePrediction, name: "Escape Prediction", description: "Reduces the chance of an immediate escape reaction.", icon: "eye.fill", baseCost: 16, growth: 1.65, maximumLevel: 8, unlockText: "Catch 15 buttons"),
        .init(id: .cloneDiscount, name: "Clone Discount", description: "Makes clone windows show up more often and expands the clone limit.", icon: "square.on.square", baseCost: 10, growth: 1.7, maximumLevel: 6, unlockText: "Open a clone window"),
        .init(id: .luckyDih, name: "Lucky Dih", description: "Sometimes a catch pays out a surprise bonus.", icon: "sparkles", baseCost: 18, growth: 1.75, maximumLevel: 10, unlockText: "Catch 20 buttons"),
        .init(id: .combo, name: "Combo", description: "Long streaks add extra points to each catch.", icon: "flame.fill", baseCost: 25, growth: 1.8, maximumLevel: 8, unlockText: "Catch 10 buttons")
    ]

    public static func definition(for id: DihUpgradeID) -> DihUpgradeDefinition {
        all.first { $0.id == id } ?? all[0]
    }

}

public enum DihAchievementID: String, CaseIterable, Codable, Sendable {
    case firstCatch, catches10, catches100, catches1000
    case firstUpgrade, firstHotlineCall, firstPassivePoint, passive100
    case points10000, streak10, streak50, clone10

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
    public var upgrades: [String: Int] = [:]
    public var achievements: [String] = []
    public var helperActive = false
    public var lastSaved = Date()
    public var lastUpdate = Date()

    public init() {}
}