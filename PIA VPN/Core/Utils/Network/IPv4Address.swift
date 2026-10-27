//
//  IPv4Address.swift
//  PIA VPN
//
//  Created by Said Rehouni on 11/8/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Network

extension IPv4Address: Comparable {
    /// Comparison is done by converting Ipaddress to Integer
    public static func < (lhs: IPv4Address, rhs: IPv4Address) -> Bool {
        let lhsIntValue = representAsInteger(ipAddress: lhs)
        let rhsIntValue = representAsInteger(ipAddress: rhs)
        return lhsIntValue < rhsIntValue
    }

    /// Converts IPAddress as integer values. Loops over each address section, shifts them and accumulate the result.
    /// - Parameter ipAddress: IPAddress for conversion
    /// - Returns: Integer representation
    static func representAsInteger(ipAddress: IPv4Address) -> Int {
        var result: Int = 0
        let octets = ipAddress.octets
        for i in stride(from: 3, through: 0, by: -1) {
            result += octets[3 - i] << (i * 8)
        }
        return result
    }

    // IPAddress as an Integer array
    var octets: [Int] {
        return self.rawValue.map { Int($0) }
    }
}

extension IPv4Address: ExpressibleByStringLiteral {
    /// Initialize from a Static String
    /// Intentionally crashes when value is a bad IPaddresses
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)!
    }
}
