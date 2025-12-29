//
//  Pinger.swift
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

protocol Pinger {
    func sendPing() -> Int?
    func setTimeout(_ timeout: Int)
}

class TCPPinger: Pinger {
    private let hostname: String
    private let port: UInt16
    private var timeout: Int = 0

    init(hostname: String, port: UInt16) {
        self.hostname = hostname
        self.port = port
    }

    func setTimeout(_ timeout: Int) {
        self.timeout = timeout
    }

    func sendPing() -> Int? {
        let descriptor = socket(PF_INET, SOCK_STREAM, 0)
        guard descriptor != -1 else {
            return nil
        }

        defer {
            close(descriptor)
        }

        var address = sockaddr_in()
        address.sin_port = port.bigEndian
        address.sin_addr.s_addr = inet_addr(hostname)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)

        let now = Date.timeIntervalSinceReferenceDate

        let result = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                connect(descriptor, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        let responseTime = Int((Date.timeIntervalSinceReferenceDate - now) * 1000.0)

        guard result == 0 else {
            return nil
        }

        return responseTime
    }
}

class UDPPinger: Pinger {
    private let hostname: String
    private let port: UInt16
    private var timeout: Int = 0

    init(hostname: String, port: UInt16) {
        self.hostname = hostname
        self.port = port
    }

    func setTimeout(_ timeout: Int) {
        self.timeout = timeout
    }

    func sendPing() -> Int? {
        let descriptor = socket(PF_INET, SOCK_DGRAM, 0)
        guard descriptor != -1 else {
            return nil
        }

        defer {
            close(descriptor)
        }

        var address = sockaddr_in()
        address.sin_port = port.bigEndian
        address.sin_addr.s_addr = inet_addr(hostname)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)

        // Set timeout if specified
        if timeout > 0 {
            var tv = timeval()
            let usecs = Int(timeout) * 1000
            tv.tv_sec = usecs / 1_000_000
            tv.tv_usec = Int32(usecs % 1_000_000)

            setsockopt(descriptor, SOL_SOCKET, SO_SNDTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
            setsockopt(descriptor, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
        }

        let now = Date.timeIntervalSinceReferenceDate

        // Send dummy byte
        let dummyByte: [UInt8] = [UInt8(ascii: "a")]
        let sendResult = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                sendto(descriptor, dummyByte, dummyByte.count, 0, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard sendResult > 0 else {
            return nil
        }

        // Receive response
        var fromAddress = sockaddr()
        var fromAddressSize = socklen_t(MemoryLayout<sockaddr>.size)
        var received = [UInt8](repeating: 0, count: 1)

        let recvResult = recvfrom(descriptor, &received, 1, 0, &fromAddress, &fromAddressSize)

        let responseTime = Int((Date.timeIntervalSinceReferenceDate - now) * 1000)

        guard recvResult != -1 else {
            return nil
        }

        return responseTime
    }
}
