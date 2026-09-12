import Foundation

public struct DihTOMLSave: Codable, Sendable {
  public struct Game: Codable, Sendable {
    public var points: Int
    public var totalPointsEarned: Int
    public var totalCatches: Int
    public var totalAttempts: Int
    public var bestScore: Int
    public var currentStreak: Int
    public var bestStreak: Int
    public var totalTimePlayed: TimeInterval
    public var lastSaved: TimeInterval
    public var lastUpdate: TimeInterval

    private enum CodingKeys: String, CodingKey {
      case points
      case totalPointsEarned = "total_points_earned"
      case totalCatches = "total_catches"
      case totalAttempts = "total_attempts"
      case bestScore = "best_score"
      case currentStreak = "current_streak"
      case bestStreak = "best_streak"
      case totalTimePlayed = "total_time_played"
      case lastSaved = "last_saved"
      case lastUpdate = "last_update"
    }
  }

  public struct Helpers: Codable, Sendable {
    public var active: Bool
    public var ownedHelpers: Int
    public var totalPointsGenerated: Int
    public var totalOfflinePoints: Int
    public var totalPayouts: Int
    public var hotlineCalls: Int

    private enum CodingKeys: String, CodingKey {
      case active
      case ownedHelpers = "owned_helpers"
      case totalPointsGenerated = "total_points_generated"
      case totalOfflinePoints = "total_offline_points"
      case totalPayouts = "total_payouts"
      case hotlineCalls = "hotline_calls"
    }
  }

  public struct Prestige: Codable, Sendable {
    public var prestiges: Int
    public var currency: Int
    public var lifetimeCurrency: Int

    private enum CodingKeys: String, CodingKey {
      case prestiges, currency
      case lifetimeCurrency = "lifetime_currency"
    }
  }

  public struct Statistics: Codable, Sendable {
    public var cloneWindowsOpened: Int
    public var cloneCatches: Int
    public var escapes: Int
    public var rareCatches: Int
    public var criticalCatches: Int
    public var goldenCatches: Int
    public var longestSession: TimeInterval
    public var resetCount: Int

    private enum CodingKeys: String, CodingKey {
      case cloneWindowsOpened = "clone_windows_opened"
      case cloneCatches = "clone_catches"
      case escapes
      case rareCatches = "rare_catches"
      case criticalCatches = "critical_catches"
      case goldenCatches = "golden_catches"
      case longestSession = "longest_session"
      case resetCount = "reset_count"
    }
  }

  public var version: Int
  public var game: Game
  public var helpers: Helpers
  public var prestige: Prestige
  public var upgrades: [String: Int]
  public var statistics: Statistics
  public var achievements: [String]
  public var settings: DihSettingsData?

  private enum CodingKeys: String, CodingKey {
    case version, game, helpers, prestige, upgrades, statistics, achievements, settings
  }

  public init(save: DihSaveData, settings: DihSettingsData? = nil) {
    version = DihSaveData.currentVersion
    game = Game(
      points: save.points, totalPointsEarned: save.totalPointsEarned,
      totalCatches: save.totalCatches, totalAttempts: save.totalAttempts, bestScore: save.bestScore,
      currentStreak: save.currentStreak, bestStreak: save.bestStreak,
      totalTimePlayed: save.totalTimePlayed, lastSaved: save.lastSaved.timeIntervalSince1970,
      lastUpdate: save.lastUpdate.timeIntervalSince1970)
    helpers = Helpers(
      active: save.ownedHelpers > 0, ownedHelpers: save.ownedHelpers,
      totalPointsGenerated: save.passivePointsGenerated,
      totalOfflinePoints: save.totalOfflinePoints, totalPayouts: save.totalHotlinePayouts,
      hotlineCalls: save.totalHotlineCalls)
    prestige = Prestige(prestiges: 0, currency: 0, lifetimeCurrency: 0)
    upgrades = save.upgrades.reduce(into: [:]) { result, entry in
      result[Self.snakeCase(entry.key)] = entry.value
    }
    statistics = Statistics(
      cloneWindowsOpened: save.totalCloneWindowsOpened, cloneCatches: save.cloneCatches,
      escapes: save.totalEscapes, rareCatches: save.rareCatches,
      criticalCatches: save.criticalCatches, goldenCatches: save.goldenCatches,
      longestSession: save.longestSession, resetCount: save.resetCount)
    achievements = save.achievements
    self.settings = settings
  }

  public func saveData() -> DihSaveData {
    var save = DihSaveData()
    save.version = version
    save.points = game.points
    save.totalPointsEarned = game.totalPointsEarned
    save.totalCatches = game.totalCatches
    save.totalAttempts = game.totalAttempts
    save.bestScore = game.bestScore
    save.currentStreak = game.currentStreak
    save.bestStreak = game.bestStreak
    save.totalTimePlayed = game.totalTimePlayed
    save.lastSaved = Date(timeIntervalSince1970: game.lastSaved)
    save.lastUpdate = Date(timeIntervalSince1970: game.lastUpdate)
    save.ownedHelpers = max(0, helpers.ownedHelpers)
    save.passivePointsGenerated = helpers.totalPointsGenerated
    save.totalOfflinePoints = helpers.totalOfflinePoints
    save.totalHotlinePayouts = helpers.totalPayouts
    save.totalHotlineCalls = helpers.hotlineCalls
    save.upgrades = upgrades.reduce(into: [:]) { result, entry in
      result[Self.camelCase(entry.key)] = entry.value
    }
    save.totalCloneWindowsOpened = statistics.cloneWindowsOpened
    save.cloneCatches = statistics.cloneCatches
    save.totalEscapes = statistics.escapes
    save.rareCatches = statistics.rareCatches
    save.criticalCatches = statistics.criticalCatches
    save.goldenCatches = statistics.goldenCatches
    save.longestSession = statistics.longestSession
    save.resetCount = statistics.resetCount
    save.achievements = achievements
    return save
  }

  private static func snakeCase(_ value: String) -> String {
    value.reduce(into: "") { result, character in
      if character.isUppercase {
        result.append("_")
        result.append(character.lowercased())
      } else {
        result.append(character)
      }
    }
  }

  private static func camelCase(_ value: String) -> String {
    value.split(separator: "_").enumerated().map { index, part in
      index == 0 ? part.lowercased() : part.capitalized
    }.joined()
  }
}
