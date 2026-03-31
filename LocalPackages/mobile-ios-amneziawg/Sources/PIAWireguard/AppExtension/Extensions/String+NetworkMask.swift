//
//  String+NetworkMask.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 07/02/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

extension String {
    
    func ipAddress() -> String {
        if let subSet = self.split(separator: "/").first {
            return String(subSet)
        }
        return ""
    }
    
    func subnetMask() -> String {
        if let subSet = self.split(separator: "/").last,
            let length = UInt8(String(subSet)) {
            let mask = ipv4SubnetMaskString(length: length)
            return mask
        }
        return ""
    }
    
    private func ipv4SubnetMaskString(length: UInt8) -> String {
        assert(length <= 32)
        var octets: [UInt8] = [0, 0, 0, 0]
        let subnetMask: UInt32 = length > 0 ? ~UInt32(0) << (32 - length) : UInt32(0)
        octets[0] = UInt8(truncatingIfNeeded: subnetMask >> 24)
        octets[1] = UInt8(truncatingIfNeeded: subnetMask >> 16)
        octets[2] = UInt8(truncatingIfNeeded: subnetMask >> 8)
        octets[3] = UInt8(truncatingIfNeeded: subnetMask)
        return octets.map { String($0) }.joined(separator: ".")
    }
}
