import Foundation

struct PersistedState: Codable {
    var assets: [Asset]
    var settings: Settings
}

struct PersistenceStore {
    let fileURL: URL
    let crypto: CryptoService

    static var `default`: PersistenceStore {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = base.appendingPathComponent("NetWorth", isDirectory: true)
        let fileURL = directory.appendingPathComponent("assets.dat")
        return PersistenceStore(fileURL: fileURL, crypto: CryptoService())
    }

    func load() throws -> PersistedState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return PersistedState(assets: [], settings: .default)
        }
        let data = try Data(contentsOf: fileURL)
        let decrypted = try crypto.open(data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PersistedState.self, from: decrypted)
    }

    func save(state: PersistedState) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(state)
        let encrypted = try crypto.seal(data)
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try encrypted.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }
}
