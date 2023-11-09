//
//  DNSResolver.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/15/17.
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

class DNSResolver {
    private let hostname: String
    
    init(hostname: String) {
        self.hostname = hostname
    }

    func resolve(completionHandler: ([String]?, Error?) -> Void) {
        let host = CFHostCreateWithName(nil, hostname as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)

        var success: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? else {
            completionHandler(nil, nil)
            return
        }
        var ipAddresses: [String] = []
        for case let theAddress as NSData in addresses {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            guard getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                continue
            }
            ipAddresses.append(String(cString: hostname))
        }
        completionHandler(ipAddresses, nil)
    }

    static func string(fromIPv4 ipv4: UInt32) -> String {
        let a = UInt8(ipv4) & 0xff
        let b = UInt8(ipv4 >> 8) & 0xff
        let c = UInt8(ipv4 >> 16) & 0xff
        let d = UInt8(ipv4 >> 24) & 0xff

        return "\(a).\(b).\(c).\(d)"
    }
}
