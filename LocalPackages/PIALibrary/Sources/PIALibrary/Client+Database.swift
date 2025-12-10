//
//  Client+Database.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
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

@available(tvOS 17.0, *)
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
