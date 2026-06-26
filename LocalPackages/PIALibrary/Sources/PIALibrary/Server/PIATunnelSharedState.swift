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

private let log = PIALogger.logger(for: PIATunnelSharedState.self)

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

    /// How long a fetched server list stays usable before the tunnel refreshes it. Mirrors the Kape
    /// low-level SDK's `DEFAULT_MAX_AGE` for instance discovery (1 hour), shortened to 5 minutes in
    /// DEBUG builds to make refresh behaviour easy to exercise. Used by the extension to decide
    /// whether to re-fetch.
    #if DEBUG
        public static let serversCacheTTL: TimeInterval = 300
    #else
        public static let serversCacheTTL: TimeInterval = 3600
    #endif

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

        /// `dipToken` of the resolved target server, or nil for a regular server. A Dedicated IP
        /// server shares its `identifier` (derived from hostname) with its base region, so the
        /// extension must disambiguate on `(identifier, dipToken)` — see `selectedServer(in:)`.
        public var selectedDipToken: String?

        /// Server list the extension looks up in. Seeded by the app from its `cachedServers`, then
        /// overwritten by the extension with a freshly fetched list (see `serversFetchedAt`).
        public var servers: [Server]

        /// When `servers` was last fetched from the backend by the extension, or nil when the list is
        /// only the app's unverified snapshot. The extension re-fetches once this is older than
        /// `serversCacheTTL`; within the TTL it reuses `servers` without hitting the network. This is
        /// the file-backed cache that survives the extension process being killed on disconnect.
        public var serversFetchedAt: Date?

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

        /// Custom DNS resolvers for OpenVPN, in priority order (the user's Settings → Network
        /// choice). Empty → let the server push its DNS (the PIA-default behaviour).
        public var openVPNDnsServers: [String]

        /// MTU for the WireGuard tunnel. 1420 by default; 1280 when small packets is enabled.
        public var wireGuardMtu: UInt16

        /// WireGuard key-exchange token used by `PIAWireguardAuthenticator`. The account `vpnToken`
        /// for a regular server, or the server's `dipUsername` for a Dedicated IP server. Passed via
        /// shared state because the extension can't reliably read account credentials at run time.
        public var wireGuardToken: String?

        /// Custom DNS resolvers for WireGuard, in priority order (the user's Settings → Network
        /// choice). Empty → the authenticator keeps the server-provided resolvers.
        public var wireGuardDnsServers: [String]

        init(
            selectedLocationId: String? = nil,
            selectedDipToken: String? = nil,
            servers: [Server] = [],
            serversFetchedAt: Date? = nil,
            selectedProtocol: TunnelProtocol = .wireGuard,
            openVPNCaCertificate: String = "",
            openVPNUsername: String = "",
            openVPNPassword: String = "",
            openVPNOvpnConfig: String = "",
            openVPNPort: UInt16 = 0,
            openVPNTransport: OpenVPNTransport = .automatic,
            openVPNMtu: UInt16 = UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize),
            openVPNDnsServers: [String] = [],
            wireGuardMtu: UInt16 = UInt16(AppConstants.WireGuardPacketSize.highPacketSize),
            wireGuardToken: String? = nil,
            wireGuardDnsServers: [String] = []
        ) {
            self.selectedLocationId = selectedLocationId
            self.selectedDipToken = selectedDipToken
            self.servers = servers
            self.serversFetchedAt = serversFetchedAt
            self.selectedProtocol = selectedProtocol
            self.openVPNCaCertificate = openVPNCaCertificate
            self.openVPNUsername = openVPNUsername
            self.openVPNPassword = openVPNPassword
            self.openVPNOvpnConfig = openVPNOvpnConfig
            self.openVPNPort = openVPNPort
            self.openVPNTransport = openVPNTransport
            self.openVPNMtu = openVPNMtu
            self.openVPNDnsServers = openVPNDnsServers
            self.wireGuardMtu = wireGuardMtu
            self.wireGuardToken = wireGuardToken
            self.wireGuardDnsServers = wireGuardDnsServers
        }

        private enum CodingKeys: String, CodingKey {
            case selectedLocationId, selectedDipToken, servers, serversFetchedAt, selectedProtocol
            case openVPNCaCertificate, openVPNUsername, openVPNPassword, openVPNOvpnConfig
            case openVPNPort, openVPNTransport, openVPNMtu, openVPNDnsServers
            case wireGuardMtu, wireGuardToken, wireGuardDnsServers
        }

        // Tolerate a missing/older file by falling back to defaults per field.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            selectedLocationId = try container.decodeIfPresent(String.self, forKey: .selectedLocationId)
            selectedDipToken = try container.decodeIfPresent(String.self, forKey: .selectedDipToken)
            servers = try container.decodeIfPresent([Server].self, forKey: .servers) ?? []
            serversFetchedAt = try container.decodeIfPresent(Date.self, forKey: .serversFetchedAt)
            selectedProtocol = try container.decodeIfPresent(TunnelProtocol.self, forKey: .selectedProtocol) ?? .wireGuard
            openVPNCaCertificate = try container.decodeIfPresent(String.self, forKey: .openVPNCaCertificate) ?? ""
            openVPNUsername = try container.decodeIfPresent(String.self, forKey: .openVPNUsername) ?? ""
            openVPNPassword = try container.decodeIfPresent(String.self, forKey: .openVPNPassword) ?? ""
            openVPNOvpnConfig = try container.decodeIfPresent(String.self, forKey: .openVPNOvpnConfig) ?? ""
            openVPNPort = try container.decodeIfPresent(UInt16.self, forKey: .openVPNPort) ?? 0
            openVPNTransport = try container.decodeIfPresent(OpenVPNTransport.self, forKey: .openVPNTransport) ?? .automatic
            openVPNMtu = try container.decodeIfPresent(UInt16.self, forKey: .openVPNMtu) ?? UInt16(AppConstants.OpenVPNPacketSize.defaultPacketSize)
            openVPNDnsServers = try container.decodeIfPresent([String].self, forKey: .openVPNDnsServers) ?? []
            wireGuardMtu = try container.decodeIfPresent(UInt16.self, forKey: .wireGuardMtu) ?? UInt16(AppConstants.WireGuardPacketSize.highPacketSize)
            wireGuardToken = try container.decodeIfPresent(String.self, forKey: .wireGuardToken)
            wireGuardDnsServers = try container.decodeIfPresent([String].self, forKey: .wireGuardDnsServers) ?? []
        }

        /// The server matching the resolved target within a server list, if present.
        ///
        /// Used both for the snapshot (`servers`) and for a freshly fetched list. A Dedicated IP
        /// server shares its `identifier` with its base region, so `identifier` alone is ambiguous:
        /// resolve by the unique `dipToken` when this is a DIP target; for a regular target match by
        /// `identifier` and exclude any DIP entry that shares it.
        public func selectedServer(in servers: [Server]) -> Server? {
            if let selectedDipToken {
                return servers.first { $0.dipToken == selectedDipToken }
            }

            guard let selectedLocationId else {
                return nil
            }

            return servers.first { $0.identifier == selectedLocationId && $0.dipToken == nil }
        }
    }

    /// Reads the shared state from PIA's App Group container, or defaults if none is written yet.
    public static func read() -> State {
        guard let url = containerURL(),
            let data = try? Data(contentsOf: url),
            let state = try? JSONDecoder().decode(State.self, from: data)
        else {
            return State()
        }
        return state
    }

    /// Writes the shared state to PIA's App Group container (atomically).
    static func write(_ state: State) {
        guard let url = containerURL() else {
            log.error("Failed to write shared state: no container URL for app group \(AppConstants.appGroup)")
            return
        }
        let data: Data
        do {
            data = try JSONEncoder().encode(state)
        } catch {
            log.error("Failed to encode shared state: \(error)")
            return
        }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            log.error("Failed to write shared state file at \(url.path): \(error)")
        }
    }

    /// Deletes the shared state file from PIA's App Group container (e.g. on logout).
    static func delete() {
        guard let url = containerURL() else {
            log.error("Failed to delete shared state: no container URL for app group \(AppConstants.appGroup)")
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
            // File not found is not an error — state was already cleared or never written.
        } catch {
            log.error("Failed to delete shared state file at \(url.path): \(error)")
        }
    }

    /// Replaces the cached server list and stamps `serversFetchedAt` with the current time,
    /// preserving every other field.
    ///
    /// Called by the app whenever it downloads fresh regions and by the tunnel extension after an
    /// autonomous fetch, so the file-backed cache stays warm across the extension process being
    /// recreated on each connect.
    public static func updateServers(_ servers: [Server]) {
        var state = read()
        state.servers = servers
        state.serversFetchedAt = Date()
        write(state)
    }

    private static func containerURL() -> URL? {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroup) else {
            return nil
        }

        let baseURL: URL

        #if os(tvOS)
            // On tvOS only the Library/Caches subdirectory is shareable/writable
            // between the app and the network extension.
            baseURL =
                container
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Caches", isDirectory: true)
        #else
            baseURL = container
        #endif

        return baseURL.appendingPathComponent(fileName)
    }
}
