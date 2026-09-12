import Foundation

public struct DihSaveData: Codable, Sendable {
  public static let currentVersion = 2
  public var version = Self.currentVersion
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
  public var ownedHelpers = 0
  public var helperBaseIncome = 1.0
  public var lastSaved = Date()
  public var lastUpdate = Date()

  public var helperActive: Bool { ownedHelpers > 0 }

  public init() {}

  private enum CodingKeys: String, CodingKey {
    case version, points, totalPointsEarned, totalCatches, totalAttempts, bestScore
    case currentStreak, bestStreak, totalTimePlayed, passivePointsGenerated
    case totalHotlineCalls, totalCloneWindowsOpened, cloneCatches, totalEscapes
    case totalOfflinePoints, totalHotlinePayouts, rareCatches, criticalCatches
    case goldenCatches, longestSession, resetCount, upgrades, achievements
    case ownedHelpers, helperBaseIncome, lastSaved, lastUpdate
  }

  private enum LegacyCodingKeys: String, CodingKey {
    case helperActive
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
    passivePointsGenerated =
      try values.decodeIfPresent(Int.self, forKey: .passivePointsGenerated) ?? 0
    totalHotlineCalls = try values.decodeIfPresent(Int.self, forKey: .totalHotlineCalls) ?? 0
    totalCloneWindowsOpened =
      try values.decodeIfPresent(Int.self, forKey: .totalCloneWindowsOpened) ?? 0
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

    let legacyValues = try? decoder.container(keyedBy: LegacyCodingKeys.self)
    let legacyHelperActive = try legacyValues?.decodeIfPresent(Bool.self, forKey: .helperActive) ?? false
    ownedHelpers = try values.decodeIfPresent(Int.self, forKey: .ownedHelpers) ?? (legacyHelperActive ? 1 : 0)
    helperBaseIncome = try values.decodeIfPresent(Double.self, forKey: .helperBaseIncome) ?? 1.0
    lastSaved = try values.decodeIfPresent(Date.self, forKey: .lastSaved) ?? Date()
    lastUpdate = try values.decodeIfPresent(Date.self, forKey: .lastUpdate) ?? lastSaved
  }
}
