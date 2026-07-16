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
}

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
    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    private var fallbackTimer: Timer!
    private var giveUpWatchdog: Timer?
    private var numberOfAttempts: Int
    private var isReconnecting: Bool
    private var lastKnownVpnStatus: VPNStatus = .disconnected
    private var giveUpState = VPNGiveUpState()

    private var isGivingUp: Bool {
        giveUpState.isActive
    }

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
        }
    }

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

            scheduleFallbackTimerIfNeeded()

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

        log.debug("[VPNDaemon] Fetching last disconnect error...")
        if let lastDisconnectError = connection.value(forKey: "_lastDisconnectError") as? NSError {
            log.debug("[VPNDaemon] fetchLastDisconnectError — domain=\(lastDisconnectError.domain) code=\(lastDisconnectError.code) description='\(lastDisconnectError.localizedDescription)'")

            let errorDomain = lastDisconnectError.domain
            let errorCode = lastDisconnectError.code
            var connectivityCheckFailed = false

            // WireGuard connectivity check failure
            #if canImport(PIAWireguard)
                if errorDomain == PacketTunnelProviderError.errorDomain, errorCode == PacketTunnelProviderError.connectivityCheckFailed.errorCode {
                    connectivityCheckFailed = true
                }
            #endif

            // OpenVPN connectivity check failure
            #if canImport(TunnelKitOpenVPN)
                if errorDomain == OpenVPNError.errorDomain, errorCode == OpenVPNError.connectivityCheckFailed.errorCode {
                    connectivityCheckFailed = true
                }
            #endif

            // IKEv2 connectivity check failure.
            // On tvOS, IKEv2 errors are reported under NEVPNConnectionErrorDomainPlugin
            // rather than NEVPNConnectionErrorDomain, so check both when IKEv2 is active.
            if #available(iOS 16, *) {
                if errorDomain == NEVPNConnectionErrorDomain || errorDomain == "NEVPNConnectionErrorDomainPlugin" {
                    connectivityCheckFailed = true
                }
            }

            log.debug("connectivityCheckFailed=\(connectivityCheckFailed) previousStatus=\(previousStatus)")

            if connectivityCheckFailed, isReconnecting {
                // A forced reconnect is already in flight; this .disconnected carries a
                // stale connectivity error from the session we just tore down. Ignore it
                // so it is not double-counted against the attempt cap.
                log.debug("connectivityCheckFailed ignored — reconnect already in progress")
            } else if connectivityCheckFailed {
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
                if !wholeInternetIsReachable {
                    giveUp(connectionIsDisconnected: true)
                } else if fallbackPolicy.shouldRetry(afterFailedAttempts: numberOfAttempts) {
                    isReconnecting = true
                    Client.providers.vpnProvider.reconnect(forceDisconnect: true) { [weak self] error in
                        DispatchQueue.main.async {
                            guard let self else { return }
                            if let error {
                                log.error("Connectivity-failure reconnect could not start: \(error)")
                                self.giveUp(connectionIsDisconnected: true)
                            } else {
                                self.scheduleFallbackTimerIfNeeded()
                            }
                        }
                    }
                } else {
                    giveUp(connectionIsDisconnected: true)
                }
            } else {
                if TerminalDisconnectPolicy.shouldGiveUpOnGenericError(
                    previousStatus: previousStatus,
                    isReconnecting: isReconnecting
                ) {
                    log.error("The VPN did fail \(lastDisconnectError)")
                    giveUp(connectionIsDisconnected: true)
                }
            }
        } else {
            log.debug("[VPNDaemon] fetchLastDisconnectError — no error reported (clean disconnect)")
            if TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: previousStatus,
                isReconnecting: isReconnecting,
                wasDisconnectedManually: wasDisconnectedManually
            ) {
                giveUp(connectionIsDisconnected: true)
            }
        }
    }

    // MARK: Fallback timer

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

        guard accessedDatabase.transient.isNetworkReachable else {
            log.debug("Connection attempt timed out without internet. Giving up.")
            giveUp()
            return
        }

        let address = try? Client.providers.serverProvider.targetServer.bestAddress()
        address?.markServerAsUnavailable()

        guard fallbackPolicy.shouldRetry(afterFailedAttempts: numberOfAttempts) else {
            giveUp()
            return
        }

        log.debug("NEVPNManager is still connecting. Reconnecting with a different server (attempt \(numberOfAttempts))...")
        updateUIWithAttemptNumber(numberOfAttempts)
        isReconnecting = true
        Client.providers.vpnProvider.reconnect(forceDisconnect: true) { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    log.error("Fallback reconnect could not start: \(error)")
                    self.giveUp()
                } else {
                    // Start the next budget only after disconnect/save/start has completed.
                    self.scheduleFallbackTimerIfNeeded()
                }
            }
        }
    }

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

    // MARK: Invalidate
    private func invalidateTimer() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }

    // MARK: Reset

    private func reset() {
        self.isReconnecting = false
        self.numberOfAttempts = 0
        self.updateUIWithAttemptNumber(0)
    }

    // MARK: Update UI

    private func updateUIWithAttemptNumber(_ number: Int) {
        NotificationCenter.default.post(name: .PIADaemonsConnectingVPNStatus, object: number)
    }

    // MARK: Notifications

    @objc private func neStatusDidChange(notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else {
            fatalError("Missing NEVPNConnection object?")
        }
        DispatchQueue.main.async {
            self.tryUpdateStatus(via: connection)
        }
    }
}
