//
//  SecureStore.swift
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

protocol SecureStore: class {
    
    func username() -> String?
    
    func setUsername(_ username: String?)
    
    func publicUsername() -> String?
    
    func setPublicUsername(_ username: String?)
    
    func password(for username: String) -> String?

    func setPassword(_ password: String?, for username: String)

    func passwordReference(for username: String) -> Data?

    func token(for username: String) -> String?

    func clearToken(for username: String)
    
    func tokenKey(for username: String) -> String

    func dipTokens() -> [String]?
    
    func setDIPToken(_ dipToken: String)
    
    func remove(_ dipToken: String)

    func removeDIPTokens()

    func setPassword(_ password: String?, forDipToken dip: String)
    
    func passwordReference(forDipToken dip: String) -> Data?
    
    func clear(for username: String)
}
