//
//  UpdateAccountRequest.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// An account update request.
///
/// - Seealso: `AccountProvider.update(...)`
public struct UpdateAccountRequest {

    /// The new email address.
    public let email: String
    
    /// :nodoc:
    public init(email: String) {
        self.email = email
    }
}
