//
//  Credentials+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
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
import Gloss

class GlossCredentials: GlossParser {
    let parsed: Credentials
    
    required init?(json: JSON) {
        guard let username: String = "username" <~~ json else {
            return nil
        }
        guard let password: String = "password" <~~ json else {
            return nil
        }
        parsed = Credentials(username: username, password: password)
    }
}

/// :nodoc:
extension Credentials: JSONEncodable {
    public func toJSON() -> JSON? {
        return [
            "username": username,
            "password": password
        ]
    }
}
