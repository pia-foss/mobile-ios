//
//  GlossAccountInfo.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/23/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

class GlossAccountInfo: GlossParser {
    let parsed: AccountInfo
    
    required init?(json: JSON) {
        let email: String? = "email" <~~ json
        let plan: Plan = "plan" <~~ json ?? .other
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
            plan: plan,
            isRenewable: isRenewable,
            isRecurring: isRecurring,
            expirationDate: Date(timeIntervalSince1970: expirationTime),
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
            "plan" ~~> plan.rawValue,
            "renewable" ~~> isRenewable,
            "recurring" ~~> isRecurring,
            "expiration_time" ~~> expirationDate.timeIntervalSince1970,
            "expire_alert" ~~> shouldPresentExpirationAlert,
            "renew_url" ~~> renewUrl
        ])
    }
}
