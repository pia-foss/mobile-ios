//
//  KeychainStore.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

class KeychainStore: SecureStore {
    private struct Entries {
        static let publicKey = "PIAPublicKey"
    }
    
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

    var publicKey: SecKey?
    
    func setPublicKey(withData data: Data) -> SecKey? {
        backend.remove(publicKeyWithIdentifier: Entries.publicKey)
        guard let publicKey = try? backend.add(publicKeyWithIdentifier: Entries.publicKey, data: data) else {
            return nil
        }
        self.publicKey = publicKey
        return publicKey
    }
    
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
        backend.remove(publicKeyWithIdentifier: Entries.publicKey)
    }
}
