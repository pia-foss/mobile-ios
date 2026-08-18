//
//  PIATunnelSharedState+Models.swift
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

import Foundation

// The `Codable` value types persisted per slice (`Config`, `ServersCache`, `Status`), plus the
// read-side `State` aggregate. The persistence API lives in `PIATunnelSharedState.swift`.
extension PIATunnelSharedState {

    // MARK: - Protocol & Transport

    /// `automatic` tries WireGuard first, then falls back to OpenVPN.
    public enum TunnelProtocol: String, Codable {
        case wireGuard
        case openVPN
        case automatic
    }

    /// The user-selected OpenVPN transport; `automatic` allows both UDP and TCP.
    public enum OpenVPNTransport: String, Codable {
        case automatic
        case udp
        case tcp
    }

    /// The transport actually carrying a live tunnel — never `automatic`.
    public enum VPNTransport: String, Codable {
        case udp
        case tcp
    }

    // MARK: - Tunnel Status

    /// The status the tunnel reports — richer than `NEVPNStatus`, which stays `.connected` through an
    /// in-place switch or mid-session reconnect. Mirrors `KapeVPNConnectionStatus`, PIA-owned so
    /// PIALibrary needs no Kape import.
    public enum TunnelStatus: String, Codable {
        case connected
        case connecting
        case reconnecting
        case disconnecting
        case disconnected
        case paused
    }

    // MARK: - Active Connection

    /// What the tunnel is *actually* running, as opposed to the user's (possibly Automatic) selection.
    /// Carries the region identifier only — never the endpoint IP.
    public struct ActiveConnection: Codable, Equatable {
        /// Never `.automatic`.
        public var `protocol`: TunnelProtocol
        public var serverId: String
        /// The transport the SDK resolved — the app can't derive this under Automatic transport.
        public var resolvedTransport: VPNTransport
        /// So a stale value from a previous session can be ignored.
        public var updatedAt: Date

        public init(
            protocol: TunnelProtocol,
            serverId: String,
            resolvedTransport: VPNTransport,
            updatedAt: Date
        ) {
            self.protocol = `protocol`
            self.serverId = serverId
            self.resolvedTransport = resolvedTransport
            self.updatedAt = updatedAt
        }

        private enum CodingKeys: String, CodingKey {
            case `protocol`, serverId, resolvedTransport, updatedAt
        }

        // A payload predating `resolvedTransport` defaults to `.udp` rather than failing the decode.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            `protocol` = try container.decode(TunnelProtocol.self, forKey: .protocol)
            serverId = try container.decode(String.self, forKey: .serverId)
            resolvedTransport = try container.decodeIfPresent(VPNTransport.self, forKey: .resolvedTransport) ?? .udp
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }

    // MARK: - Protocol Settings

    /// OpenVPN parameters the app resolves at connect time; read by `PIAEndpointRepository+OpenVPN`.
    public struct OpenVPNSettings: Codable, Equatable {
        /// CA certificate PEM (`PIA-RSA-4096.pem`).
        public var caCertificate: String

        /// `vpnTokenUsername` from `AccountProvider`.
        public var username: String

        /// `vpnTokenPassword` from `AccountProvider`.
        public var password: String

        /// Minimal OVPN text supplying `cipher` and `auth`, parsed by the SDK's `OpenVPNConfigParser`.
        public var ovpnConfig: String

        /// Preferred port, or 0 for the protocol defaults.
        public var port: UInt16

        public var transport: OpenVPNTransport

        /// 1400 by default; 1350 with small packets.
        public var mtu: UInt16

        /// Custom resolvers in priority order. Empty → let the server push its DNS.
        public var dnsServers: [String]

        public init(
            caCertificate: String = "",
            username: String = "",
            password: String = "",
            ovpnConfig: String = "",
            port: UInt16 = 0,
            transport: OpenVPNTransport = .automatic,
            mtu: UInt16 = UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize),
            dnsServers: [String] = []
        ) {
            self.caCertificate = caCertificate
            self.username = username
            self.password = password
            self.ovpnConfig = ovpnConfig
            self.port = port
            self.transport = transport
            self.mtu = mtu
            self.dnsServers = dnsServers
        }

        private enum CodingKeys: String, CodingKey {
            case caCertificate, username, password, ovpnConfig, port, transport, mtu, dnsServers
        }

