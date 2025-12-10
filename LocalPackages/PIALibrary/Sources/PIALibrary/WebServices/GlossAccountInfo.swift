//
//  GlossAccountInfo.swift
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

class GlossAccountInfo: GlossParser {
    let parsed: AccountInfo
    
    required init?(json: JSON) {
        let email: String? = "email" <~~ json
        let username: String = "username" <~~ json ?? ""
        let productId: String? = "product_id" <~~ json
        let plan: Plan = "plan" <~~ json ?? .other
        let canInvite: Bool = "can_invite" <~~ json ?? false
        
        guard let isRenewable: Bool = "renewable" <~~ json else {
            return nil
        }
        guard let isRecurring: Bool = "recurring" <~~ json else {
            return nil
        }
        
        guard let expirationTime: TimeInterval = "expiration_time" <~~ json else {
            return nil
        }
        guard let shouldPresentExpirationAlert: Bool = "expire_alert" <~~ json else {
            return nil
        }
        var renewUrl: URL?
        if let renewUrlString: String = "renew_url" <~~ json {
            renewUrl = URL(string: renewUrlString)
        }

        parsed = AccountInfo(
            email: email,
            username: username,
            plan: plan,
            productId: productId,
            isRenewable: isRenewable,
            isRecurring: isRecurring,
            expirationDate: Date(timeIntervalSince1970: expirationTime),
            canInvite: canInvite,
            shouldPresentExpirationAlert: shouldPresentExpirationAlert,
            renewUrl: renewUrl
        )
    }
}

/// :nodoc:
extension AccountInfo: JSONEncodable {
    public func toJSON() -> JSON? {
        return jsonify([
            "email" ~~> email,
            "username" ~~> username,
            "product_id" ~~> productId,
            "plan" ~~> plan.rawValue,
            "renewable" ~~> isRenewable,
            "can_invite" ~~> canInvite,
            "recurring" ~~> isRecurring,
            "expiration_time" ~~> expirationDate.timeIntervalSince1970,
            "expire_alert" ~~> shouldPresentExpirationAlert,
            "renew_url" ~~> renewUrl
        ])
    }
}
