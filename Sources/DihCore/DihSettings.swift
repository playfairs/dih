import Foundation
import Combine

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
    public var reducedMovement = false
    public var largerButton = false
    public var slowerButton = false
    public var highContrast = false
    public var lastSaved = Date()
}

public enum DihDifficulty: String, Codable, CaseIterable, Sendable {
    case relaxed = "Relaxed"
    case normal = "Normal"
    case spicy = "Spicy"
}

public actor DihSettingsPersistence {
    private let fileURL: URL

    public init(fileManager: FileManager = .default) {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        self.fileURL = support.appendingPathComponent("Dih", isDirectory: true).appendingPathComponent("settings.json")
    }

    public init(fileURL: URL) { self.fileURL = fileURL }

    public func load() -> DihSettingsData {
        guard let data = try? Data(contentsOf: fileURL), var settings = try? JSONDecoder().decode(DihSettingsData.self, from: data) else {
            return DihSettingsData()
        }
        if settings.version < 2 {
            settings.version = 2
            settings.soundEffectsEnabled = true
        }
        return settings
    }

    public func save(_ settings: DihSettingsData) {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(settings).write(to: fileURL, options: .atomic)
        } catch {
            // Settings are optional; a failed write must not interrupt play.
        }
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