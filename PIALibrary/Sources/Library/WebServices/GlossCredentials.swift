//
//  Credentials+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
