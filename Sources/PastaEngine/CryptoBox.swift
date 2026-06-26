import Foundation
import CryptoKit
import Security

/// Stores/loads the symmetric key. Injectable so tests don't depend on a login Keychain.
public protocol KeyStoring {
    func loadKey() throws -> SymmetricKey?
    func storeKey(_ key: SymmetricKey) throws
}

/// Manages the symmetric key used to encrypt history at rest. The key is generated once and
/// stored via the injected `KeyStoring` (Keychain in the app); subsequent runs reuse it.
/// See specs/04-persistence.
public final class CryptoBox {
    public enum CryptoError: Error { case keyUnavailable, sealFailed, openFailed }

    private let keyStore: KeyStoring
    private var cachedKey: SymmetricKey?

    public init(keyStore: KeyStoring) {
        self.keyStore = keyStore
    }

    /// App default: key lives in the login Keychain.
    public convenience init(service: String = "com.pasta.history-key", account: String = "default") {
        self.init(keyStore: KeychainKeyStore(service: service, account: account))
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
        if let existing = try keyStore.loadKey() {
            cachedKey = existing
            return existing
        }
        let fresh = SymmetricKey(size: .bits256)
        try keyStore.storeKey(fresh)
        cachedKey = fresh
        return fresh
    }
}

/// Keychain-backed key storage (the app default).
public final class KeychainKeyStore: KeyStoring {
    private let service: String
    private let account: String

    public init(service: String = "com.pasta.history-key", account: String = "default") {
        self.service = service
        self.account = account
    }

    public func loadKey() throws -> SymmetricKey? {
        var query = baseQuery()
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
            throw CryptoBox.CryptoError.keyUnavailable
        }
    }

    public func storeKey(_ key: SymmetricKey) throws {
        let data = key.withUnsafeBytes { Data($0) }
        var attributes = baseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        SecItemDelete(baseQuery() as CFDictionary)
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoBox.CryptoError.keyUnavailable }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

/// In-memory key storage for tests (no Keychain dependency). Persists a fresh key for the
/// lifetime of the instance.
public final class InMemoryKeyStore: KeyStoring {
    private var key: SymmetricKey?
    public init() {}
    public func loadKey() throws -> SymmetricKey? { key }
    public func storeKey(_ key: SymmetricKey) throws { self.key = key }
}
