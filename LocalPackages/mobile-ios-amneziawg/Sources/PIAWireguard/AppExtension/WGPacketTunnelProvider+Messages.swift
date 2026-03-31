//
//  WGPacketTunnelProvider+Messages.swift
//  PIAWireguard
//  
//  Created by Jose Antonio Blaya Garcia on 14/02/2020.
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

extension WGPacketTunnelProvider {

    /// The messages accepted by `WGPacketTunnelProvider`.
    public class Message: Equatable {

        /// Requests a snapshot of the latest debug log. Returns the log data decoded from UTF-8.
        public static let requestLog = Message(0xff)
        
        /// Requests the current bytes count from data channel (if connected).
        ///
        /// Data is 16 bytes: low 8 = received, high 8 = sent.
        public static let dataCount = Message(0xfe)
        
        /// The underlying raw message `Data` to forward to the tunnel via IPC.
        public let data: Data
        
        private init(_ byte: UInt8) {
            data = Data([byte])
        }
        
        init(_ data: Data) {
            self.data = data
        }
        
        // MARK: Equatable

        /// :nodoc:
        public static func ==(lhs: Message, rhs: Message) -> Bool {
            return (lhs.data == rhs.data)
        }
        
    }

}
