//
//  DedicatedIPError.swift
//  PIADedicatedIP
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

public enum DedicatedIPError: Error {
    /// Token is expired.
    case expired
    /// Token is invalid.
    case invalid
    /// A Dedicated IP is already activated.
    case alreadyHasOne
    /// Other.
    case generic(Error?)
}

public enum RemoveDedicatedIPError: Error {
    /// No current Dedicated IP activated.
    case doesntHaveOne
    /// Failed to disconnect from the VPN.
    case disconect(Error)
    /// Failed to remove Dedicated IP from favorites.
    case favorite(Error)
}
