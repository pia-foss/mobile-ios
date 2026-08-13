//
//  ServersDaemon.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
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

#if os(iOS)
    import UIKit
#endif

private let log = PIALogger.logger(for: ServersDaemon.self)

extension ServersDaemon {
    private enum Constants {
        static let downloadTimeout: UInt64 = 60 * NSEC_PER_SEC
    }

    private enum WakeSignal {
        case serversMayBeStale
        case pingOnly
    }

    typealias DownloadResult = (servers: [Server]?, error: Error?)
    typealias DownloadServers = @Sendable () async -> DownloadResult
    typealias Sleep = @Sendable (UInt64) async -> Void
}

/// Keeps the server list fresh.
///
/// The cadence is owned by a single `loopTask` that alternates between evaluating staleness and
/// sleeping. Notifications and callers never reschedule anything themselves; they only `wake()` the
/// loop, which then re-evaluates. The previous design recreated a `DispatchSourceTimer` from five
/// call sites across two thread families, and racing threads would release a source that had not
/// been resumed yet — a libdispatch trap.
internal actor ServersDaemon: Daemon, ConfigurationAccess, DatabaseAccess, ProvidersAccess {
    static let shared = ServersDaemon()

    private let downloadServers: DownloadServers
    private let sleep: Sleep
    private let downloadTimeout: UInt64

    private var hasEnabledUpdates = false
    private var lastUpdateDate: Date?
    private var lastPingDate: Date?

    private var loopTask: Task<Void, Never>?
    private var sleepTask: Task<Void, Never>?

    private var inflightUpdate: Task<DownloadResult, Never>?
    private var inflightGeneration = 0
    private var observationTasks: [Task<Void, Never>] = []

    init(
        downloadServers: DownloadServers? = nil,
        sleep: Sleep? = nil,
        downloadTimeout: UInt64? = nil
    ) {
        self.downloadServers = downloadServers ?? Self.downloadFromCurrentProvider
        self.sleep = sleep ?? { try? await Task.sleep(nanoseconds: $0) }
        self.downloadTimeout = downloadTimeout ?? Constants.downloadTimeout
    }

    // MARK: - Daemon

    nonisolated func start() {
        Task {
            await beginObserving()
        }
    }

    nonisolated func enableUpdates() {
        Task {
            await enableUpdatesIfNeeded()
        }
    }

    // MARK: - Lifecycle

    func forceUpdates() async throws {
        guard !hasEnabledUpdates else {
            log.debug("Updates already enabled, skipping forced update")
            return
        }
        hasEnabledUpdates = true

        defer {
            startUpdateLoop()
        }

        try await refresh()
    }

    func reset() async {
        loopTask?.cancel()
        loopTask = nil
        sleepTask?.cancel()
        sleepTask = nil
        inflightUpdate?.cancel()
        inflightUpdate = nil
        inflightGeneration += 1
        lastUpdateDate = nil
        lastPingDate = nil
        hasEnabledUpdates = false
    }

    private func enableUpdatesIfNeeded() {
        guard !hasEnabledUpdates else {
            return
        }
        hasEnabledUpdates = true

        startUpdateLoop()
    }

    private func startUpdateLoop() {
        loopTask?.cancel()
        sleepTask?.cancel()

        loopTask = Task {
            await runUpdateLoop()
        }
    }

    // MARK: - Update loop

    private func runUpdateLoop() async {
        while !Task.isCancelled {
            let delay = await nextUpdateDelay()

            guard !Task.isCancelled else {
                return
            }
            await sleepInterruptibly(milliseconds: delay)
        }
    }

    private func nextUpdateDelay() async -> Int {
        let pollInterval = accessedDatabase.transient.serversConfiguration.pollInterval
        log.debug("Poll interval is \(pollInterval)")

        if let lastUpdateDate = lastUpdateDate {
            let elapsed = Int(-lastUpdateDate.timeIntervalSinceNow * 1000.0)
            guard elapsed >= pollInterval else {
                let leftDelay = pollInterval - elapsed
                log.debug(
                    "Elapsed \(elapsed) milliseconds (< \(pollInterval)) since last update (\(lastUpdateDate)), retrying in \(leftDelay) milliseconds..."
                )

                return leftDelay
            }
        } else {
            log.debug("Never updated so far, updating now...")
        }

        guard accessedDatabase.transient.isNetworkReachable else {
            let delay = accessedConfiguration.serversUpdateWhenNetworkDownDelay
            log.debug("Not updating when network is down, retrying in \(delay) milliseconds...")
            return delay
        }

        try? await refresh()

        return accessedDatabase.transient.serversConfiguration.pollInterval
    }

    private func sleepInterruptibly(milliseconds: Int) async {
        let nanoseconds = UInt64(max(0, milliseconds)) * NSEC_PER_MSEC
        let task = Task { [sleep] in
            await sleep(nanoseconds)
        }
        sleepTask = task
        await task.value
        sleepTask = nil
    }

    private func wake() {
        sleepTask?.cancel()
    }

    // MARK: - Downloading

    private func refresh() async throws {
        let result = await runDeduplicatedDownload()

        let updateDate = Date()
        lastUpdateDate = updateDate
        let pollInterval = accessedDatabase.transient.serversConfiguration.pollInterval
        log.debug("Servers updated on \(updateDate), will repeat in \(pollInterval) milliseconds")

        if let servers = result.servers {
            pingIfOffline(servers: servers)
        } else if let error = result.error as? ClientError, error == ClientError.noRegions {
            pingIfOffline(servers: accessedProviders.serverProvider.currentServers)
        }

        if let error = result.error {
            throw error
        }
    }

    private func runDeduplicatedDownload() async -> DownloadResult {
        // Join an in-flight download instead of starting a second one.
        if let inflightUpdate = inflightUpdate {
            log.debug("Servers download already in flight, joining it")
            return await inflightUpdate.value
        }

        inflightGeneration += 1
        let generation = inflightGeneration
        let task = Task {
            await downloadWithWatchdog()
        }
        inflightUpdate = task

        let result = await task.value

        // Only the owning call clears the slot; reset() may have installed a newer generation.
        if inflightGeneration == generation {
            inflightUpdate = nil
        }

        return result
    }

    private func downloadWithWatchdog() async -> DownloadResult {
        let outcome = DownloadOutcome()

        let download = Task { [downloadServers] in
            outcome.resume(with: await downloadServers())
        }

        let watchdog = Task { [downloadTimeout] in
            try? await Task.sleep(nanoseconds: downloadTimeout)
            log.error("Servers download did not call back within the timeout")
            outcome.resume(with: (nil, ClientError.libraryError(message: "Servers download timed out")))
        }

        let result = await outcome.value()

        download.cancel()
        watchdog.cancel()

        return result
    }

    private static let downloadFromCurrentProvider: DownloadServers = {
        let outcome = DownloadOutcome()
        Client.providers.serverProvider.download { servers, error in
            outcome.resume(with: (servers, error))
        }
        return await outcome.value()
    }

    // MARK: - Pings

    private func pingIfOffline(servers: [Server]) {
        guard accessedConfiguration.enablesServerPings else {
            return
        }

        if let last = lastPingDate {
            let elapsed = Int(-last.timeIntervalSinceNow * 1000.0)
            guard elapsed >= accessedConfiguration.minPingInterval else {
                log.debug(
                    "Not pinging servers before \(accessedConfiguration.minPingInterval) milliseconds (elapsed: \(elapsed))"
                )
                return
            }
        }
        lastPingDate = Date()

        // pings must be issued when VPN is NOT active to avoid biased response times
        guard accessedDatabase.transient.vpnStatus == .disconnected else {
            log.debug("Not pinging servers while on VPN, will try on next update")
            return
        }
        log.debug("Start pinging servers")

        // Deliberately not awaited: the update cadence must not wait on a full ping pass.
        Task {
            await ServersPinger.shared.ping(withDestinations: servers)
        }
    }

    // MARK: Notifications

    private func beginObserving() {
        guard observationTasks.isEmpty else {
            return
        }

        var tasks = [
            observationTask(for: .ConnectivityDaemonDidGetReachable, signal: .serversMayBeStale),
            observationTask(for: .PIADaemonsDidUpdateVPNStatus, signal: .serversMayBeStale)
        ]
        #if os(iOS)
            tasks.append(
                observationTask(for: UIApplication.didBecomeActiveNotification, signal: .pingOnly)
            )
        #endif
        observationTasks = tasks
    }

    private func observationTask(for name: Notification.Name, signal: WakeSignal) -> Task<Void, Never> {
        Task { [weak self] in
            // Mapped to Void: the notification itself is never read, only used as a signal.
            for await _ in NotificationCenter.default.notifications(named: name).map({ _ in () }) {
                guard let self = self else {
                    return
                }
                await self.handle(signal)
            }
        }
    }

    private func handle(_ signal: WakeSignal) {
        guard hasEnabledUpdates else {
            return
        }

        switch signal {
        case .serversMayBeStale:
            wake()
        case .pingOnly:
            break
        }

        pingIfOffline(servers: accessedProviders.serverProvider.currentServers)
    }
}

private final class DownloadOutcome: @unchecked Sendable {
    private struct State {
        var continuation: CheckedContinuation<ServersDaemon.DownloadResult, Never>?
        var pending: ServersDaemon.DownloadResult?
        var isResolved = false
    }

    private var state = Mutex(State())

    func value() async -> ServersDaemon.DownloadResult {
        await withCheckedContinuation { continuation in
            state.withLock { state in
                guard let pending = state.pending else {
                    state.continuation = continuation
                    return
                }
                state.pending = nil
                state.isResolved = true
                continuation.resume(returning: pending)
            }
        }
    }

    func resume(with result: ServersDaemon.DownloadResult) {
        state.withLock { state in
            guard !state.isResolved, state.pending == nil else {
                return
            }
            guard let continuation = state.continuation else {
                state.pending = result
                return
            }
            state.continuation = nil
            state.isResolved = true
            continuation.resume(returning: result)
        }
    }
}
