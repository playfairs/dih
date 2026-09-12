import Foundation
import TOML

public actor DihPersistence {
  private let fileURL: URL
  private let legacyJSONURL: URL
  private var latestSavedDate: Date?

  public init(fileManager: FileManager = .default) {
    let applicationSupport =
      fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent(
        "Library/Application Support")
    let directory = applicationSupport.appendingPathComponent("Dih", isDirectory: true)
    self.init(fileURL: directory.appendingPathComponent("save.toml"))
  }

  public init(fileURL: URL) {
    self.fileURL =
      fileURL.pathExtension.lowercased() == "toml"
      ? fileURL : fileURL.deletingPathExtension().appendingPathExtension("toml")
    self.legacyJSONURL = self.fileURL.deletingPathExtension().appendingPathExtension("json")
  }

  public func load() -> DihSaveData {
    if let save = loadTOML() { return save }
    guard !FileManager.default.fileExists(atPath: fileURL.path), let migrated = loadLegacyJSON()
    else {
      return DihSaveData()
    }
    guard writeTOML(migrated) else { return migrated }
    try? FileManager.default.removeItem(at: legacyJSONURL)
    return migrated
  }

  public func save(_ save: DihSaveData, settings: DihSettingsData? = DihSettingsData()) {
    if let latestSavedDate, save.lastSaved < latestSavedDate { return }
    if writeTOML(save, settings: settings) { latestSavedDate = save.lastSaved }
  }

  public func deleteSave() {
    try? FileManager.default.removeItem(at: fileURL)
    try? FileManager.default.removeItem(at: legacyJSONURL)
  }

  public func saveURL() -> URL { fileURL }

  private func loadTOML() -> DihSaveData? {
    guard let data = try? Data(contentsOf: fileURL), let text = String(data: data, encoding: .utf8)
    else { return nil }
    do {
      let document = try TOMLDecoder().decode(DihTOMLSave.self, from: text)
      guard document.version <= DihSaveData.currentVersion else { return nil }
      var save = document.saveData()
      save.version = DihSaveData.currentVersion
      return save
    } catch {
      return nil
    }
  }

  private func loadLegacyJSON() -> DihSaveData? {
    guard let data = try? Data(contentsOf: legacyJSONURL) else { return nil }
    return try? JSONDecoder().decode(DihSaveData.self, from: data)
  }

  private func writeTOML(_ save: DihSaveData, settings: DihSettingsData? = nil) -> Bool {
    do {
      let directory = fileURL.deletingLastPathComponent()
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      let encoder = TOMLEncoder()
      encoder.outputFormatting = .sortedKeys
      let data = try encoder.encode(
        DihTOMLSave(save: save, settings: settings ?? DihSettingsData()))
      let temporaryURL = directory.appendingPathComponent(".save-\(UUID().uuidString).tmp")
      try data.write(to: temporaryURL, options: .atomic)
      if FileManager.default.fileExists(atPath: fileURL.path) {
        _ = try FileManager.default.replaceItemAt(
          fileURL, withItemAt: temporaryURL, backupItemName: nil, options: .usingNewMetadataOnly)
      } else {
        try FileManager.default.moveItem(at: temporaryURL, to: fileURL)
      }
      return true
    } catch {
      return false
    }
  }
}
