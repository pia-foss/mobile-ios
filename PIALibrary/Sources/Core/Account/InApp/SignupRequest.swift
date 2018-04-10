//
//  SignupRequest.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// A signup request.
///
/// - Seealso: `AccountProvider.signup(...)`
public struct SignupRequest {

    /// The email address to sign up with.
    public let email: String
    
    /// The purchased transaction.
    public let transaction: InAppTransaction?
    
    /// A map of objects attached to the signup request for marketing purposes.
    public let marketing: [String: Any]?

    /// :nodoc:
    public init(email: String, transaction: InAppTransaction? = nil, marketing: [String: Any]? = nil) {
        self.email = email
        self.transaction = transaction
        self.marketing = marketing
    }
}
