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

/// File-based shared state between the app and the PlatformSDK tunnel extension. Uses the App Group
/// container rather than `UserDefaults`, which can return stale values in a Network Extension.
///
/// Split into three files, each with a **single writing process**:
/// - `…_config.json` — connection inputs + measured latencies (`Config`); app only
/// - `…_status.json` — the tunnel's write-back (`Status`); extension only
/// - `…_servers.json` — the server cache (`ServersCache`); either side, wholesale writes only
///
/// One file for all of it was not safe: every mutation is a read-modify-write, and `.atomic` only
/// prevents torn reads, not interleaved writers — so the app updating `servers`/`latencies` (which it
/// does on every VPN status change) could revert the extension's `tunnelStatus` and strand the app's
/// surfaced VPN status. Splitting by writer removes the interleaving; `Store` additionally locks each
/// read-modify-write so the app's own concurrent writers can't lose updates. `NSFileCoordinator` is
/// avoided on purpose: it can block for a long time when the peer process is suspended, and one peer
/// here writes on the tunnel's start path.
///
/// Value types live in `PIATunnelSharedState+Models.swift`.
public enum PIATunnelSharedState {

    // MARK: - Files

    private static let configFileName = "pia_platformsdk_config.json"
    private static let serversFileName = "pia_platformsdk_servers.json"
    private static let statusFileName = "pia_platformsdk_status.json"

    static let configStore = Store(fileName: configFileName) { Config() }
    static let serversStore = Store(fileName: serversFileName) { ServersCache() }
    static let statusStore = Store(fileName: statusFileName) { Status() }

    public static let serversCacheTTL: TimeInterval = 3600

    // MARK: - Reading

    public static func read() -> State {
        State(
            config: configStore.read(),
            serversCache: serversStore.read(),
            status: statusStore.read()
        )
    }

    public static func readConfig() -> Config {
        configStore.read()
    }

    public static func readServersCache() -> ServersCache {
        serversStore.read()
    }

    /// The tunnel's write-back. Cheap enough for status-change handlers to read on the main thread.
    public static func readStatus() -> Status {
        statusStore.read()
    }

    // MARK: - Writing (app)

    /// Replaces the connection inputs the tunnel resolves its endpoints from, leaving the measured
    /// latencies in place. Called by the app at connect time (`KapePlatformSDKTunnelProfile.doSave`).
    static func writeConnectionInputs(
        selectedLocationId: String?,
        selectedDipServer: Server?,
        selectedProtocol: TunnelProtocol,
        openVPN: OpenVPNSettings,
        wireGuard: WireGuardSettings,
        geoCountryCode: String?
    ) {
        configStore.mutate { config in
            config.selectedLocationId = selectedLocationId
            config.selectedDipServer = selectedDipServer
            config.selectedProtocol = selectedProtocol
            config.openVPN = openVPN
            config.wireGuard = wireGuard
            config.geoCountryCode = geoCountryCode
            return true
        }
    }

    /// Replaces the per-server latency map, preserving the connection inputs. Called after each
    /// `ServersPinger` cycle so the extension's fastest-server fallback stays aligned with the app's
    /// `bestServer`. Keys are `Server.identifier`; values are milliseconds.
    public static func updateLatencies(_ latencyByServerId: [String: Int]) {
        configStore.mutate { config in
            guard config.latencyByServerId != latencyByServerId else { return false }
            config.latencyByServerId = latencyByServerId
            return true
        }
    }

    // MARK: - Writing (shared cache)

    /// Replaces the cached server list wholesale and stamps it with the current time. Called by the
    /// app on a regions download and by the extension after an autonomous fetch, so the cache survives
    /// the extension process being recreated on each connect. Both processes write this slice, but
    /// only ever whole — so a concurrent write means "the other list won", not a lost field.
    public static func updateServers(_ servers: [Server]) {
        serversStore.write(ServersCache(servers: servers, serversFetchedAt: Date()))
    }

    // MARK: - Writing (extension)

    /// Records what the tunnel actually connected to. Written by the extension once `.connected`; the
    /// app re-reads it on `.PIADaemonsDidUpdateVPNStatus`.
    public static func updateActiveConnection(
        protocol vpnProtocol: TunnelProtocol,
        serverId: String,
        resolvedTransport: VPNTransport,
        obfuscation: String?
    ) {
        statusStore.mutate { status in
            status.activeConnection = ActiveConnection(
                protocol: vpnProtocol,
                serverId: serverId,
                resolvedTransport: resolvedTransport,
                obfuscation: obfuscation,
                updatedAt: Date()
            )
            return true
        }
    }

    /// Clears the actual-connection write-back (e.g. on disconnect/pause).
    public static func clearActiveConnection() {
        statusStore.mutate { status in
            guard status.activeConnection != nil else { return false }
            status.activeConnection = nil
            return true
        }
    }

    /// Records the status the tunnel reports. The app folds it into its VPN status so a mid-session
    /// reconnect or in-place switch surfaces as "Connecting" while `NEVPNStatus` stays `.connected`.
    /// The changed-check runs inside the mutation, so compare and write are one atomic step.
    public static func updateTunnelStatus(_ tunnelStatus: TunnelStatus) {
        statusStore.mutate { status in
            guard status.tunnelStatus != tunnelStatus else { return false }
            status.tunnelStatus = tunnelStatus
            return true
        }
    }

