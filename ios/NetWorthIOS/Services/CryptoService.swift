import Foundation
import CryptoKit

enum CryptoError: Error {
    case sealFailed
}

struct CryptoService {
    private let keychain = KeychainService()

    func seal(_ data: Data) throws -> Data {
        let key = try keychain.getKey()
        let sealed = try AES.GCM.seal(data, using: key)
        guard let combined = sealed.combined else {
            throw CryptoError.sealFailed
        }
        return combined
    }

    func open(_ data: Data) throws -> Data {
        let key = try keychain.getKey()
        let box = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(box, using: key)
    }
}
