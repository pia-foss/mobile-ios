//
//  RenewRequest.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// A renew request.
///
/// - Seealso: `AccountProvider.renew(...)`
public struct RenewRequest {

    /// The purchased transaction.
    public let transaction: InAppTransaction?
    
    /// A map of objects attached to the signup request for marketing purposes.
    public let marketing: [String: Any]?
    
    /// :nodoc:
    public init(transaction: InAppTransaction?, marketing: [String: Any]? = nil) {
        self.transaction = transaction
        self.marketing = marketing
    }
}
