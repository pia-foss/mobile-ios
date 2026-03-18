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

private extension NEVPNStatus {
    var debugDescription: String {
        switch self {
        case .invalid:      return "invalid"
        case .disconnected: return "disconnected"
        case .connecting:   return "connecting"
        case .connected:    return "connected"
        case .reasserting:  return "reasserting"
        case .disconnecting: return "disconnecting"
        @unknown default:   return "unknown(\(rawValue))"
        }
    }
}

final class VPNDaemon: Daemon, DatabaseAccess, ProvidersAccess {
    static let shared = VPNDaemon()

    private(set) var hasEnabledUpdates: Bool
    private var fallbackTimer: Timer!
    private var changingServerTimer: Timer?
    private var numberOfAttempts: Int
    private var isReconnecting: Bool
    private var isChangingServer: Bool
    private var lastKnownVpnStatus: VPNStatus = .disconnected

    private init() {
        hasEnabledUpdates = false
        isReconnecting = false
        isChangingServer = false
        numberOfAttempts = 0
    }

    func start() {
        log.debug("[VPNDaemon] Starting — isVPNConnected=\(Client.providers.vpnProvider.isVPNConnected)")
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(neStatusDidChange(notification:)), name: .NEVPNStatusDidChange, object: nil)
        nc.addObserver(self, selector: #selector(vpnIsChangingServer(notification:)), name: .PIAVPNIsChangingServer, object: nil)

        do {
            try accessedProviders.vpnProvider.prepare()
        } catch {
            log.error("Faile to prepare VPN provider: \(error.localizedDescription)")
        }

        if Client.providers.vpnProvider.isVPNConnected {
            self.lastKnownVpnStatus = .connected
            log.debug("[VPNDaemon] Initial lastKnownVpnStatus set to .connected")
        }
    }

