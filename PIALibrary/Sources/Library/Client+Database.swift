//
//  Client+Database.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

extension Client {

    /**
     The persistence layer of the client, stores consumer preferences via
     underlying `UserDefaults` and keychain stores.
     */
    public final class Database {
        let plain: PlainStore
        
        let secure: SecureStore

        private(set) var transient: TransientStore = MemoryStore()
        
        /**
         Default initializer, uses `UserDefaults.standard` and the main keychain.
         */
        public init() {
            plain = UserDefaultsStore()
            secure = KeychainStore()
        }
        
        /**
         Raw group initializer, uses an app group for both `UserDefaults` and the keychain.
         
         - Parameter group: An app group
         */
        public init(group: String) {
            plain = UserDefaultsStore(group: group)
            secure = KeychainStore(group: group)
        }

        /**
         Team group initializer, uses an app group for `UserDefaults`. The keychain uses
         the same app group prefixed with the team ID.
         
         - Parameter team: The development team ID
         - Parameter group: An app group
         */
        public init(team: String, group: String) {
            plain = UserDefaultsStore(group: group)
            secure = KeychainStore(team: team, group: group)
        }

        /**
         Resets the persistency layer completely.
         
         - Returns: `self`
         */
        @discardableResult public func truncate() -> Self {
            plain.clear()
            transient = MemoryStore()
            return self
        }
    }
}
