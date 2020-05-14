//
//  Macros+Pinger.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/12/17.
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
import __PIALibraryNative

/// The IP protocol over which to issue the ping.
public enum PingerProtocol {

    /// Over TCP.
    case TCP

    /// Over UDP.
    case UDP

}

extension Macros {

    /**
     Pings a VPN server by sending a dummy packet via a socket. The call is I/O blocking.
     
     - Parameter protocolType: The `PingerProtocol` to use.
     - Parameter hostname: The server hostname.
     - Parameter port: The server port.
     - Parameter timeout: The timeout in milliseconds.
     - Returns: The elapsed interval in milliseconds or `nil` if the endpoint is unreachable within the specified timeout.
     */
    public static func ping(withProtocol protocolType: PingerProtocol, hostname: String, port: UInt16, timeout: Int? = 3000) -> Int? {
        let pinger: Pinger
        switch protocolType {
        case .TCP:
            pinger = TCPPinger(hostname: hostname, port: port)
        case .UDP:
            pinger = UDPPinger(hostname: hostname, port: port)
        }

        if let timeout = timeout {
            pinger.setTimeout(timeout)
        }
        return pinger.sendPing() as? Int
    }
    
}
