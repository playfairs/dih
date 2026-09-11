import Foundation

public actor DihPersistence {
    private let fileURL: URL

    public init(fileManager: FileManager = .default) {
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        let directory = applicationSupport.appendingPathComponent("Dih", isDirectory: true)
        self.init(fileURL: directory.appendingPathComponent("save.json"))
    }

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() -> DihSaveData {
        do {
            let data = try Data(contentsOf: fileURL)
            var save = try JSONDecoder().decode(DihSaveData.self, from: data)
            save.version = DihSaveData.currentVersion
            return save
        } catch {
            return DihSaveData()
        }
    }

    public func save(_ save: DihSaveData) {
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(save)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // a failed save should never make the game unplayable :3
        }
    }

    public func deleteSave() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}