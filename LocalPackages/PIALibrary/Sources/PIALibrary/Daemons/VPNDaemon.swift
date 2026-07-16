//
//  VPNDaemon.swift
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
import NetworkExtension

#if canImport(PIAWireguard) && canImport(TunnelKitOpenVPN)
    import PIAWireguard
    import TunnelKitOpenVPN
#endif

private let log = PIALogger.logger(for: VPNDaemon.self)

// MARK: - Retry policy

struct VPNFallbackPolicy {
    let initialDelay: TimeInterval
    let maximumDelay: TimeInterval
    let maximumAttempts: Int

    func delay(afterFailedAttempts failedAttempts: Int) -> TimeInterval {
        let multiplier = pow(2.0, Double(max(0, failedAttempts)))
        return min(initialDelay * multiplier, maximumDelay)
    }

    func shouldRetry(afterFailedAttempts failedAttempts: Int) -> Bool {
        failedAttempts < maximumAttempts
    }

    /// Whether to reconnect or give up after a failed/dropped attempt.
    ///
    /// - No internet → give up. There is nothing to leak while fully offline, and waiting for a
    ///   reachability signal can deadlock behind the kill switch (the bug this work fixes).
    /// - Internet reachable + the user already had an established connection to preserve
    ///   (`hasEstablishedConnection`) → keep reconnecting indefinitely. Abandoning a connection the
    ///   user chose would silently expose them to leaks; the delay is already capped, so retrying
    ///   forever does not storm.
    /// - Internet reachable + no established connection yet (a cold connect) → bounded by the
    ///   attempt cap, then give up.
    func decision(
        afterFailedAttempts failedAttempts: Int,
        internetIsReachable: Bool,
        hasEstablishedConnection: Bool
    ) -> VPNRetryDecision {
        guard internetIsReachable else { return .giveUp }
        if hasEstablishedConnection { return .reconnect }
        return shouldRetry(afterFailedAttempts: failedAttempts) ? .reconnect : .giveUp
    }
}

enum VPNRetryDecision: Equatable {
    case reconnect
    case giveUp
}

// MARK: - Terminal-disconnect policy

/// Decides whether an observed `.disconnected` should terminate the retry cycle.
///
/// A forced reconnect is implemented as `disconnect { connect }` (see `DefaultVPNProvider.reconnect`),
/// so it surfaces an intermediate `.disconnected` with `previousStatus == .connecting` while
/// `isReconnecting` is still set — status updates are suppressed during a reconnect. That teardown
/// must never be classified as a failed connect, otherwise the bounded 20/40/60 backoff gives up on
/// its own first reconnect and never reaches attempts 2–3.
enum TerminalDisconnectPolicy {
    /// A `.disconnected` carrying no connectivity error. Give up only for a genuine connect attempt:
    /// not an intermediate reconnect teardown, and not a manual disconnect (handled elsewhere).
    static func shouldGiveUpOnCleanDisconnect(
        previousStatus: VPNStatus,
        isReconnecting: Bool,
        wasDisconnectedManually: Bool
    ) -> Bool {
        previousStatus == .connecting && !isReconnecting && !wasDisconnectedManually
    }

    /// A `.disconnected` carrying a non-connectivity error. Same reconnect-teardown guard applies.
    static func shouldGiveUpOnGenericError(
        previousStatus: VPNStatus,
        isReconnecting: Bool
    ) -> Bool {
        previousStatus == .connecting && !isReconnecting
    }
}

// MARK: - Give-up state

struct VPNGiveUpState {
    private(set) var isActive = false
    private(set) var disconnectCompleted = false
    private(set) var reachedDisconnected = false

    var isComplete: Bool {
        isActive && disconnectCompleted && reachedDisconnected
    }

    mutating func begin(connectionIsDisconnected: Bool) {
        isActive = true
        disconnectCompleted = false
        reachedDisconnected = connectionIsDisconnected
    }

    mutating func recordDisconnectCompletion(connectionIsSettled: Bool) {
        disconnectCompleted = true
        reachedDisconnected = reachedDisconnected || connectionIsSettled
    }

    mutating func recordDisconnected() {
        reachedDisconnected = true
    }

