//
//  OpenVPNProvider+Compat.swift
//  PIALibrary
//
//  Copyright © 2026 Private Internet Access, Inc.
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
    import TunnelKitCore
    import TunnelKitOpenVPN

    // Backward-compatibility shims bridging PIA's existing OpenVPN integration
    // (written against the legacy `mobile-ios-openvpn` fork) onto the Kape TunnelKit
    // fork. Two breaking changes are bridged here so the app target needs minimal
    // churn:
    //
    //  1. `OpenVPNProvider.Configuration` became `OpenVPN.ProviderConfiguration`,
    //     which now *wraps* a separate `OpenVPN.Configuration` instead of merging
    //     provider- and session-level fields.
    //  2. The `endpointProtocols` (protocol + port, no address) / `resolvedAddresses`
    //     split was removed in favour of `remotes: [Endpoint]` (address + protocol).

    /// Legacy namespace mirror for `OpenVPNProvider.*` references throughout the app.
    public enum OpenVPNProvider {

        /// The provider configuration type (a distinct type in the old fork).
        public typealias Configuration = OpenVPN.ProviderConfiguration

        /// Title stored on the generated provider configuration (informational only).
        static let title = "PIA"

        /// Mutable builder mirroring the old `OpenVPNProvider.ConfigurationBuilder`,
        /// which wrapped a mutable session configuration plus provider-level flags.
        public struct ConfigurationBuilder {

            /// The mutable session configuration. Exposed as a builder so existing
            /// callers can keep mutating `mtu`, `endpointProtocols`, etc.
            public var sessionConfiguration: OpenVPN.ConfigurationBuilder

            /// Enables tunnel debug logging.
            public var shouldDebug: Bool = false

            public init(sessionConfiguration: OpenVPN.Configuration) {
                self.sessionConfiguration = sessionConfiguration.builder()
            }

            public func build() -> OpenVPN.ProviderConfiguration {
                var providerConfiguration = OpenVPN.ProviderConfiguration(
                    OpenVPNProvider.title,
                    appGroup: Client.Configuration.appGroup,
                    configuration: sessionConfiguration.build()
                )
                providerConfiguration.shouldDebug = shouldDebug
                return providerConfiguration
            }
        }
    }

    extension OpenVPN.ProviderConfiguration {

        /// Legacy accessor: the old provider configuration exposed its inner session
        /// configuration as `sessionConfiguration`.
        public var sessionConfiguration: OpenVPN.Configuration {
            configuration
        }
    }

    extension OpenVPN.ConfigurationBuilder {

        /// Sentinel address used for endpoints whose real address is resolved later,
        /// at connection time (see `PIATunnelProfile.generatedProtocol`).
        static let unresolvedEndpointAddress = "0.0.0.0"

        /// Legacy bridge: the old fork modelled protocol preferences separately from
        /// addresses via `endpointProtocols`. The Kape fork only has `remotes`
        /// (address + protocol), so protocol preferences are stored on `remotes` using
        /// a sentinel address that `generatedProtocol` replaces with the resolved IP.
        public var endpointProtocols: [EndpointProtocol]? {
            get {
                remotes?.map { $0.proto }
            }
            set {
                guard let newValue else {
                    remotes = nil
                    return
                }
                remotes = newValue.map { TunnelKitCore.Endpoint(Self.unresolvedEndpointAddress, $0) }
            }
        }
    }
#endif
