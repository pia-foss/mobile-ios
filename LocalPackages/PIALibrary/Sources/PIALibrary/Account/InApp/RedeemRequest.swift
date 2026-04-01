//
//  RedeemRequest.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 5/8/18.
//

import Foundation

/// A redeem request.
///
/// - Seealso: `AccountProvider.redeem(...)`
public struct RedeemRequest {
    
    /// The email address to sign up with.
    public let email: String
    
    /// The code to redeem.
    public let code: String
    
    /// :nodoc:
    public init(email: String, code: String) {
        self.email = email
        self.code = code
    }
}
