//
//  PIATunnelSharedState.swift
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

/// File-based shared state between the app and the PlatformSDK tunnel extension.
///
/// Mirrors the Kape SDK's `KapeSharedState`: a single `Codable` `State` persisted as a JSON file
/// in the App Group container — **not** `UserDefaults`, which can be unreliable to read from a
/// Network Extension (per-process `cfprefsd` caching can return stale values right after a write).
///
/// The app writes the state at connect time (`KapePlatformSDKTunnelProfile.doSave`); the extension
/// reads it on every tunnel start (`PIAEndpointRepository`). Because the resolved location and the
/// server list are written together, the file is always a self-consistent snapshot.
public enum PIATunnelSharedState {

    private static let fileName = "pia_platformsdk_state.json"

    /// The VPN protocol the PlatformSDK tunnel should run.
    public enum TunnelProtocol: String, Codable {
        case wireGuard
        case openVPN
    }

    /// The OpenVPN transport the user selected. `automatic` lets the tunnel try both UDP and TCP.
    public enum OpenVPNTransport: String, Codable {
        case automatic
        case udp
        case tcp
    }

    /// Everything the PlatformSDK tunnel needs to resolve its endpoints.
    public struct State: Codable {
        /// Identifier of the resolved target server (`serverProvider.targetServer`) the tunnel
        /// should connect to. Concrete even for "Automatic", where `preferredServer` is nil.
        public var selectedLocationId: String?

        /// Snapshot of the server list (the app's `cachedServers`) the extension looks up in.
        public var servers: [Server]

        /// The protocol the tunnel should establish (mirrors the user's selected VPN protocol).
        public var selectedProtocol: TunnelProtocol

        // MARK: OpenVPN fields (written by the app at connect time, read by PIAOpenVPNEndpointRepository)

        /// CA certificate PEM (`PIA-RSA-4096.pem`). Required by `OpenVPNConnectionController`.
        public var openVPNCaCertificate: String

        /// VPN username (`vpnTokenUsername` from `AccountProvider`).
        public var openVPNUsername: String

        /// VPN password (`vpnTokenPassword` from `AccountProvider`).
        public var openVPNPassword: String

        /// Minimal OVPN config text supplying `cipher` and `auth` directives, e.g.
        /// `"cipher AES-128-GCM\nauth SHA256"`. Parsed by `OpenVPNConfigParser` in the SDK.
        public var openVPNOvpnConfig: String

        /// Preferred port for the chosen transport, or 0 for automatic (use protocol defaults).
        public var openVPNPort: UInt16

        /// The user-selected OpenVPN transport. `automatic` allows both UDP and TCP endpoints.
        public var openVPNTransport: OpenVPNTransport

        /// MTU for the OpenVPN tunnel. 1400 by default; 1350 when small packets is enabled.
        public var openVPNMtu: UInt16

        /// MTU for the WireGuard tunnel. 1420 by default; 1280 when small packets is enabled.
        public var wireGuardMtu: UInt16

        public init(
            selectedLocationId: String? = nil,
            servers: [Server] = [],
            selectedProtocol: TunnelProtocol = .wireGuard,
            openVPNCaCertificate: String = "",
            openVPNUsername: String = "",
            openVPNPassword: String = "",
            openVPNOvpnConfig: String = "",
            openVPNPort: UInt16 = 0,
            openVPNTransport: OpenVPNTransport = .automatic,
            openVPNMtu: UInt16 = UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize),
            wireGuardMtu: UInt16 = UInt16(AppConstants.WireGuardPacketSize.highPacketSize)
        ) {
            self.selectedLocationId = selectedLocationId
            self.servers = servers
            self.selectedProtocol = selectedProtocol
            self.openVPNCaCertificate = openVPNCaCertificate
            self.openVPNUsername = openVPNUsername
            self.openVPNPassword = openVPNPassword
            self.openVPNOvpnConfig = openVPNOvpnConfig
            self.openVPNPort = openVPNPort
            self.openVPNTransport = openVPNTransport
            self.openVPNMtu = openVPNMtu
            self.wireGuardMtu = wireGuardMtu
        }

        private enum CodingKeys: String, CodingKey {
            case selectedLocationId, servers, selectedProtocol
            case openVPNCaCertificate, openVPNUsername, openVPNPassword, openVPNOvpnConfig
            case openVPNPort, openVPNTransport, openVPNMtu
            case wireGuardMtu
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedLocationId = try container.decodeIfPresent(String.self, forKey: .selectedLocationId)
            servers = try container.decodeIfPresent([Server].self, forKey: .servers) ?? []
            selectedProtocol = try container.decodeIfPresent(TunnelProtocol.self, forKey: .selectedProtocol) ?? .wireGuard
            openVPNCaCertificate = try container.decodeIfPresent(String.self, forKey: .openVPNCaCertificate) ?? ""
            openVPNUsername = try container.decodeIfPresent(String.self, forKey: .openVPNUsername) ?? ""
            openVPNPassword = try container.decodeIfPresent(String.self, forKey: .openVPNPassword) ?? ""
            openVPNOvpnConfig = try container.decodeIfPresent(String.self, forKey: .openVPNOvpnConfig) ?? ""
            openVPNPort = try container.decodeIfPresent(UInt16.self, forKey: .openVPNPort) ?? 0
            openVPNTransport = try container.decodeIfPresent(OpenVPNTransport.self, forKey: .openVPNTransport) ?? .automatic
            openVPNMtu = try container.decodeIfPresent(UInt16.self, forKey: .openVPNMtu) ?? UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize)
            wireGuardMtu = try container.decodeIfPresent(UInt16.self, forKey: .wireGuardMtu) ?? UInt16(AppConstants.WireGuardPacketSize.highPacketSize)
        }

        /// The server matching `selectedLocationId` within `servers`, if present.
        public var selectedServer: Server? {
            guard let selectedLocationId else { return nil }
            return servers.first { $0.identifier == selectedLocationId }
        }
    }

    /// Reads the shared state from the App Group container, or defaults if none is written yet.
    public static func read(appGroup: String) -> State {
        guard let url = containerURL(appGroup: appGroup),
            let data = try? Data(contentsOf: url),
            let state = try? JSONDecoder().decode(State.self, from: data)
        else {
            return State()
        }
        return state
    }

    /// Writes the shared state to the App Group container (atomically).
    public static func write(_ state: State, appGroup: String) {
        guard let url = containerURL(appGroup: appGroup),
            let data = try? JSONEncoder().encode(state)
        else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }

    private static func containerURL(appGroup: String) -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent(fileName)
    }
}
