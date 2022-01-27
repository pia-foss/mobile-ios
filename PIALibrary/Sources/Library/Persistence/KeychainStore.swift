//
//  KeychainStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
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

class KeychainStore: SecureStore {
    
    private let backend: Keychain

    init() {
        backend = Keychain()
    }

    init(group: String) {
        backend = Keychain(group: group)
    }
    
    init(team: String, group: String) {
        backend = Keychain(team: team, group: group)
    }

    // MARK: SecureStore
    
    func password(for username: String) -> String? {
        return try? backend.password(for: username)
    }

    func setPassword(_ password: String?, for username: String) {
        if let password = password {
            try? backend.set(password: password, for: username)
        } else {
            backend.removePassword(for: username)
        }
    }
    
    func passwordReference(for username: String) -> Data? {
        return try? backend.passwordReference(for: username)
    }
    
    func clear(for username: String) {
        backend.removePassword(for: username)
        backend.removeToken(for: tokenKey(for: username))
    }
}

extension KeychainStore {
    
    func username() -> String? {
        return try? backend.username()
    }
    
    func setUsername(_ username: String?) {
        if let username = username {
            try? backend.set(username: username)
        } else {
            backend.removeUsername()
        }
    }
}

extension KeychainStore {
    
    func publicUsername() -> String? {
        return try? backend.publicUsername()
    }
    
    func setPublicUsername(_ username: String?) {
        if let username = username {
            try? backend.set(publicUsername: username)
        } else {
            backend.removePublicUsername()
        }
    }
}

extension KeychainStore {
    
    func token(for username: String) -> String? {
        return try? backend.token(for: username)
    }

    func clearToken(for username: String) {
        backend.removeToken(for: username)
    }
    
    func tokenKey(for username: String) -> String {
        return "auth-token: \(username)"
    }

}

extension KeychainStore {
    
    func dipTokens() -> [String]? {
        return try? backend.dipTokens()
    }
    
    func setDIPToken(_ dipToken: String) {
        try? backend.set(dipToken: dipToken)
    }
    
    func remove(_ dipToken: String) {
        try? backend.remove(dipToken: dipToken)
    }
    
    func removeDIPTokens() {
        try? backend.removeDIPTokens()
    }
    
    func setPassword(_ password: String?, forDipToken dip: String) {
        if let password = password {
            try? backend.set(password: password, for: dip)
        } else {
            backend.removePassword(for: dip)
        }
    }
    
    func passwordReference(forDipToken dip: String) -> Data? {
        return try? backend.passwordReference(for: dip)
    }
}
