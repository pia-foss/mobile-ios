//
//  GlossRedeem.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 5/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

extension Redeem: JSONEncodable {
    func toJSON() -> JSON? {
        return jsonify([
            "email" ~~> email,
            "pin" ~~> code
        ])
    }
}
