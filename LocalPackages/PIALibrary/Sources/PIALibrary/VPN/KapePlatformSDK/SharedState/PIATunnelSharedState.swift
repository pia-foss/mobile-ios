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
///
/// The persisted value types (`State`, `ActiveConnection`, `OpenVPNSettings`, …) live in
/// `PIATunnelSharedState+Models.swift`; this file holds the read/write/update API over them.
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

    // MARK: - Persistence

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
            postDidChange()
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
            postDidChange()
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

    /// Replaces the per-server latency map (`latencyByServerId`), preserving every other field.
    ///
    /// Called by the app each time the `ServersPinger` finishes a ping cycle, so the extension's
    /// fastest-server fallback in `State.selectedServer(in:)` stays aligned with the app's
    /// `bestServer`. Keys are `Server.identifier`; values are latencies in milliseconds.
    public static func updateLatencies(_ latencyByServerId: [String: Int]) {
        var state = read()
        state.latencyByServerId = latencyByServerId
        write(state)
    }

    /// Records what the tunnel actually connected to (resolved protocol + region id + transport),
    /// preserving every other field. Called by the extension once `.connected`. The app re-reads
    /// this when it observes the VPN status change (`.PIADaemonsDidUpdateVPNStatus`).
    public static func updateActiveConnection(
        protocol vpnProtocol: TunnelProtocol,
        serverId: String,
        resolvedTransport: VPNTransport
    ) {
        var state = read()
        state.activeConnection = ActiveConnection(
            protocol: vpnProtocol,
            serverId: serverId,
            resolvedTransport: resolvedTransport,
            updatedAt: Date()
        )
        write(state)
    }

    /// Clears the actual-connection write-back (e.g. on disconnect/pause).
    public static func clearActiveConnection() {
        var state = read()
        guard state.activeConnection != nil else { return }
        state.activeConnection = nil
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
