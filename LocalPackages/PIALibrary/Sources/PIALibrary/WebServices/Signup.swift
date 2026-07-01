//
//  Signup.swift
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
import PIABase

public struct Signup {
    let email: String

    /// The signed JWS transaction sent to the backend as `receipt`.
    let receipt: JWS

    var marketing: [String: Any]?

    var debug: [String: Any]?

    init(email: String, receipt: JWS) {
        self.email = email
        self.receipt = receipt
    }
}

private let log = PIALogger.logger(for: SignupRequest.self)

#if os(iOS) || os(tvOS)
    extension SignupRequest {
        func signup(withStore store: InAppProvider) async -> Signup? {
            // Prefer the JWS of the freshly purchased transaction; otherwise fall back to
            // the newest active entitlement (e.g. signing up after a restore).
            let jws: JWS?
            if let transaction {
                jws = transaction.jwsRepresentation
            } else {
                jws = await store.currentEntitlementJWS()
            }

            guard let jws else { return nil }
            var object = Signup(email: email, receipt: jws)
            object.marketing = marketing
            if let txid = transaction?.identifier {
                object.debug = ["txid": txid]
            }
            return object
        }
    }
#endif