    mutating func reset() {
        isActive = false
        disconnectCompleted = false
        reachedDisconnected = false
    }
}

final class VPNDaemon: Daemon, DatabaseAccess, ProvidersAccess {

    // MARK: - Properties

    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    private var fallbackTimer: Timer!
    private var giveUpWatchdog: Timer?
    private var numberOfAttempts: Int
    private var isReconnecting: Bool
    private var lastKnownVpnStatus: VPNStatus = .disconnected
    private var giveUpState = VPNGiveUpState()

    /// True once the current VPN session has actually reached `.connected` — i.e. the user has an
    /// established connection they expect to keep. While this holds and the internet is reachable,
    /// a dropped tunnel is retried indefinitely (with backoff) instead of giving up: abandoning it
    /// would silently expose the user to leaks after they chose to be protected. It is a session
    /// latch on purpose — it survives the intermediate teardowns of recovery reconnects (so it is
    /// NOT cleared in `reset()`) and is cleared only when we truly stop: a manual disconnect or a
    /// terminal give-up.
    private var didReachConnected = false

    private var isGivingUp: Bool {
        giveUpState.isActive
    }

    // MARK: - Lifecycle

    private init() {
        hasEnabledUpdates = false
        isReconnecting = false
        numberOfAttempts = 0
    }

