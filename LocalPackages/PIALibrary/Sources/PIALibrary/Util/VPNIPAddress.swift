//
//  VPNIPAddress.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 29/12/25.
//  Copyright © 2025 Private Internet Access, Inc.
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

/// Gets the VPN IP address by examining network interfaces.
/// - Returns: The IP address string if a VPN interface is found, nil otherwise.
/// - Note: This method always returns a string no matter if the VPN is connected or not
func VPNIPAddressFromInterfaces() -> String? {
    var ifaddrs: UnsafeMutablePointer<ifaddrs>?

    guard getifaddrs(&ifaddrs) == 0 else {
        return nil
    }

    defer {
        freeifaddrs(ifaddrs)
    }

    var vpnIPAddress: String?
    var currentAddr = ifaddrs

    while let addr = currentAddr {
        defer {
            currentAddr = addr.pointee.ifa_next
        }

        guard let sockaddr = addr.pointee.ifa_addr else {
            continue
        }

        // Only process IPv4 addresses
        guard sockaddr.pointee.sa_family == AF_INET else {
            continue
        }

        guard let ifName = String(validatingUTF8: addr.pointee.ifa_name) else {
            continue
        }

        // Convert sockaddr to sockaddr_in to get IP address
        let sockaddrIn = sockaddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }

        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        var inAddr = sockaddrIn.sin_addr

        guard inet_ntop(AF_INET, &inAddr, &buffer, socklen_t(INET_ADDRSTRLEN)) != nil else {
            continue
        }

        guard let ifIPAddress = String(validatingUTF8: buffer) else {
            continue
        }

        // Check if this is a VPN interface
        if ifName.hasPrefix("utun") || ifName.hasPrefix("ppp") || ifName.hasPrefix("ipsec0") {
            vpnIPAddress = ifIPAddress
        }
    }

    return vpnIPAddress
}
