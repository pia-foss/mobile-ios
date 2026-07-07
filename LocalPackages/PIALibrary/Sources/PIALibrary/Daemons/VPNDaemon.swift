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

final class VPNDaemon: Daemon, DatabaseAccess, ProvidersAccess {
    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    private var fallbackTimer: Timer!
    private var numberOfAttempts: Int
    private var isReconnecting: Bool
    private var isReconnectingAfterConnectivityFailure: Bool = false
    private var lastKnownVpnStatus: VPNStatus = .disconnected

    private init() {
        hasEnabledUpdates = false
        isReconnecting = false
        numberOfAttempts = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(neStatusDidChange(notification:)), name: .NEVPNStatusDidChange, object: nil)

        // PlatformSDK tunnel: an in-place region switch (and mid-session reconnect) keeps NEVPNStatus
        // at `.connected`, so `.NEVPNStatusDidChange` never fires. The extension instead writes its
        // live status into `PIATunnelSharedState`; fold that into `transient.vpnStatus` so the app's
        // single source of truth reflects "Connecting" during a switch. Legacy tunnels don't write
        // it and this observer isn't registered — their status stays purely NEVPNStatus-driven.
        if Client.configuration.featureFlags[.usePlatformSDKVPN] {
            PIATunnelSharedState.startObserving()
            nc.addObserver(self, selector: #selector(platformSDKTunnelStatusDidChange), name: PIATunnelSharedState.didChangeNotification, object: nil)
        }

        do {
            try accessedProviders.vpnProvider.prepare()
        } catch {
            log.error("Failed to prepare VPN provider: \(error.localizedDescription)")
        }

        if Client.providers.vpnProvider.isVPNConnected {
            self.lastKnownVpnStatus = .connected
        }
    }