    /// Clears the reported tunnel status (e.g. when the extension tears the tunnel down).
    public static func clearTunnelStatus() {
        statusStore.mutate { status in
            guard status.tunnelStatus != nil else { return false }
            status.tunnelStatus = nil
            return true
        }
    }

    /// Drops the whole write-back. Called by the extension at tunnel start so a status left by a
    /// previous tunnel process — including one killed without a graceful `stopTunnel` — isn't read as
    /// current. The app must not call this: it doesn't own the slice.
    public static func clearStatus() {
        statusStore.delete()
    }

    // MARK: - Teardown

    /// Deletes all shared state from PIA's App Group container (e.g. on logout).
    static func delete() {
        configStore.delete()
        serversStore.delete()
        statusStore.delete()
    }

    // MARK: - Container

    static func containerDirectory() -> URL? {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroup) else {
            return nil
        }

        #if os(tvOS)
            // On tvOS only the Library/Caches subdirectory is shareable/writable
            // between the app and the network extension.
            return
                container
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Caches", isDirectory: true)
        #else
            return container
        #endif
    }
}

// MARK: - Store

extension PIATunnelSharedState {

    /// One persisted slice: a `Codable` value in its own file in the App Group container.
    ///
    /// `mutate(_:)` holds the mutex across the whole read-modify-write, so two writers in the *same*
    /// process can't build on a snapshot the other superseded. Cross-process safety comes from
    /// single-writer ownership per file, not from this mutex.
    final class Store<Value: Codable>: Sendable {

        private let fileName: String
        private let directory: @Sendable () -> URL?
        private let makeDefault: @Sendable () -> Value

        /// Guards the file, not in-memory state — hence `Void`. `PIALibrary.Mutex` is the repo's
        /// backport, so this becomes `Synchronization.Mutex` for free once the floor reaches iOS 18.
        private let mutex = Mutex<Void>(())

        /// - Parameter directory: injectable so the read-modify-write is testable without an App
        ///   Group entitlement, which a unit-test process doesn't have.
        init(
            fileName: String,
            directory: @escaping @Sendable () -> URL? = { PIATunnelSharedState.containerDirectory() },
            makeDefault: @escaping @Sendable () -> Value
        ) {
            self.fileName = fileName
            self.directory = directory
            self.makeDefault = makeDefault
        }

        /// The persisted value, or a default when the file is absent or unreadable.
        func read() -> Value {
            mutex.withLock { _ in readLocked() }
        }

        /// Replaces the persisted value wholesale.
        func write(_ value: Value) {
            let didWrite = mutex.withLock { _ in writeLocked(value) }

            if didWrite {
                PIATunnelSharedState.postDidChange()
            }
        }

        /// Reads, edits and writes back under the mutex, so no concurrent mutation in this process is
        /// lost. `body` returns `false` to skip the write, keeping an "only if changed" test atomic
        /// with the write it guards.
        func mutate(_ body: (inout Value) -> Bool) {
            let didWrite = mutex.withLock { _ in
                var value = readLocked()
                return body(&value) ? writeLocked(value) : false
            }

            if didWrite {
                PIATunnelSharedState.postDidChange()
            }
        }

        /// Removes the file, so the next `read()` returns defaults.
        func delete() {
            let didDelete = mutex.withLock { _ in deleteLocked() }

            if didDelete {
                PIATunnelSharedState.postDidChange()
            }
        }

        // MARK: Guarded primitives

        private func fileURL() -> URL? {
            directory()?.appendingPathComponent(fileName)
        }

        private func readLocked() -> Value {
            guard let url = fileURL(),
                let data = try? Data(contentsOf: url),
                let value = try? JSONDecoder().decode(Value.self, from: data)
            else {
                return makeDefault()
            }
            return value
        }

        private func writeLocked(_ value: Value) -> Bool {
            guard let url = fileURL() else {
                log.error("Failed to write \(fileName): no container URL for app group \(AppConstants.appGroup)")
                return false
            }
            let data: Data
            do {
                data = try JSONEncoder().encode(value)
            } catch {
                log.error("Failed to encode \(fileName): \(error)")
                return false
            }
            do {
                // `.atomic` prevents torn reads only; serialization is `mutex` + single-writer ownership.
                try data.write(to: url, options: .atomic)
                return true
            } catch {
                log.error("Failed to write \(fileName) at \(url.path): \(error)")
                return false
            }
        }

        private func deleteLocked() -> Bool {
            guard let url = fileURL() else {
                log.error("Failed to delete \(fileName): no container URL for app group \(AppConstants.appGroup)")
                return false
            }
            do {
                try FileManager.default.removeItem(at: url)
                return true
            } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError {
                // Already cleared or never written — not an error.
                return false
            } catch {
                log.error("Failed to delete \(fileName) at \(url.path): \(error)")
                return false
            }
        }
    }
}
