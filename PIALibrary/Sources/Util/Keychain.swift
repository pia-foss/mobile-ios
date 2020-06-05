//
//  Keychain.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 2/12/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

/// Handled keychain errors.
public enum KeychainError: Error {

    /// Couldn't add entry.
    case add
    
    /// Couldn't find entry.
    case notFound
    
//    /// Returned entry has an unexpected type.
//    case typeMismatch
}

/// Encapsulates Apple keychain operations.
public class Keychain {
    private let service: String?

    private let accessGroup: String?
    
    private let usernameKey = "USERNAME_KEY"
    private let publicUsernameKey = "PUBLIC_USERNAME_KEY"

    /**
     Default initializer. Uses the default keychain associated with the main bundle identifier.
     */
    public init() {
        service = Bundle.main.bundleIdentifier
        accessGroup = nil
    }

    /**
     Uses the keychain associated with an app group. Requires proper entitlements.

     - Parameter group: The app group.
     */
    public init(group: String) {
        service = nil
        accessGroup = group
    }
    
    /**
     Uses the keychain associated with an app group and a team prefix. Requires proper entitlements.

     - Parameter team: The team ID.
     - Parameter group: The app group.
     */
    public init(team: String, group: String) {
        service = nil
        accessGroup = "\(team).\(group)"
    }
    
    // MARK: Password
    
    /// :nodoc:
    public func set(password: String, for username: String) throws {
        removePassword(for: username)
        
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData as String] = password.data(using: .utf8)
    
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else {
            throw KeychainError.add
        }
    }
    
    /// :nodoc:
    @discardableResult public func removePassword(for username: String) -> Bool {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        
        let status = SecItemDelete(query as CFDictionary)
        return (status == errSecSuccess)
    }

    /// :nodoc:
    public func password(for username: String) throws -> String {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        //query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return password
    }

    /// :nodoc:
    public func passwordReference(for username: String) throws -> Data {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        setScope(query: &query)
        query[kSecAttrAccount as String] = username
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnPersistentRef as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        return data
    }
    
    /// :nodoc:
    public static func password(for username: String, reference: Data) throws -> String {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        query[kSecMatchItemList as String] = [reference]
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return password
    }
    
    // MARK: Helpers
    
    private func setScope(query: inout [String: Any]) {
        if let service = service {
            query[kSecAttrService as String] = service
        } else if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        } else {
            fatalError("No service nor accessGroup set")
        }
    }
}

extension Keychain {
    
    // MARK: Username
    
    /// :nodoc:
    public func set(username: String) throws {
        removeUsername()
        
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = usernameKey
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData as String] = username.data(using: .utf8)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else {
            throw KeychainError.add
        }
    }
    
    /// :nodoc:
    @discardableResult public func removeUsername() -> Bool {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = usernameKey
        
        let status = SecItemDelete(query as CFDictionary)
        return (status == errSecSuccess)
    }
    
    /// :nodoc:
    public func username() throws -> String {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = usernameKey
        //query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return token
    }

}

extension Keychain {
    
    // MARK: Public Username
    
    /// :nodoc:
    public func set(publicUsername: String) throws {
        removePublicUsername()
        
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = publicUsernameKey
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData as String] = publicUsername.data(using: .utf8)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else {
            throw KeychainError.add
        }
    }
    
    /// :nodoc:
    @discardableResult public func removePublicUsername() -> Bool {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = publicUsernameKey
        
        let status = SecItemDelete(query as CFDictionary)
        return (status == errSecSuccess)
    }
    
    /// :nodoc:
    public func publicUsername() throws -> String {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = publicUsernameKey
        //query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return token
    }
    
}

extension Keychain {
    
    // MARK: Token
    
    /// :nodoc:
    public func set(token: String, for username: String) throws {
        removeToken(for: username)
        
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecValueData as String] = token.data(using: .utf8)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard (status == errSecSuccess) else {
            throw KeychainError.add
        }
    }
    
    /// :nodoc:
    @discardableResult public func removeToken(for username: String) -> Bool {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        
        let status = SecItemDelete(query as CFDictionary)
        return (status == errSecSuccess)
    }
    
    /// :nodoc:
    public func token(for username: String) throws -> String {
        var query = [String: Any]()
        setScope(query: &query)
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        //query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return token
    }
    
    /// :nodoc:
    public func tokenReference(for username: String) throws -> Data {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        setScope(query: &query)
        query[kSecAttrAccount as String] = username
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnPersistentRef as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        return data
    }
    
    /// :nodoc:
    public static func token(for username: String, reference: Data) throws -> String {
        var query = [String: Any]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccount as String] = username
        query[kSecMatchItemList as String] = [reference]
        query[kSecReturnData as String] = true
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard (status == errSecSuccess) else {
            throw KeychainError.notFound
        }
        guard let data = result as? Data else {
            throw KeychainError.notFound
        }
        guard let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.notFound
        }
        return password
    }

}