    /// Folds the PlatformSDK tunnel's reported status (`PIATunnelSharedState.tunnelStatus`) into
    /// `transient.vpnStatus` via the shared `VPNStatus.resolve(system:tunnel:)` table. This is the
    /// only signal for an in-place switch / mid-session reconnect, where NEVPNStatus stays
    /// `.connected` and `.NEVPNStatusDidChange` never fires.
    ///
    /// The "is the tunnel up" gate is `VPNIPAddressFromInterfaces()` — the live tunnel interface —
    /// NOT the `NETunnelProviderManager` connection status. The manager loads asynchronously, so on a
    /// cold relaunch (tunnel still alive) it isn't available yet and an early write-back would be
    /// dropped; the interface is present immediately. With the interface up the tunnel exists, so we
    /// pass `system: .connected` and let `resolve` layer the tunnel's `.connecting` nuance on top.
    /// The `tunnelStatus != nil` guard means teardown (which clears it) is left to the NEVPNStatus
    /// path, and it ignores a stale write-back while disconnected (no interface).
    @objc private func platformSDKTunnelStatusDidChange() {
        guard let tunnel = PIATunnelSharedState.read().tunnelStatus, VPNIPAddressFromInterfaces() != nil else {
            return
        }

        let resolvedStatus = VPNStatus.resolve(system: .connected, tunnel: tunnel)
        guard resolvedStatus != accessedDatabase.transient.vpnStatus else {
            return
        }
        accessedDatabase.transient.vpnStatus = resolvedStatus

        // Safety net for adopting a live tunnel whose start we never observed (the NEVPNStatus path
        // only records this on a `.disconnected → .connected` transition). Seeding at cold launch
        // normally sets this first, so this only fills the rare case where the write-back is what
        // flips us to `.connected`. No `connectedDate` is available here, so fall back to now; only
        // fill a missing value so an accurate timestamp is preserved. Drives the "Protected | <time>"
        // label — see the matching backfill in `DefaultVPNProvider.seedInitialVPNStatus`.
        if resolvedStatus == .connected, Client.preferences.lastVPNConnectionSuccess == nil {
            Client.preferences.lastVPNConnectionSuccess = Date().timeIntervalSince1970
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

        // Captured before the switch below, which resets the flag when the
        // .disconnected transition of a manual disconnect is processed. The
        // last-disconnect-error handling further down must still know that the
        // disconnect was user-initiated.
        let disconnectedManually = Client.configuration.disconnectedManually

        switch connection.status {
        case .connected:
            nextStatus = .connected
            Client.preferences.timeToConnectVPN = Date().timeIntervalSince1970 - Client.preferences.lastVPNConnectionAttempt

            let previousStatus = accessedDatabase.transient.vpnStatus

            guard (nextStatus != previousStatus) else {
                return
            }

            isReconnectingAfterConnectivityFailure = false
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

            nextStatus = .connecting
            // If a reconnect cycle was in progress, it has now successfully reached
            // .connecting — clear the flag here instead of in the reconnect callback so
            // that the intermediate .disconnecting → .disconnected status changes are
            // suppressed (isReconnecting=true) and vpnStatus never briefly touches
            // .disconnected between the two connecting states.
            isReconnecting = false
            // Reset the attempt counter each time we enter .connecting so that each
            // new connection attempt starts fresh. This preserves the retry-indefinitely
            // behaviour for unreachable servers: the fallback timer fires every 5s,
            // marking one IP unavailable per tick, so the counter resets when the next
            // .connecting status arrives and the cycle can continue without hitting max.
            if numberOfAttempts > 0 {
                numberOfAttempts = 0
                updateUIWithAttemptNumber(0)
            }
            Client.preferences.lastVPNConnectionAttempt = Date().timeIntervalSince1970

            if accessedDatabase.transient.vpnStatus == .disconnected,
                self.lastKnownVpnStatus == .disconnected,
                Client.preferences.shareServiceQualityData
            {
                ServiceQualityManager.shared.connectionAttemptEvent()
            }

            if fallbackTimer == nil {
                log.debug("Setting up fallbackTimer...")

                fallbackTimer = Timer.scheduledTimer(withTimeInterval: Client.configuration.vpnConnectivityRetryDelay, repeats: true) { [weak self] timer in
                    guard let self else { return }
                    log.debug("Executing fallbackTimer...")

                    let address = try? Client.providers.serverProvider.targetServer.bestAddress()
                    address?.markServerAsUnavailable()

                    self.numberOfAttempts += 1
                    if self.numberOfAttempts < Client.configuration.vpnConnectivityMaxAttempts || self.isReconnectingAfterConnectivityFailure {
                        log.debug("NEVPNManager is still connecting. Reconnecting with a different server...")
                        self.updateUIWithAttemptNumber(self.numberOfAttempts)
                        self.isReconnecting = true
                        Client.providers.vpnProvider.reconnect(after: 0, forceDisconnect: true) { error in
                            if error != nil {
                                // Reconnect initiation failed — clear flag immediately so the
                                // subsequent .disconnected status change can clean up normally.
                                self.isReconnecting = false
                            }
                            // On success: leave isReconnecting=true. It will be cleared in
                            // tryUpdateStatus when .connecting status arrives, ensuring that
                            // the intermediate .disconnecting → .disconnected transitions do
                            // not briefly expose vpnStatus = .disconnected to the rest of the app.
                        }
                    } else {
                        log.debug("Max number of VPN reconnections. Disconnecting...")
                        Client.providers.vpnProvider.disconnect { error in
                            Macros.postNotification(.PIAVPNDidFail)
                            self.reset()
                            self.invalidateTimer()
                        }
                    }
                }

            }

        case .disconnecting:
            nextStatus = .disconnecting

        case .disconnected:
            nextStatus = .disconnected

            let previousStatus = accessedDatabase.transient.vpnStatus

            guard (nextStatus != previousStatus) else {
                return
            }

            // No internet while a connection was already in progress: keep trying
            // indefinitely instead of giving up. Reaching this point means the previous
            // status was not .disconnected, so a connection attempt (or an established
            // connection) was underway. Force the status back to .connecting and keep
            // the fallback timer alive — recreating it if it was already invalidated —
            // so we reconnect as soon as the network becomes reachable again.
            // Skipped when the user disconnected manually.
            if !accessedDatabase.transient.isNetworkReachable,
                !Client.configuration.disconnectedManually
            {
                // The PlatformSDK tunnel handles transient network loss internally via
                // KapePathReconnector. For legacy protocols, force the status back to
                // .connecting and keep the fallback timer alive.
                guard !Client.configuration.featureFlags[.usePlatformSDKVPN] else {
                    isReconnecting = false
                    invalidateTimer()
                    reset()
                    return
                }

                log.debug("No internet while connecting — staying in .connecting and keeping the retry timer alive")
                isReconnecting = true
                scheduleFallbackTimerIfNeeded()

                accessedDatabase.plain.lastKnownVpnStatus = .connecting
                if previousStatus != .connecting {
                    accessedDatabase.transient.vpnStatus = .connecting
                }
                return
            }

            // A manual disconnect must always tear down the retry loop, even mid-reconnect
            // (isReconnecting == true), otherwise the fallback timer would keep firing and
            // force the status back to .connecting after the user asked to disconnect.
            if !isReconnecting || Client.configuration.disconnectedManually {
                invalidateTimer()
                reset()
            }

            //triggered only when the user is manually aborting connection (before being established).
            if Client.configuration.disconnectedManually {
                isReconnectingAfterConnectivityFailure = false

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

        // Resolve through the shared table so the NEVPNStatus path and the PlatformSDK write-back
        // fold agree on one combination. For legacy protocols `tunnel` is nil, so this is exactly the
        // pure `NEVPNStatus` mapping computed above (no behaviour change); for the PlatformSDK tunnel
        // it layers the `.connecting` nuance if the tunnel is mid-reconnect when this event fires.
        let tunnel = Client.configuration.featureFlags[.usePlatformSDKVPN] ? PIATunnelSharedState.read().tunnelStatus : nil
        let resolvedStatus = VPNStatus.resolve(system: connection.status, tunnel: tunnel)

        let previousStatus = accessedDatabase.transient.vpnStatus
        guard resolvedStatus != previousStatus else {
            return
        }

        accessedDatabase.plain.lastKnownVpnStatus = nextStatus

        if !isReconnecting {
            accessedDatabase.transient.vpnStatus = resolvedStatus
        }

        log.debug("[VPNDaemon] Fetching last disconnect error...")
        if let lastDisconnectError = connection.value(forKey: "_lastDisconnectError") as? NSError {
            log.debug("[VPNDaemon] fetchLastDisconnectError — domain=\(lastDisconnectError.domain) code=\(lastDisconnectError.code) description='\(lastDisconnectError.localizedDescription)'")

            // The PlatformSDK tunnel handles reconnection internally via KapePathReconnector.
            // Skip all PIA-level disconnect-error handling: neither the mark-unavailable
            // reconnect nor .PIAVPNDidFail (the Dashboard observes the latter and calls
            // vpnProvider.disconnect, which would tear down the SDK tunnel mid-recovery).
            guard !Client.configuration.featureFlags[.usePlatformSDKVPN] else { return }

            let errorDomain = lastDisconnectError.domain
            let errorCode = lastDisconnectError.code
            var connectivityCheckFailed = false

            // WireGuard connectivity check failure
            #if canImport(PIAWireguard)
                if errorDomain == PacketTunnelProviderError.errorDomain, errorCode == PacketTunnelProviderError.connectivityCheckFailed.errorCode {
                    connectivityCheckFailed = true
                }
            #endif

            // OpenVPN connectivity check failure.
            // The Kape TunnelKit fork dropped PIA's bespoke `connectivityCheckFailed`
            // error, so there is no exact equivalent. Approximate the old behaviour by
            // treating the fork's connectivity-related disconnect reasons as a failed
            // check when the original Swift error survives bridging.
            // TODO: verify on device whether `_lastDisconnectError` preserves the
            // `TunnelKitOpenVPNError` type across the Network Extension boundary.
            #if canImport(PIAWireguard) && canImport(TunnelKitOpenVPN)
                if let openVPNError = lastDisconnectError as? TunnelKitOpenVPNError {
                    switch openVPNError {
                    case .timeout, .networkChanged, .exhaustedEndpoints, .socketActivity:
                        connectivityCheckFailed = true
                    default:
                        break
                    }
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

            log.debug("[VPNDaemon] connectivityCheckFailed=\(connectivityCheckFailed) previousStatus=\(previousStatus)")

            if connectivityCheckFailed {
                log.debug("[VPNDaemon] connectivityCheckFailed — marking current server as unavailable and triggering reconnect")

                if let lastConnectedCN = accessedDatabase.plain.lastServerCN {
                    let targetRegion = try? Client.providers.serverProvider.targetServer
                    let lastConnectedServer = targetRegion?.addresses().first(where: { $0.cn == lastConnectedCN })
                    lastConnectedServer?.markServerAsUnavailable()
                }

                isReconnectingAfterConnectivityFailure = true
                Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true, nil)
            } else {
                if previousStatus == .connecting {
                    log.error("The VPN did fail \(lastDisconnectError)")
                    Macros.postNotification(.PIAVPNDidFail)
                }
            }
        } else {
            log.debug("[VPNDaemon] fetchLastDisconnectError — no error reported (clean disconnect)")
        }
    }

    // MARK: Fallback timer

    /// Schedules the repeating reconnection timer if it is not already running.
    /// The timer fires every `vpnConnectivityRetryDelay` seconds, marking the current
    /// server as unavailable and attempting a reconnect. It keeps retrying while there
    /// are attempts left, while there is no internet, or while recovering from a
    /// connectivity failure; otherwise it gives up and disconnects.
    private func scheduleFallbackTimerIfNeeded() {
        guard fallbackTimer == nil else { return }
        // The PlatformSDK tunnel handles reconnection internally via KapePathReconnector
        // and KapeSessionController, which cycles through all configured endpoints.
        // Avoid double-reconnecting by suppressing the PIA-level fallback timer.
        guard !Client.configuration.featureFlags[.usePlatformSDKVPN] else { return }
        log.debug("Setting up fallbackTimer...")

        fallbackTimer = Timer.scheduledTimer(withTimeInterval: Client.configuration.vpnConnectivityRetryDelay, repeats: true) { [weak self] timer in
            guard let self else { return }
            log.debug("Executing fallbackTimer...")

            let address = try? Client.providers.serverProvider.targetServer.bestAddress()
            address?.markServerAsUnavailable()

            self.numberOfAttempts += 1

            let shouldKeepTrying =
                numberOfAttempts < Client.configuration.vpnConnectivityMaxAttempts
                || !accessedDatabase.transient.isNetworkReachable
                || isReconnectingAfterConnectivityFailure

            if shouldKeepTrying {
                log.debug("NEVPNManager is still connecting. Reconnecting with a different server...")
                self.updateUIWithAttemptNumber(self.numberOfAttempts)
                self.isReconnecting = true
                Client.providers.vpnProvider.reconnect(forceDisconnect: true) { error in
                    if let clientError = error as? ClientError, clientError == .internetUnreachable {
                        self.isReconnecting = true
                        self.isReconnectingAfterConnectivityFailure = true

                    } else if error != nil {
                        // Reconnect initiation failed — clear flag immediately so the
                        // subsequent .disconnected status change can clean up normally.
                        self.isReconnecting = false
                    }
                    // On success: leave isReconnecting=true. It will be cleared in
                    // tryUpdateStatus when .connecting status arrives, ensuring that
                    // the intermediate .disconnecting → .disconnected transitions do
                    // not briefly expose vpnStatus = .disconnected to the rest of the app.
                }
            } else {
                log.debug("Max number of VPN reconnections. Disconnecting...")
                Client.providers.vpnProvider.disconnect { error in
                    Macros.postNotification(.PIAVPNDidFail)
                    self.reset()
                    self.invalidateTimer()
                }
            }
        }
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
