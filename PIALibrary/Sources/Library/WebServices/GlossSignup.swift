//
//  Signup+Gloss.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

extension Signup: JSONEncodable {
    func toJSON() -> JSON? {
        return jsonify([
            "email" ~~> email,
            "receipt" ~~> receipt.base64EncodedString(),
            "marketing" ~~> marketing,
            "debug" ~~> debug,
            "store" ~~> "apple_app_store"
        ])
    }
}