    func start() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(neStatusDidChange(notification:)), name: .NEVPNStatusDidChange, object: nil)

        do {
            try accessedProviders.vpnProvider.prepare()
        } catch {
            log.error("Failed to prepare VPN provider: \(error.localizedDescription)")
        }

        if Client.providers.vpnProvider.isVPNConnected {
            self.lastKnownVpnStatus = .connected
            // The app relaunched onto an already-established session the user expects to keep.
            self.didReachConnected = true
        }
    }

    // MARK: - Status updates

    private func tryUpdateStatus(via connection: NEVPNConnection) {
        guard let profile = accessedDatabase.transient.activeVPNProfile else {
            return
        }
        if let session = connection as? NETunnelProviderSession {
            guard profile.isTunnel else {
                return
            }
            // Verify the connection belongs to the active profile's loaded manager.
            // Without this, NEVPNStatusDidChange events from other tunnel providers
            // (e.g. a previously installed OpenVPN profile being cleaned up on startup)
            // pass the isTunnel check and incorrectly reset vpnStatus to .disconnected
            // while WireGuard is still connected.
            //
            // When tryUpdateStatus runs (via DispatchQueue.main.async), the active
            // profile's loadAllFromPreferences callback has always already completed
            // and set profile.native, so this guard is safe to make strict.
            guard
                let activeManager = profile.native as? NETunnelProviderManager,
                session.manager === activeManager
            else {
                return
            }
        } else {
            guard !profile.isTunnel else {
                return
            }
        }

        var nextStatus: VPNStatus = .disconnected
        var shouldGiveUpAfterStatusUpdate = false
        var observedGiveUpDisconnect = false
        var wasDisconnectedManually = false

        switch connection.status {
        case .connected:
            guard !isGivingUp else {
                log.debug("Stopping tunnel that connected while terminal disconnect was in progress")
                connection.stopVPNTunnel()
                return
            }

            nextStatus = .connected
            Client.preferences.timeToConnectVPN = Date().timeIntervalSince1970 - Client.preferences.lastVPNConnectionAttempt

            let previousStatus = accessedDatabase.transient.vpnStatus

            guard (nextStatus != previousStatus) else {
                return
            }

            Client.preferences.lastVPNConnectionSuccess = Date().timeIntervalSince1970
            invalidateTimer()
            reset()
            // Latch that the user now has a connection to preserve. Set after reset() (reset()
            // does not touch it) so it stays true across any later recovery reconnects.
            didReachConnected = true

            if self.lastKnownVpnStatus == .disconnected, Client.preferences.shareServiceQualityData {
                ServiceQualityManager.shared.connectionEstablishedEvent()
                self.lastKnownVpnStatus = .connected
            }

            //Connection successful, the user interaction finished
            Client.configuration.connectedManually = false

        case .connecting, .reasserting:

            guard !isGivingUp else {
                log.debug("Ignoring automatic reconnect while terminal disconnect is in progress")
                connection.stopVPNTunnel()
                return
            }

            nextStatus = .connecting
            // A fresh attempt is a genuine .disconnected → .connecting transition that we
            // did not initiate as part of a reconnect storm (isReconnecting == false). Only
            // then reset the storm-wide counter.
            // Gating on previousStatus == .disconnected is important: IKEv2 can oscillate
            // .connecting ⇄ .reasserting without passing through .disconnected, and
            // isReconnecting is cleared on the first .connecting — so relying on
            // isReconnecting alone would reset the counter mid-attempt and defeat the cap.
            if accessedDatabase.transient.vpnStatus == .disconnected, !isReconnecting {
                if numberOfAttempts > 0 {
                    numberOfAttempts = 0
                    updateUIWithAttemptNumber(0)
                }
            }
            // If a reconnect cycle was in progress, it has now successfully reached
            // .connecting — clear the flag here instead of in the reconnect callback so
            // that the intermediate .disconnecting → .disconnected status changes are
            // suppressed (isReconnecting=true) and vpnStatus never briefly touches
            // .disconnected between the two connecting states.
            isReconnecting = false
            Client.preferences.lastVPNConnectionAttempt = Date().timeIntervalSince1970

            if accessedDatabase.transient.vpnStatus == .disconnected,
                self.lastKnownVpnStatus == .disconnected,
                Client.preferences.shareServiceQualityData
            {
                ServiceQualityManager.shared.connectionAttemptEvent()
            }

        case .disconnecting:
            nextStatus = .disconnecting

        case .disconnected:
            nextStatus = .disconnected

            let previousStatus = accessedDatabase.transient.vpnStatus

            if isGivingUp {
                observedGiveUpDisconnect = true
                markGiveUpReachedDisconnected()
            }

            guard (nextStatus != previousStatus) else {
                return
            }

            wasDisconnectedManually = Client.configuration.disconnectedManually

            // Reachability is affected by the kill switch, so waiting for a reachable
            // notification here can deadlock forever. Stop the actual tunnel and disable
            // on-demand instead; a later user-initiated connection starts a fresh cycle.
            if !accessedDatabase.transient.isNetworkReachable,
                !wasDisconnectedManually,
                !observedGiveUpDisconnect
            {
                log.debug("No internet while connecting — terminating the retry cycle")
                shouldGiveUpAfterStatusUpdate = true
            }

            // A manual disconnect must always tear down the retry loop, even mid-reconnect
            // (isReconnecting == true), otherwise the fallback timer would keep firing and
            // force the status back to .connecting after the user asked to disconnect.
            if wasDisconnectedManually || previousStatus != .connecting {
                invalidateTimer()
                reset()
            } else {
                // Preserve the storm-wide attempt count until the disconnect error has
                // been classified, but never leave a watchdog attached to a dead session.
                invalidateTimer()
            }

            //triggered only when the user is manually aborting connection (before being established).
            if wasDisconnectedManually {
                if self.lastKnownVpnStatus != .connected,
                    (previousStatus == .connecting || previousStatus == .disconnecting),
                    Client.preferences.shareServiceQualityData
                {
                    ServiceQualityManager.shared.connectionCancelledEvent()
                }

                //VPN disconnected, the user interaction finished. Only reset the value when the source was manual.
                Client.configuration.disconnectedManually = false

                // The user chose to disconnect — there is no longer a connection to preserve.
                didReachConnected = false
            }

            Client.preferences.lastVPNConnectionSuccess = nil
            self.lastKnownVpnStatus = .disconnected

        default:
            nextStatus = .disconnected
        }

        let previousStatus = accessedDatabase.transient.vpnStatus
        guard (nextStatus != previousStatus) else {
            return
        }

        accessedDatabase.plain.lastKnownVpnStatus = nextStatus

        if !isReconnecting {
            accessedDatabase.transient.vpnStatus = nextStatus
        }

        // Arm the connect watchdog only after the status is committed to `.connecting`. Scheduling
        // earlier (mid-switch, before this update) silently no-ops, because the timer guard requires
        // `transient.vpnStatus == .connecting` — so a connect that hangs after a single `.connecting`
        // event would never be retried and the app would sit in "Connecting…" forever. Once armed,
        // each tick reschedules itself from the reconnect callbacks.
        if nextStatus == .connecting {
            scheduleFallbackTimerIfNeeded()
        }

        if observedGiveUpDisconnect {
            return
        }

        if shouldGiveUpAfterStatusUpdate {
            giveUp(connectionIsDisconnected: true)
            return
        }

        // `_lastDisconnectError` is sticky. Reading it while a new session is connecting
        // can misclassify an old teardown error as a failure of the replacement session.
        guard connection.status == .disconnected else {
            return
        }

        handleDisconnectError(
            on: connection,
            previousStatus: previousStatus,
            wasDisconnectedManually: wasDisconnectedManually
        )
    }

    /// Classifies a settled session's sticky `_lastDisconnectError` and drives the retry loop:
    /// rotate/reconnect on a connectivity-check failure, or give up on a genuine failed connect.
    /// A `.disconnected` observed mid-reconnect carries a stale error and is ignored so it is not
    /// double-counted against the attempt cap.
    private func handleDisconnectError(
        on connection: NEVPNConnection,
        previousStatus: VPNStatus,
        wasDisconnectedManually: Bool
    ) {
        log.debug("[VPNDaemon] Fetching last disconnect error...")

        guard let lastDisconnectError = connection.value(forKey: "_lastDisconnectError") as? NSError else {
            log.debug("[VPNDaemon] fetchLastDisconnectError — no error reported (clean disconnect)")
            if TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: previousStatus,
                isReconnecting: isReconnecting,
                wasDisconnectedManually: wasDisconnectedManually
            ) {
                giveUp(connectionIsDisconnected: true)
            }
            return
        }

        log.debug("[VPNDaemon] fetchLastDisconnectError — domain=\(lastDisconnectError.domain) code=\(lastDisconnectError.code) description='\(lastDisconnectError.localizedDescription)'")

        let connectivityCheckFailed = isConnectivityCheckFailure(
            domain: lastDisconnectError.domain,
            code: lastDisconnectError.code
        )
        log.debug("connectivityCheckFailed=\(connectivityCheckFailed) previousStatus=\(previousStatus)")

        guard connectivityCheckFailed else {
            if TerminalDisconnectPolicy.shouldGiveUpOnGenericError(
                previousStatus: previousStatus,
                isReconnecting: isReconnecting
            ) {
                log.error("The VPN did fail \(lastDisconnectError)")
                giveUp(connectionIsDisconnected: true)
            }
            return
        }

        guard !isReconnecting else {
            // A forced reconnect is already in flight; this .disconnected carries a stale
            // connectivity error from the session we just tore down. Ignore it so it is not
            // double-counted against the attempt cap.
            log.debug("connectivityCheckFailed ignored — reconnect already in progress")
            return
        }

        let wholeInternetIsReachable = accessedDatabase.transient.isNetworkReachable
        if wholeInternetIsReachable, let lastConnectedCN = accessedDatabase.plain.lastServerCN {
            log.debug("connectivityCheckFailed — marking current server as unavailable and triggering reconnect")
            let targetRegion = try? Client.providers.serverProvider.targetServer
            let lastConnectedServer = targetRegion?.addresses().first(where: { $0.cn == lastConnectedCN })
            lastConnectedServer?.markServerAsUnavailable()
        } else if !wholeInternetIsReachable {
            log.debug("There's no internet!")
        }

        numberOfAttempts += 1
        switch fallbackPolicy.decision(
            afterFailedAttempts: numberOfAttempts,
            internetIsReachable: wholeInternetIsReachable,
            hasEstablishedConnection: didReachConnected
        ) {
        case .giveUp:
            giveUp(connectionIsDisconnected: true)
        case .reconnect:
            startReconnect(context: "Connectivity-failure", giveUpConnectionIsDisconnected: true)
        }
    }

    /// Whether a Network Extension disconnect error is a tunnel connectivity-check failure for any
    /// of the three protocols (the signal that a server has gone unreachable), as opposed to a
    /// generic connect failure.
    private func isConnectivityCheckFailure(domain: String, code: Int) -> Bool {
        // WireGuard connectivity check failure
        #if canImport(PIAWireguard)
            if domain == PacketTunnelProviderError.errorDomain, code == PacketTunnelProviderError.connectivityCheckFailed.errorCode {
                return true
            }
        #endif

        // OpenVPN connectivity check failure
        #if canImport(TunnelKitOpenVPN)
            if domain == OpenVPNError.errorDomain, code == OpenVPNError.connectivityCheckFailed.errorCode {
                return true
            }
        #endif

        // IKEv2 connectivity check failure.
        // On tvOS, IKEv2 errors are reported under NEVPNConnectionErrorDomainPlugin
        // rather than NEVPNConnectionErrorDomain, so check both when IKEv2 is active.
        if #available(iOS 16, *) {
            if domain == NEVPNConnectionErrorDomain || domain == "NEVPNConnectionErrorDomainPlugin" {
                return true
            }
        }

        return false
    }

    // MARK: - Fallback timer & retries

    /// Delay before the next fallback tick. It grows with the number of attempts so the
    /// app backs off during a sustained outage instead of hammering servers. The first
    /// attempt gets the full `vpnConnectivityRetryDelay` budget so a slow-but-healthy
    /// connection (e.g. a cold-starting extension on older hardware) is not killed
    /// prematurely — which was the trigger for the reconnect storm.
    private func nextFallbackDelay() -> TimeInterval {
        fallbackPolicy.delay(afterFailedAttempts: numberOfAttempts)
    }

    private var fallbackPolicy: VPNFallbackPolicy {
        VPNFallbackPolicy(
            initialDelay: Client.configuration.vpnConnectivityRetryDelay,
            maximumDelay: Client.configuration.vpnConnectivityMaximumRetryDelay,
            maximumAttempts: Client.configuration.vpnConnectivityMaxAttempts
        )
    }

    /// Schedules the single-shot reconnection watchdog if it is not already running. Each
    /// replacement attempt receives a fresh, backed-off budget until `giveUp()` stops the loop.
    private func scheduleFallbackTimerIfNeeded() {
        guard
            fallbackTimer == nil,
            !isGivingUp,
            accessedDatabase.transient.vpnStatus == .connecting
        else {
            return
        }
        let delay = nextFallbackDelay()
        log.debug("Setting up fallbackTimer (delay=\(delay)s, attempt=\(numberOfAttempts))...")

        fallbackTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self else { return }
            // Single-shot: clear so the next attempt can reschedule with the next backoff step.
            self.fallbackTimer = nil
            self.handleFallbackTick()
        }
    }

    /// Fired when a connection attempt has used up its budget without reaching `.connected`.
    /// Marks the current server unavailable and either rotates to a different server (while
    /// attempts remain) or gives up.
    private func handleFallbackTick() {
        guard !isGivingUp, accessedDatabase.transient.vpnStatus == .connecting else {
            return
        }

        log.debug("Executing fallbackTimer...")

        numberOfAttempts += 1

        let internetIsReachable = accessedDatabase.transient.isNetworkReachable
        if internetIsReachable {
            let address = try? Client.providers.serverProvider.targetServer.bestAddress()
            address?.markServerAsUnavailable()
        }

        // Once the user has an established connection to preserve, keep rotating servers
        // indefinitely (the delay is already capped) rather than giving up. Only a cold connect
        // that never reached .connected is bounded by the attempt cap, and no internet always
        // gives up.
        guard
            case .reconnect = fallbackPolicy.decision(
                afterFailedAttempts: numberOfAttempts,
                internetIsReachable: internetIsReachable,
                hasEstablishedConnection: didReachConnected
            )
        else {
            log.debug("Connection attempt exhausted (reachable=\(internetIsReachable)). Giving up.")
            giveUp()
            return
        }

        log.debug("NEVPNManager is still connecting. Reconnecting with a different server (attempt \(numberOfAttempts))...")
        updateUIWithAttemptNumber(numberOfAttempts)
        startReconnect(context: "Fallback", giveUpConnectionIsDisconnected: false)
    }

    /// Issues a forced reconnect (`disconnect { connect }`). On success the fallback budget is
    /// re-armed for the new attempt; if the reconnect cannot even be initiated, the loop gives up.
    /// `giveUpConnectionIsDisconnected` matches the caller's context: `true` from the connectivity
    /// path (the session is already down), `false` from the fallback tick (still connecting).
    private func startReconnect(context: String, giveUpConnectionIsDisconnected: Bool) {
        isReconnecting = true
        Client.providers.vpnProvider.reconnect(forceDisconnect: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    log.error("\(context) reconnect could not start: \(error)")
                    self.giveUp(connectionIsDisconnected: giveUpConnectionIsDisconnected)
                } else {
                    // Start the next budget only after disconnect/save/start has completed.
                    self.scheduleFallbackTimerIfNeeded()
                }
            }
        }
    }

    // MARK: - Give up

    /// Stops the retry loop, disables on-demand, and tears down the real Network Extension
    /// session. Completion is tracked separately from the `.disconnected` status event so
    /// neither callback ordering nor a sticky kill switch can restart the cycle.
    private func giveUp(connectionIsDisconnected: Bool = false) {
        if isGivingUp {
            if connectionIsDisconnected {
                markGiveUpReachedDisconnected()
            }
            return
        }

        log.debug("Giving up active VPN reconnection cycle...")
        invalidateTimer()
        isReconnecting = false
        // Terminal stop: there is no longer a connection to preserve, so a later manual connect
        // starts a fresh, bounded cold-connect cycle rather than inheriting this latch.
        didReachConnected = false
        giveUpState.begin(connectionIsDisconnected: connectionIsDisconnected || activeConnectionIsSettled)
        scheduleGiveUpWatchdog()

        Client.providers.vpnProvider.disconnect { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    log.error("Terminal VPN disconnect completed with error: \(error)")
                }
                self.giveUpState.recordDisconnectCompletion(connectionIsSettled: self.activeConnectionIsSettled)
                Macros.postNotification(.PIAVPNDidFail)
                self.finishGivingUpIfPossible()
            }
        }
    }

    private var activeConnectionIsSettled: Bool {
        guard
            let profile = accessedDatabase.transient.activeVPNProfile,
            let manager = profile.native as? NEVPNManager
        else {
            return false
        }
        return TunnelRestartPolicy.canStartTunnel(from: manager.connection.status)
    }

    private func markGiveUpReachedDisconnected() {
        giveUpState.recordDisconnected()
        finishGivingUpIfPossible()
    }

    private func finishGivingUpIfPossible() {
        guard giveUpState.isComplete else { return }
        invalidateGiveUpWatchdog()
        giveUpState.reset()
        reset()
    }

    /// Failsafe so a give-up can never wedge the daemon permanently. `giveUp()` only completes
    /// once both the `disconnect` completion callback and a settled `.disconnected` are observed;
    /// if either signal never arrives, `isGivingUp` would stay true forever and silently kill
    /// every future user connect (see the `.connected`/`.connecting` short-circuits). If the
    /// terminal disconnect has not settled within `vpnDisconnectWaitTimeout`, force-reset so the
    /// daemon recovers in-session.
    private func scheduleGiveUpWatchdog() {
        invalidateGiveUpWatchdog()
        let timeout = Client.configuration.vpnDisconnectWaitTimeout
        giveUpWatchdog = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.giveUpWatchdog = nil
            guard self.isGivingUp else { return }
            log.error("Terminal VPN disconnect did not settle within \(timeout)s — force-resetting give-up state")
            self.giveUpState.reset()
            self.reset()
        }
    }

    private func invalidateGiveUpWatchdog() {
        giveUpWatchdog?.invalidate()
        giveUpWatchdog = nil
    }

    // MARK: - Invalidate timer

    private func invalidateTimer() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }

    // MARK: - Reset

    private func reset() {
        self.isReconnecting = false
        self.numberOfAttempts = 0
        self.updateUIWithAttemptNumber(0)
    }

    // MARK: - Update UI

    private func updateUIWithAttemptNumber(_ number: Int) {
        NotificationCenter.default.post(name: .PIADaemonsConnectingVPNStatus, object: number)
    }

    // MARK: - Notifications

    @objc private func neStatusDidChange(notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            fatalError("Missing NEVPNConnection object?")
        }
        DispatchQueue.main.async {
            self.tryUpdateStatus(via: connection)
        }
    }
}
