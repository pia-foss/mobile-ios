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

// The `Codable` value types persisted in the shared-state file. The persistence API that reads and
// writes them (`read`/`write`/`delete`/`update*`) lives in `PIATunnelSharedState.swift`.
extension PIATunnelSharedState {

    // MARK: - Protocol & Transport

    /// The VPN protocol the PlatformSDK tunnel should run. `automatic` lets the tunnel try
    /// WireGuard first and fall back to OpenVPN.
    public enum TunnelProtocol: String, Codable {
        case wireGuard
        case openVPN
        case automatic
    }

    /// The OpenVPN transport the user selected. `automatic` lets the tunnel try both UDP and TCP.
    public enum OpenVPNTransport: String, Codable {
        case automatic
        case udp
        case tcp
    }

    /// A concrete transport actually carrying an established tunnel — protocol-neutral and never
    /// `automatic` (a live connection always runs over exactly one). WireGuard is always `.udp`;
    /// OpenVPN is whichever of UDP/TCP the SDK resolved.
    public enum VPNTransport: String, Codable {
        case udp
        case tcp
    }

    // MARK: - Tunnel Status

    /// The live connection status the PlatformSDK tunnel reports back, written by the extension
    /// whenever its status changes.
    ///
    /// This is the extension's authoritative view of the session — richer than what `NEVPNStatus`
    /// exposes. In particular an in-place region switch (and any mid-session reconnect) surfaces as
    /// `.connecting` / `.reconnecting` here even though `NEVPNStatus` stays `.connected` the whole
    /// time, which is why the app reads this to drive its connection status. Mirrors the SDK's own
    /// `KapeVPNConnectionStatus`, but PIA-owned so PIALibrary needs no Kape import.
    public enum TunnelStatus: String, Codable {
        case connected
        case connecting
        case reconnecting
        case disconnecting
        case disconnected
        case paused
    }

    // MARK: - Active Connection

    /// What the tunnel is *actually* running, written back by the extension once connected.
    ///
    /// Distinct from the user's *selection*: when the user picks Automatic the tunnel resolves a
    /// concrete protocol (`.wireGuard`/`.openVPN`) and a concrete server, which the app reads to
    /// display the live state. Carries only the protocol and the region **identifier** — never the
    /// endpoint IP (the extension resolves host → `serverId` in-process and persists only the id).
    public struct ActiveConnection: Codable, Equatable {
        /// The protocol actually serving the tunnel (never `.automatic`).
        public var `protocol`: TunnelProtocol
        /// `Server.identifier` of the server the tunnel actually connected to.
        public var serverId: String
        /// The transport actually carrying the tunnel. WireGuard is always `.udp`; OpenVPN is the
        /// transport the SDK resolved — relevant when the user selected Automatic transport and the
        /// SDK picks UDP/TCP via demand-driven failover, which the app can't otherwise derive.
        public var resolvedTransport: VPNTransport
        /// When this was written, so a stale value from a previous session can be ignored.
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

        // Tolerate a payload written before `resolvedTransport` existed by defaulting to `.udp`
        // (WireGuard is always UDP and OpenVPN's primary transport is UDP) — so an older
        // active-connection blob never fails the whole state decode.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            `protocol` = try container.decode(TunnelProtocol.self, forKey: .protocol)
            serverId = try container.decode(String.self, forKey: .serverId)
            resolvedTransport = try container.decodeIfPresent(VPNTransport.self, forKey: .resolvedTransport) ?? .udp
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }

    // MARK: - Protocol Settings

    /// OpenVPN parameters the app resolves at connect time and the extension
    /// (`PIAEndpointRepository+OpenVPN`) reads to build its endpoints.
    public struct OpenVPNSettings: Codable, Equatable {
        /// CA certificate PEM (`PIA-RSA-4096.pem`). Required by `OpenVPNConnectionController`.
        public var caCertificate: String

        /// VPN username (`vpnTokenUsername` from `AccountProvider`).
        public var username: String

        /// VPN password (`vpnTokenPassword` from `AccountProvider`).
        public var password: String

