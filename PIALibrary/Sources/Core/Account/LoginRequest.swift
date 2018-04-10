//
//  LoginRequest.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// A login request.
///
/// - Seealso: `AccountProvider.login(...)`
public struct LoginRequest {

    /// The `Credentials` to log in with.
    public let credentials: Credentials
    
    /// :nodoc:
    public init(credentials: Credentials) {
        self.credentials = credentials
    }
}
