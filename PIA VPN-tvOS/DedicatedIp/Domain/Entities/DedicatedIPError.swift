//
//  DedicatedIPError.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum DedicatedIPError: Error {
    /// Token is expired.
    case expired
    /// Token is invalid.
    case invalid
    /// A Dedicated IP is already activated.
    case alreadyHasOne
    /// Other.
    case generic(Error?)
}
