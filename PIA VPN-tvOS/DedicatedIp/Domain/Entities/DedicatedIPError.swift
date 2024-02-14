//
//  DedicatedIPError.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum DedicatedIPError: Error {
    case expired
    case invalid
    case generic(Error?)
}
