//
//  Credentials.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// The account credentials.
public struct Credentials {

    /// The username, typically a number prefixed with "p".
    public let username: String
    
    /// The password.
    public let password: String
    
    /// :nodoc:
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