        /// Minimal OVPN config text supplying `cipher` and `auth` directives, e.g.
        /// `"cipher AES-128-GCM\nauth SHA256"`. Parsed by `OpenVPNConfigParser` in the SDK.
        public var ovpnConfig: String

        /// Preferred port for the chosen transport, or 0 for automatic (use protocol defaults).
        public var port: UInt16

        /// The user-selected OpenVPN transport. `automatic` allows both UDP and TCP endpoints.
        public var transport: OpenVPNTransport

        /// MTU for the OpenVPN tunnel. 1400 by default; 1350 when small packets is enabled.
        public var mtu: UInt16

        /// Custom DNS resolvers for OpenVPN, in priority order (the user's Settings → Network
        /// choice). Empty → let the server push its DNS (the PIA-default behaviour).
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

        // Tolerate a missing/older payload by falling back to defaults per field.
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

    /// WireGuard parameters the app resolves at connect time and the extension
    /// (`PIAEndpointRepository+WireGuard`, `PIAWireguardAuthenticator`) reads to build its endpoints.
    public struct WireGuardSettings: Codable, Equatable {
        /// MTU for the WireGuard tunnel. 1420 by default; 1280 when small packets is enabled.
        public var mtu: UInt16

        /// WireGuard key-exchange token used by `PIAWireguardAuthenticator`. The account `vpnToken`
        /// for a regular server, or the server's `dipUsername` for a Dedicated IP server. Passed via
        /// shared state because the extension can't reliably read account credentials at run time.
        public var token: String?

        /// Custom DNS resolvers for WireGuard, in priority order (the user's Settings → Network
        /// choice). Empty → the authenticator keeps the server-provided resolvers.
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

        // Tolerate a missing/older payload by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            mtu = try container.decodeIfPresent(UInt16.self, forKey: .mtu) ?? UInt16(AppConstants.WireGuardPacketSize.highPacketSize)
            token = try container.decodeIfPresent(String.self, forKey: .token)
            dnsServers = try container.decodeIfPresent([String].self, forKey: .dnsServers) ?? []
        }
    }

    // MARK: - State

    /// Everything the PlatformSDK tunnel needs to resolve its endpoints, plus what it reports back.
    ///
    /// A single self-consistent snapshot. Fields are grouped by IPC direction: connection inputs the
    /// app writes for the tunnel, a server cache both sides write, and the tunnel's write-back the
    /// app reads. Every mutator (`update*`) reads the whole state, changes one field, and rewrites it.
    public struct State: Codable {

        // MARK: App → Tunnel (connection inputs)

        /// Identifier of the resolved target server (`serverProvider.targetServer`) the tunnel
        /// should connect to. Concrete even for "Automatic", where `preferredServer` is nil.
        public var selectedLocationId: String?

        /// The resolved Dedicated IP target server, carried in full when a DIP region is selected,
        /// nil otherwise. DIP servers are per-user and absent from the public regions list the
        /// extension fetches autonomously, so they cannot be looked up in `servers`; when this is
        /// set, `selectedServer(in:)` uses it directly. Only the server's addresses are needed by the
        /// extension (DIP credentials are flattened into the `openVPN` / `wireGuard.token` fields),
        /// and those survive `Server`'s `Codable` round-trip.
        public var selectedDipServer: Server?

        /// The protocol the tunnel should establish (mirrors the user's selected VPN protocol).
        public var selectedProtocol: TunnelProtocol

        /// OpenVPN parameters (written by the app at connect time, read by `PIAEndpointRepository+OpenVPN`).
        public var openVPN: OpenVPNSettings

        /// WireGuard parameters (written by the app at connect time, read by `PIAEndpointRepository+WireGuard`
        /// and `PIAWireguardAuthenticator`).
        public var wireGuard: WireGuardSettings

        // MARK: Shared cache (written by both app and extension)

        /// Server list the extension looks up in. Seeded by the app from its `cachedServers`, then
        /// overwritten by the extension with a freshly fetched list (see `serversFetchedAt`).
        public var servers: [Server]

