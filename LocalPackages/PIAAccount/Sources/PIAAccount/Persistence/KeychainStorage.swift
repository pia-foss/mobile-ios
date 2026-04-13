import Foundation
import Security

/// Thread-safe wrapper for iOS Keychain storage
final class KeychainStorage: Sendable {
    private let service: String

    /// Creates a new Keychain storage instance
    /// - Parameter service: The service identifier for Keychain items
    init(service: String) {
        self.service = service
    }

    // MARK: - Public Methods

    /// Stores data in the Keychain
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The key to associate with the data
    /// - Throws: PIAAccountError if the operation fails
    func set(_ data: Data, forKey key: String) throws {
        let query = buildQuery(forKey: key)

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        // Add the new item
        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw PIAAccountError.keychainError(
                "Failed to store data in Keychain",
                osStatus: status
            )
        }
    }

    /// Retrieves data from the Keychain
    /// - Parameter key: The key associated with the data
    /// - Returns: The stored data, or nil if not found
    /// - Throws: PIAAccountError if the operation fails (except for not found)
    func get(forKey key: String) throws -> Data? {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw PIAAccountError.keychainError(
                "Failed to read data from Keychain",
                osStatus: status
            )
        }
    }

    /// Deletes data from the Keychain
    /// - Parameter key: The key associated with the data to delete
    /// - Throws: PIAAccountError if the operation fails (except for not found)
    func delete(forKey key: String) throws {
        let query = buildQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PIAAccountError.keychainError(
                "Failed to delete data from Keychain",
                osStatus: status
            )
        }
    }

    /// Checks if a key exists in the Keychain
    /// - Parameter key: The key to check
    /// - Returns: true if the key exists, false otherwise
    /// - Throws: PIAAccountError if the operation fails
    func exists(forKey key: String) throws -> Bool {
        var query = buildQuery(forKey: key)
        query[kSecReturnData as String] = false
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw PIAAccountError.keychainError(
                "Failed to check Keychain item existence",
                osStatus: status
            )
        }
    }

    /// Clears all items for this service from the Keychain
    /// - Throws: PIAAccountError if the operation fails
    func clearAll() throws {
        // On macOS, SecItemDelete with just service doesn't reliably delete all items
        // We need to use kSecMatchLimitAll to ensure all items are deleted
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PIAAccountError.keychainError(
                "Failed to clear Keychain",
                osStatus: status
            )
        }
    }

    // MARK: - Private Helpers

    private func buildQuery(forKey key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}

// MARK: - Convenience Extensions

extension KeychainStorage {
    /// Stores a Codable object in the Keychain
    /// - Parameters:
    ///   - object: The object to store
    ///   - key: The key to associate with the object
    ///   - encoder: The JSON encoder to use (defaults to JSONEncoder)
    /// - Throws: PIAAccountError if encoding or storage fails
    func set<T: Encodable>(_ object: T, forKey key: String, encoder: JSONEncoder = .init()) throws {
        do {
            let data = try encoder.encode(object)
            try set(data, forKey: key)
        } catch let error as PIAAccountError {
            throw error
        } catch {
            throw PIAAccountError.encodingFailed(error)
        }
    }

    /// Retrieves a Codable object from the Keychain
    /// - Parameters:
    ///   - type: The type of object to retrieve
    ///   - key: The key associated with the object
    ///   - decoder: The JSON decoder to use (defaults to JSONDecoder)
    /// - Returns: The decoded object, or nil if not found
    /// - Throws: PIAAccountError if retrieval or decoding fails
    func get<T: Decodable>(_ type: T.Type, forKey key: String, decoder: JSONDecoder = .init()) throws -> T? {
        guard let data = try get(forKey: key) else {
            return nil
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw PIAAccountError.decodingFailed(error)
        }
    }
}