        // Missing keys fall back to defaults.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            caCertificate = try container.decodeIfPresent(String.self, forKey: .caCertificate) ?? ""
            username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
            password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
            ovpnConfig = try container.decodeIfPresent(String.self, forKey: .ovpnConfig) ?? ""
            port = try container.decodeIfPresent(UInt16.self, forKey: .port) ?? 0
            transport = try container.decodeIfPresent(OpenVPNTransport.self, forKey: .transport) ?? .automatic
            mtu = try container.decodeIfPresent(UInt16.self, forKey: .mtu) ?? UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize)
            dnsServers = try container.decodeIfPresent([String].self, forKey: .dnsServers) ?? []
        }
    }

    /// WireGuard parameters the app resolves at connect time; read by `PIAEndpointRepository+WireGuard`
    /// and `PIAWireguardAuthenticator`.
    public struct WireGuardSettings: Codable, Equatable {
        /// 1420 by default; 1280 with small packets.
        public var mtu: UInt16

        /// Key-exchange token: the account `vpnToken`, or the server's `dipUsername` for a Dedicated IP.
        /// Passed through shared state because the extension can't reliably read account credentials.
        public var token: String?

        /// Custom resolvers in priority order. Empty → keep the server-provided ones.
        public var dnsServers: [String]

        public init(
            mtu: UInt16 = UInt16(AppConstants.WireGuardPacketSize.highPacketSize),
            token: String? = nil,
            dnsServers: [String] = []
        ) {
            self.mtu = mtu
            self.token = token
            self.dnsServers = dnsServers
        }

        private enum CodingKeys: String, CodingKey {
            case mtu, token, dnsServers
        }

        // Missing keys fall back to defaults.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            mtu = try container.decodeIfPresent(UInt16.self, forKey: .mtu) ?? UInt16(AppConstants.WireGuardPacketSize.highPacketSize)
            token = try container.decodeIfPresent(String.self, forKey: .token)
            dnsServers = try container.decodeIfPresent([String].self, forKey: .dnsServers) ?? []
        }
    }

    // MARK: - Persisted Slices

    /// App → tunnel connection inputs plus the app's measured latencies, in
    /// `pia_platformsdk_config.json`. Written only by the app; the extension reads it.
    public struct Config: Codable {

        /// The resolved target server's identifier, or nil for "Automatic" — the signal for
        /// `PIAEndpointRepository.generateConfigurations` to fan out across every online server. nil is
        /// the common case.
        public var selectedLocationId: String?

        /// The resolved Dedicated IP target, carried in full because DIP servers are per-user and absent
        /// from the public list the extension fetches. nil for a regular region.
        public var selectedDipServer: Server?

        public var selectedProtocol: TunnelProtocol

        public var openVPN: OpenVPNSettings

        public var wireGuard: WireGuardSettings

        /// Latencies from the app's `ServersPinger`, keyed by `Server.identifier`, in milliseconds.
        /// Carried explicitly because `Server`'s `Codable` form drops its measured `responseTime`;
        /// `State.selectedServer(in:)` uses it to mirror the app's `bestServer`. App-owned, so a
        /// connect-time write and a ping cycle can't lose each other's values.
        public var latencyByServerId: [String: Int]

        public init(
            selectedLocationId: String? = nil,
            selectedDipServer: Server? = nil,
            selectedProtocol: TunnelProtocol = .automatic,
            openVPN: OpenVPNSettings = OpenVPNSettings(),
            wireGuard: WireGuardSettings = WireGuardSettings(),
            latencyByServerId: [String: Int] = [:]
        ) {
            self.selectedLocationId = selectedLocationId
            self.selectedDipServer = selectedDipServer
            self.selectedProtocol = selectedProtocol
            self.openVPN = openVPN
            self.wireGuard = wireGuard
            self.latencyByServerId = latencyByServerId
        }

        private enum CodingKeys: String, CodingKey {
            case selectedLocationId, selectedDipServer, selectedProtocol, openVPN, wireGuard
            case latencyByServerId
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedLocationId = try container.decodeIfPresent(String.self, forKey: .selectedLocationId)
            selectedDipServer = try container.decodeIfPresent(Server.self, forKey: .selectedDipServer)
            selectedProtocol = try container.decodeIfPresent(TunnelProtocol.self, forKey: .selectedProtocol) ?? .automatic
            openVPN = try container.decodeIfPresent(OpenVPNSettings.self, forKey: .openVPN) ?? OpenVPNSettings()
            wireGuard = try container.decodeIfPresent(WireGuardSettings.self, forKey: .wireGuard) ?? WireGuardSettings()
            latencyByServerId = try container.decodeIfPresent([String: Int].self, forKey: .latencyByServerId) ?? [:]
        }
    }

    /// The server list the extension looks up in, in `pia_platformsdk_servers.json`. The one slice both
    /// processes write — but only ever whole (`updateServers`), so a concurrent write means "the other
    /// list won" rather than a lost field.
    public struct ServersCache: Codable {

        public var servers: [Server]

        /// When `servers` was last fetched, or nil while the list is only the app's unverified snapshot.
        /// The extension re-fetches past `serversCacheTTL` and reuses `servers` within it.
        public var serversFetchedAt: Date?

        public init(servers: [Server] = [], serversFetchedAt: Date? = nil) {
            self.servers = servers
            self.serversFetchedAt = serversFetchedAt
        }

        private enum CodingKeys: String, CodingKey {
            case servers, serversFetchedAt
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            servers = try container.decodeIfPresent([Server].self, forKey: .servers) ?? []
            serversFetchedAt = try container.decodeIfPresent(Date.self, forKey: .serversFetchedAt)
        }
    }

    /// Tunnel → app write-back, in `pia_platformsdk_status.json`. Written only by the extension, which
    /// clears it at tunnel start and on `stopTunnel`. Its own file because the app writes shared state
    /// on paths that overlap a connect, and sharing one file let those revert `tunnelStatus`.
    public struct Status: Codable {

        /// `nil` when not connected. The app reads it, gated on `vpnStatus`, to show the resolved
        /// protocol/server rather than the user's selection.
        public var activeConnection: ActiveConnection?

        /// `nil` before the tunnel reports anything, or once cleared.
        public var tunnelStatus: TunnelStatus?

        public init(activeConnection: ActiveConnection? = nil, tunnelStatus: TunnelStatus? = nil) {
            self.activeConnection = activeConnection
            self.tunnelStatus = tunnelStatus
        }

        private enum CodingKeys: String, CodingKey {
            case activeConnection, tunnelStatus
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            activeConnection = try container.decodeIfPresent(ActiveConnection.self, forKey: .activeConnection)
            tunnelStatus = try container.decodeIfPresent(TunnelStatus.self, forKey: .tunnelStatus)
        }
    }

    // MARK: - State

    /// Every slice combined, for consumers that need more than one. Not persisted itself — the slices
    /// are the units on disk — so a snapshot is consistent *per slice*, not across all three. Only
    /// readers combine these fields, so that's enough.
    public struct State {

        // MARK: App → Tunnel (connection inputs)

        public var selectedLocationId: String?
        public var selectedDipServer: Server?
        public var selectedProtocol: TunnelProtocol
        public var openVPN: OpenVPNSettings
        public var wireGuard: WireGuardSettings
        public var latencyByServerId: [String: Int]

        // MARK: Shared cache

        public var servers: [Server]
        public var serversFetchedAt: Date?

        // MARK: Tunnel → App (write-back)

        public var activeConnection: ActiveConnection?
        public var tunnelStatus: TunnelStatus?

        init(
            selectedLocationId: String? = nil,
            selectedDipServer: Server? = nil,
            selectedProtocol: TunnelProtocol = .automatic,
            openVPN: OpenVPNSettings = OpenVPNSettings(),
            wireGuard: WireGuardSettings = WireGuardSettings(),
            servers: [Server] = [],
            serversFetchedAt: Date? = nil,
            latencyByServerId: [String: Int] = [:],
            activeConnection: ActiveConnection? = nil,
            tunnelStatus: TunnelStatus? = nil
        ) {
            self.selectedLocationId = selectedLocationId
            self.selectedDipServer = selectedDipServer
            self.selectedProtocol = selectedProtocol
            self.openVPN = openVPN
            self.wireGuard = wireGuard
            self.servers = servers
            self.serversFetchedAt = serversFetchedAt
            self.latencyByServerId = latencyByServerId
            self.activeConnection = activeConnection
            self.tunnelStatus = tunnelStatus
        }

        init(config: Config, serversCache: ServersCache, status: Status) {
            self.init(
                selectedLocationId: config.selectedLocationId,
                selectedDipServer: config.selectedDipServer,
                selectedProtocol: config.selectedProtocol,
                openVPN: config.openVPN,
                wireGuard: config.wireGuard,
                servers: serversCache.servers,
                serversFetchedAt: serversCache.serversFetchedAt,
                latencyByServerId: config.latencyByServerId,
                activeConnection: status.activeConnection,
                tunnelStatus: status.tunnelStatus
            )
        }

        /// The server matching the resolved target, if present. A DIP target is used directly; a regular
        /// one matches by `identifier`, excluding any DIP entry sharing it; with no selection, the
        /// fastest server wins.
        public func selectedServer(in servers: [Server]) -> Server? {
            if let selectedDipServer {
                return selectedDipServer
            }

            // An unmatched id falls through to the Automatic behaviour below rather than returning nil.
            if let selectedLocationId, let match = servers.first(where: { $0.identifier == selectedLocationId && $0.dipToken == nil }) {
                return match
            }

            // Fastest measured server, mirroring the app's `bestServer`; with no ping data (e.g. an
            // autonomous fetch) fall back to the first available one.
            let available = servers.filter { $0.dipToken == nil && !$0.offline }
            if let fastest =
                available
                .compactMap({ server in latencyByServerId[server.identifier].map { (server, $0) } })
                .min(by: { $0.1 < $1.1 })?.0
            {
                return fastest
            }

            return available.first
        }
    }
}