        /// When `servers` was last fetched from the backend by the extension, or nil when the list is
        /// only the app's unverified snapshot. The extension re-fetches once this is older than
        /// `serversCacheTTL`; within the TTL it reuses `servers` without hitting the network. This is
        /// the file-backed cache that survives the extension process being killed on disconnect.
        public var serversFetchedAt: Date?

        /// Per-server latency measured by the app's `ServersPinger`, keyed by `Server.identifier`
        /// and expressed in milliseconds (the best/lowest sample, matching the app's plain store).
        ///
        /// Carried explicitly because `Server`'s `Codable` form does not round-trip its measured
        /// `responseTime` — so without this map the extension cannot tell servers apart by speed.
        /// `selectedServer(in:)` uses it to pick the fastest server when no specific region is
        /// selected (Automatic, or an app-less autonomous fetch), mirroring the app's `bestServer`.
        /// Empty until the app has completed a ping cycle.
        public var latencyByServerId: [String: Int]

        // MARK: Tunnel → App (write-back)

        /// What the tunnel is actually running, written back by the extension on connect and cleared
        /// on disconnect. `nil` when not connected. The app reads it (gated on `vpnStatus`) to show
        /// the resolved protocol/server instead of the user's (possibly Automatic) selection.
        public var activeConnection: ActiveConnection?

        /// The live connection status the extension reports (see `TunnelStatus`). `nil` before the
        /// tunnel has reported anything or after it's cleared. The app folds this into its VPN status
        /// so an in-place region switch / mid-session reconnect surfaces as "Connecting" even though
        /// `NEVPNStatus` stays `.connected`.
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

        private enum CodingKeys: String, CodingKey {
            case selectedLocationId, selectedDipServer, selectedProtocol, openVPN, wireGuard
            case servers, serversFetchedAt, latencyByServerId
            case activeConnection, tunnelStatus
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedLocationId = try container.decodeIfPresent(String.self, forKey: .selectedLocationId)
            selectedDipServer = try container.decodeIfPresent(Server.self, forKey: .selectedDipServer)
            selectedProtocol = try container.decodeIfPresent(TunnelProtocol.self, forKey: .selectedProtocol) ?? .automatic
            openVPN = try container.decodeIfPresent(OpenVPNSettings.self, forKey: .openVPN) ?? OpenVPNSettings()
            wireGuard = try container.decodeIfPresent(WireGuardSettings.self, forKey: .wireGuard) ?? WireGuardSettings()
            servers = try container.decodeIfPresent([Server].self, forKey: .servers) ?? []
            serversFetchedAt = try container.decodeIfPresent(Date.self, forKey: .serversFetchedAt)
            latencyByServerId = try container.decodeIfPresent([String: Int].self, forKey: .latencyByServerId) ?? [:]
            activeConnection = try container.decodeIfPresent(ActiveConnection.self, forKey: .activeConnection)
            tunnelStatus = try container.decodeIfPresent(TunnelStatus.self, forKey: .tunnelStatus)
        }

        /// The server matching the resolved target within a server list, if present.
        ///
        /// A Dedicated IP target is carried in full (`selectedDipServer`) and used directly — it is
        /// per-user and not present in `servers`. For a regular target match by `identifier` and
        /// exclude any DIP entry that shares it; with no selection, fall back to the fastest server.
        public func selectedServer(in servers: [Server]) -> Server? {
            if let selectedDipServer {
                return selectedDipServer
            }

            // No specific region selected (Automatic / first launch), or the persisted id no longer
            // matches the current list: behave like the Automatic region and connect to the best
            // available server rather than returning nothing.
            if let selectedLocationId, let match = servers.first(where: { $0.identifier == selectedLocationId && $0.dipToken == nil }) {
                return match
            }

            // Pick the fastest server we have a measured latency for, mirroring the app's
            // `bestServer`. `latencyByServerId` is populated by the app's `ServersPinger`; it
            // carries the latencies the `servers` list itself cannot (`Server`'s Codable form drops
            // `responseTime`). When no ping data is present — e.g. an autonomous fetch with no
            // app-measured latencies — fall back to the first available server.
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