    private func tryUpdateStatus(via connection: NEVPNConnection) {
        let rawStatus = connection.status
        log.debug("[VPNDaemon] tryUpdateStatus — rawNEStatus=\(rawStatus.debugDescription) isReconnecting=\(isReconnecting) numberOfAttempts=\(numberOfAttempts) isChangingServer=\(isChangingServer) lastKnownVpnStatus=\(lastKnownVpnStatus)")

        guard let profile = accessedDatabase.transient.activeVPNProfile else {
            log.debug("[VPNDaemon] No active VPN profile, skipping status update")
            return
        }
        if let _ = connection as? NETunnelProviderSession {
            guard profile.isTunnel else {
                log.debug("[VPNDaemon] Connection is NETunnelProviderSession but profile is not tunnel, skipping")
                return
            }
        } else {
            guard !profile.isTunnel else {
                log.debug("[VPNDaemon] Connection is not NETunnelProviderSession but profile is tunnel, skipping")
                return
            }
        }

        var nextStatus: VPNStatus = .disconnected

        switch connection.status {
        case .connected:
            nextStatus = .connected
            Client.preferences.timeToConnectVPN = Date().timeIntervalSince1970 - Client.preferences.lastVPNConnectionAttempt

            let previousStatus = accessedDatabase.transient.vpnStatus

            guard (nextStatus != previousStatus) else {
                log.debug("[VPNDaemon] .connected — already connected, no-op")
                return
            }

            log.debug("[VPNDaemon] .connected — timeToConnect=\(Client.preferences.timeToConnectVPN)s attempts=\(numberOfAttempts)")
            Client.preferences.lastVPNConnectionSuccess = Date().timeIntervalSince1970
            invalidateTimer()
            reset()

            if self.lastKnownVpnStatus == .disconnected, Client.preferences.shareServiceQualityData {
                ServiceQualityManager.shared.connectionEstablishedEvent()
                self.lastKnownVpnStatus = .connected
            }

            //Connection successful, the user interaction finished
            Client.configuration.connectedManually = false

            // As connect has succeeded isChangingServer flag can now be turned off
            self.isChangingServer = false
            invalidateServerChangeTimer()

        case .connecting, .reasserting:
            nextStatus = .connecting
            log.debug("[VPNDaemon] .connecting/.reasserting — fallbackTimerActive=\(fallbackTimer != nil) currentVpnStatus=\(accessedDatabase.transient.vpnStatus)")
            Client.preferences.lastVPNConnectionAttempt = Date().timeIntervalSince1970

            if accessedDatabase.transient.vpnStatus == .disconnected,
               self.lastKnownVpnStatus == .disconnected,
               Client.preferences.shareServiceQualityData,
               self.numberOfAttempts == 0 {
                ServiceQualityManager.shared.connectionAttemptEvent()
            }

            if fallbackTimer == nil {
                log.debug("[VPNDaemon] Starting fallback timer — retryDelay=\(Client.configuration.vpnConnectivityRetryDelay)s maxAttempts=\(Client.configuration.vpnConnectivityMaxAttempts)")
                fallbackTimer = Timer.scheduledTimer(withTimeInterval: Client.configuration.vpnConnectivityRetryDelay, repeats: true) { timer in
                    let targetServer = try? Client.providers.serverProvider.targetServer
                    let address = try? targetServer?.bestAddress()
                    log.debug("[VPNDaemon] Fallback timer fired — attempt=\(self.numberOfAttempts + 1)/\(Client.configuration.vpnConnectivityMaxAttempts) targetServer='\(targetServer?.name ?? "nil")' bestAddress=\(address?.ip ?? "nil")")
                    address?.markServerAsUnavailable()

                    log.debug("[VPNDaemon] NEVPNManager is still connecting. Reconnecting with a different server...")
                    self.numberOfAttempts += 1
                    if self.numberOfAttempts < Client.configuration.vpnConnectivityMaxAttempts {
                        self.updateUIWithAttemptNumber(self.numberOfAttempts)
                        self.isReconnecting = true
                        log.debug("[VPNDaemon] Triggering reconnect (fallback timer) — attempt=\(self.numberOfAttempts)")
                        Client.providers.vpnProvider.reconnect(after: 0, { _ in
                            log.debug("[VPNDaemon] reconnect(after:0) callback — isReconnecting will be reset to false")
                            self.isReconnecting = false
                        })
                    } else {
                        log.debug("[VPNDaemon] MAX number of VPN reconnections (\(Client.configuration.vpnConnectivityMaxAttempts)) reached. Disconnecting...")
                        Client.providers.vpnProvider.disconnect({ error in
                            if let error {
                                log.error("[VPNDaemon] Disconnect after max attempts failed: \(error.localizedDescription)")
                            }
                            Macros.postNotification(.PIAVPNDidFail)
                            self.reset()
                            self.invalidateTimer()
                        })
                    }
                }
            } else {
                log.debug("[VPNDaemon] .connecting/.reasserting — fallback timer already active, not creating a new one")
            }

        case .disconnecting:
            nextStatus = .disconnecting
            log.debug("[VPNDaemon] .disconnecting — isReconnecting=\(isReconnecting)")

        case .disconnected:
            nextStatus = .disconnected

            let previousStatus = accessedDatabase.transient.vpnStatus

            guard (nextStatus != previousStatus) else {
                log.debug("[VPNDaemon] .disconnected — already disconnected, no-op")
                return
            }

            log.debug("[VPNDaemon] .disconnected — previousStatus=\(previousStatus) isReconnecting=\(isReconnecting) disconnectedManually=\(Client.configuration.disconnectedManually)")

            if !isReconnecting {
                log.debug("[VPNDaemon] .disconnected — not reconnecting, invalidating timer and resetting")
                invalidateTimer()
                reset()
            } else {
                log.debug("[VPNDaemon] .disconnected — isReconnecting=true, keeping timer alive")
            }

            //triggered only when the user is manually aborting connection (before being established).
            if Client.configuration.disconnectedManually {

                if self.lastKnownVpnStatus != .connected,
                   (previousStatus == .connecting || previousStatus == .disconnecting),
                   Client.preferences.shareServiceQualityData {
                    ServiceQualityManager.shared.connectionCancelledEvent()
                }

                //VPN disconnected, the user interaction finished. Only reset the value when the source was manual.
                Client.configuration.disconnectedManually = false

            }

            Client.preferences.lastVPNConnectionSuccess = nil
            self.lastKnownVpnStatus = .disconnected

        default:
            log.debug("[VPNDaemon] Unknown NEVPNStatus=\(connection.status.rawValue), treating as .disconnected")
            nextStatus = .disconnected
        }

        let previousStatus = accessedDatabase.transient.vpnStatus
        guard (nextStatus != previousStatus) else {
            log.debug("[VPNDaemon] nextStatus=\(nextStatus) == previousStatus=\(previousStatus), skipping notification")
            return
        }

        log.debug("[VPNDaemon] Status transition: \(previousStatus) → \(nextStatus)")
        accessedDatabase.plain.lastKnownVpnStatus = nextStatus

        if !isReconnecting {
            updateVpnStatus(with: nextStatus)
        } else {
            log.debug("[VPNDaemon] isReconnecting=true — skipping updateVpnStatus, UI stays at current state")
        }

        guard !isReconnecting else {
            log.debug("[VPNDaemon] isReconnecting=true — skipping fetchLastDisconnectError")
            return
        }

        guard #available(iOS 16.0, *) else {
            log.debug("[VPNDaemon] iOS < 16 — posting PIAVPNDidFail directly (no fetchLastDisconnectError)")
            Macros.postNotification(.PIAVPNDidFail)
            return
        }

