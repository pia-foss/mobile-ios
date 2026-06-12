//
//  PIATunnelProvider+Profile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 1/11/18.
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
#if os(iOS)
    import Foundation
    import TunnelKitOpenVPN

    /// :nodoc:
    extension OpenVPN.ProviderConfiguration: VPNCustomConfiguration {
        public func serialized() -> [String: Any] {
            // Mirrors TunnelKit's `Encodable.asDictionary()` so the dictionary stored
            // in `NETunnelProviderProtocol.providerConfiguration` round-trips through
            // the tunnel's `fromDictionary(OpenVPN.ProviderConfiguration.self, …)`.
            guard let data = try? JSONEncoder().encode(self),
                let dictionary = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
            else {
                return [:]
            }
            return dictionary
        }

        public func isEqual(to: VPNCustomConfiguration) -> Bool {
            guard let other = to as? OpenVPN.ProviderConfiguration else {
                return false
            }
            guard shouldDebug == other.shouldDebug else {
                return false
            }
            // `OpenVPN.Configuration` is `Equatable`; this also covers `mtu`.
            return configuration == other.configuration
        }
    }
#endif
