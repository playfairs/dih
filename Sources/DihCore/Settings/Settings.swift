import Combine
import Foundation
import TOML

public enum DihAppearance: String, Codable, CaseIterable, Sendable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"

  public var displayName: String { rawValue }
}

public struct DihSettingsData: Codable, Sendable {
  public var version = 2
  public var movementEnabled = true
  public var fleeBehaviorEnabled = true
  public var difficulty = DihDifficulty.normal
  public var animationIntensity = 1.0
  public var showReactions = true
  public var showScorePopups = true
  public var cloneWindowsEnabled = true
  public var maximumCloneWindows = 3
  public var soundEffectsEnabled = true
  public var masterVolume = 0.7
  public var compactMode = false
  public var showStatistics = true
  public var showPassiveNotifications = true
  public var showAchievements = true
  public var achievementNotificationsEnabled = true
  public var reducedMovement = false
  public var largerButton = false
  public var slowerButton = false
  public var highContrast = false
  public var appearance = DihAppearance.system
  public var lastSaved = Date()

  public init() {}

  private enum CodingKeys: String, CodingKey {
    case version
    case movementEnabled = "movement_enabled"
    case fleeBehaviorEnabled = "flee_behavior_enabled"
    case difficulty
    case animationIntensity = "animation_intensity"
    case showReactions = "show_reactions"
    case showScorePopups = "show_score_popups"
    case cloneWindowsEnabled = "clone_windows_enabled"
    case maximumCloneWindows = "maximum_clone_windows"
    case soundEffectsEnabled = "sound_effects_enabled"
    case masterVolume = "master_volume"
    case compactMode = "compact_mode"
    case showStatistics = "show_statistics"
    case showPassiveNotifications = "show_passive_notifications"
    case showAchievements = "show_achievements"
    case achievementNotificationsEnabled = "achievement_notifications_enabled"
    case reducedMovement = "reduced_movement"
    case largerButton = "larger_button"
    case slowerButton = "slower_button"
    case highContrast = "high_contrast"
    case appearance
    case lastSaved = "last_saved"
  }
}

public enum DihDifficulty: String, Codable, CaseIterable, Sendable {
  case relaxed = "Relaxed"
  case normal = "Normal"
  case spicy = "Spicy"
}

public actor DihSettingsPersistence {
  private let fileURL: URL
  private let legacyJSONURL: URL

  public init(fileManager: FileManager = .default) {
    let support =
      fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(
        "Library/Application Support")
    self.init(
      fileURL: support.appendingPathComponent("Dih", isDirectory: true).appendingPathComponent(
        "settings.toml"))
  }

  public init(fileURL: URL) {
    self.fileURL =
      fileURL.pathExtension.lowercased() == "toml"
      ? fileURL : fileURL.deletingPathExtension().appendingPathExtension("toml")
    self.legacyJSONURL = self.fileURL.deletingPathExtension().appendingPathExtension("json")
  }

  public func load() -> DihSettingsData {
    if let data = try? Data(contentsOf: fileURL), let text = String(data: data, encoding: .utf8),
      let settings = try? TOMLDecoder().decode(DihSettingsData.self, from: text)
    {
      return migrate(settings)
    }
    if let data = try? Data(contentsOf: legacyJSONURL),
      let settings = try? JSONDecoder().decode(DihSettingsData.self, from: data)
    {
      let migrated = migrate(settings)
      save(migrated)
      try? FileManager.default.removeItem(at: legacyJSONURL)
      return migrated
    }
    return DihSettingsData()
  }

  public func save(_ settings: DihSettingsData) {
    do {
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      let encoder = TOMLEncoder()
      encoder.outputFormatting = .sortedKeys
      let data = try encoder.encode(settings)
      let temporaryURL = fileURL.deletingLastPathComponent().appendingPathComponent(
        ".settings-\(UUID().uuidString).tmp")
      try data.write(to: temporaryURL, options: .atomic)
      if FileManager.default.fileExists(atPath: fileURL.path) {
        _ = try FileManager.default.replaceItemAt(
          fileURL, withItemAt: temporaryURL, backupItemName: nil, options: .usingNewMetadataOnly)
      } else {
        try FileManager.default.moveItem(at: temporaryURL, to: fileURL)
      }
    } catch {
      // Settings are optional; a failed write must not interrupt play.
    }
  }

  private func migrate(_ settings: DihSettingsData) -> DihSettingsData {
    var settings = settings
    if settings.version < 2 {
      settings.version = 2
      settings.soundEffectsEnabled = true
    }
    return settings
  }
}

@MainActor
public final class DihSettings: ObservableObject {
  @Published public private(set) var data = DihSettingsData()
  public let persistence: DihSettingsPersistence

  public init(persistence: DihSettingsPersistence = DihSettingsPersistence()) {
    self.persistence = persistence
    Task { [weak self] in
      guard let self else { return }
      data = await persistence.load()
    }
  }

  public func update<Value>(_ keyPath: WritableKeyPath<DihSettingsData, Value>, _ value: Value) {
    data[keyPath: keyPath] = value
    data.lastSaved = Date()
    let snapshot = data
    Task { await persistence.save(snapshot) }
  }

  public func saveNow() {
    data.lastSaved = Date()
    let snapshot = data
    Task { await persistence.save(snapshot) }
  }
}
