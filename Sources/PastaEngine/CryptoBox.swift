import Foundation
import CryptoKit
import Security

/// Manages the symmetric key used to encrypt history at rest. The key is generated once
/// and stored in the login Keychain; subsequent runs reuse it. See specs/04-persistence.
public final class CryptoBox {
    public enum CryptoError: Error { case keyUnavailable, sealFailed, openFailed }

    private let service: String
    private let account: String
    private var cachedKey: SymmetricKey?

    public init(service: String = "com.pasta.history-key", account: String = "default") {
        self.service = service
        self.account = account
    }

    // MARK: - Seal / open

    public func seal(_ plaintext: Data) throws -> Data {
        let key = try key()
        let box = try AES.GCM.seal(plaintext, using: key)
        guard let combined = box.combined else { throw CryptoError.sealFailed }
        return combined
    }

    public func open(_ ciphertext: Data) throws -> Data {
        let key = try key()
        let box = try AES.GCM.SealedBox(combined: ciphertext)
        return try AES.GCM.open(box, using: key)
    }

    // MARK: - Key management

    private func key() throws -> SymmetricKey {
        if let cached = cachedKey { return cached }
        if let existing = try loadKey() {
            cachedKey = existing
            return existing
        }
        let fresh = SymmetricKey(size: .bits256)
        try storeKey(fresh)
        cachedKey = fresh
        return fresh
    }

    private func loadKey() throws -> SymmetricKey? {
        var query: [String: Any] = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { return nil }
            return SymmetricKey(data: data)
        case errSecItemNotFound:
            return nil
        default:
            throw CryptoError.keyUnavailable
        }
    }

    private func storeKey(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        var attributes: [String: Any] = baseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        // Remove any stale item, then add fresh.
        SecItemDelete(baseQuery() as CFDictionary)
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoError.keyUnavailable }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