        log.debug("[VPNDaemon] Fetching last disconnect error...")
        connection.fetchLastDisconnectError { error in
            guard let lastDisconnectError = error as NSError? else {
                log.debug("[VPNDaemon] fetchLastDisconnectError — no error reported (clean disconnect)")
                return
            }

            log.debug("[VPNDaemon] fetchLastDisconnectError — domain=\(lastDisconnectError.domain) code=\(lastDisconnectError.code) description='\(lastDisconnectError.localizedDescription)'")

            let connectivityCheckFailed = switch (lastDisconnectError.domain, lastDisconnectError.code) {
            #if canImport(PIAWireguard) && canImport(TunnelKitOpenVPN)
            case (PacketTunnelProviderError.errorDomain, PacketTunnelProviderError.connectivityCheckFailed.errorCode),
                 (OpenVPNError.errorDomain, OpenVPNError.connectivityCheckFailed.errorCode):
                true
            #endif
            case (NEVPNConnectionErrorDomain, _):
                true
            default:
                false
            }

            log.debug("[VPNDaemon] connectivityCheckFailed=\(connectivityCheckFailed) previousStatus=\(previousStatus)")

            if connectivityCheckFailed {
                log.debug("[VPNDaemon] connectivityCheckFailed — marking current server as unavailable and triggering reconnect")
                // Since disconnection was caused by connectivityCheckFailed error, we mark that server as unavailable.
                // It will not be considered again in the next reconnection loop.
                let targetServer = try? Client.providers.serverProvider.targetServer
                let lastConnectedServer = try? targetServer?.bestAddress()
                log.debug("[VPNDaemon] connectivityCheckFailed — targetServer='\(targetServer?.name ?? "nil")' addressToMark=\(lastConnectedServer?.ip ?? "nil")")
                lastConnectedServer?.markServerAsUnavailable()

                log.debug("[VPNDaemon] connectivityCheckFailed — calling reconnect(forceDisconnect: true)")
                Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true, nil)
            } else {
                log.debug("[VPNDaemon] disconnect error does NOT match connectivityCheckFailed — previousStatus=\(previousStatus)")
                if previousStatus == .connecting {
                    log.error("[VPNDaemon] VPN failed while connecting: domain=\(lastDisconnectError.domain) code=\(lastDisconnectError.code) '\(lastDisconnectError.localizedDescription)'")
                    Macros.postNotification(.PIAVPNDidFail)
                } else {
                    log.debug("[VPNDaemon] previousStatus=\(previousStatus) — not posting PIAVPNDidFail")
                }
            }
        }
    }

    private func updateVpnStatus(with vpnStatus: VPNStatus) {
        /// Artificially manipulates vpnStatus so that if user decides to change a region
        /// while already being connected, UI won't show disconnected (not protected) label.
        /// Instead it will show the connecting interface.
        if vpnStatus == .disconnected, isChangingServer {
            log.debug("[VPNDaemon] updateVpnStatus — overriding .disconnected → .connecting (isChangingServer=true)")
            accessedDatabase.transient.vpnStatus = .connecting
        } else {
            log.debug("[VPNDaemon] updateVpnStatus — setting vpnStatus=\(vpnStatus)")
            accessedDatabase.transient.vpnStatus = vpnStatus
        }
    }

    // MARK: Invalidate
    private func invalidateTimer() {
        if fallbackTimer != nil {
            log.debug("[VPNDaemon] Invalidating fallback timer")
            fallbackTimer?.invalidate()
            fallbackTimer = nil
        }
    }

    private func startServerChangeTimer() {
        // Clear any existing timer
        invalidateServerChangeTimer()

        let changeServerTimeout = TimeInterval(Client.configuration.vpnConnectivityMaxAttempts) * Client.configuration.vpnConnectivityRetryDelay
        log.debug("[VPNDaemon] Starting server change timer — timeout=\(changeServerTimeout)s")
        changingServerTimer = Timer.scheduledTimer(withTimeInterval: changeServerTimeout, repeats: false) { [weak self] timer in
            guard let self, self.isChangingServer else { return }
            log.debug("[VPNDaemon] Server change timer fired — timed out, reverting artificial vpnStatus to lastKnownVpnStatus=\(self.lastKnownVpnStatus)")

            // Clear any artificial vpnStatus previously reported
            self.isChangingServer = false
            updateVpnStatus(with: lastKnownVpnStatus)

            invalidateServerChangeTimer()
        }
    }

    private func invalidateServerChangeTimer() {
        if changingServerTimer != nil {
            log.debug("[VPNDaemon] Invalidating server change timer")
            changingServerTimer?.invalidate()
            changingServerTimer = nil
        }
    }

    // MARK: Reset

    private func reset() {
        log.debug("[VPNDaemon] reset() — clearing isReconnecting, numberOfAttempts=\(numberOfAttempts)")
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
            log.error("Missing NEVPNConnection object")
            return
        }

        log.debug("[VPNDaemon] NEVPNStatusDidChange received — rawStatus=\(connection.status.debugDescription)")
        DispatchQueue.main.async {
            self.tryUpdateStatus(via: connection)
        }
    }

    @objc private func vpnIsChangingServer(notification: Notification) {
        /// Sets true to isChangingServer. This flag is supposed to become false again only:
        /// - After vpnStatus becomes .connected, or
        /// - changingServerTimer is fired, which means the server change did timeout.
        self.isChangingServer = true
        startServerChangeTimer()
        log.debug("[VPNDaemon] PIAVPNIsChangingServer received — isChangingServer=\(isChangingServer)")
    }
}
