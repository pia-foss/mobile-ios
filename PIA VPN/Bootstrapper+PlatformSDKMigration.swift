//
//  Bootstrapper+PlatformSDKMigration.swift
//  PIA VPN
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

import Combine
import Foundation
import NetworkExtension
import PIALibrary

private let log = PIALogger.logger(for: Bootstrapper.self)

/// Migration between the legacy VPN profiles and the PlatformSDK tunnel.
extension Bootstrapper {

    // MARK: - Constants

    private static let liveVPNStatuses: [NEVPNStatus] = [.connected, .connecting, .reasserting]
    private static let vpnStatusTimeout: DispatchTimeInterval = .seconds(3)
    private static let reconnectAfterCleanupLoadingTimeout: DispatchTimeInterval = .seconds(10)

    // MARK: - Consent

    /// The flag is on *and* the consent is recorded: a launch that never got an answer out of the
    /// consent check stays on the legacy profiles rather than migrating unannounced.
    var shouldUsePlatformSDKTunnel: Bool {
        return AppPreferences.shared.usePlatformSDKVPN && AppPreferences.shared.didConfirmPlatformSDKMigration
    }

    /// Only ask for migration consent when legacy tunnel was previously connected.
    /// User is unformed there will be a short connection interruption.
    func shouldConfirmPlatformSDKMigration(_ completion: @escaping (Bool) -> Void) {
        guard AppPreferences.shared.usePlatformSDKVPN, !AppPreferences.shared.didConfirmPlatformSDKMigration else {
            log.info("shouldConfirmPlatformSDKMigration: not asking, usePlatformSDKVPN: \(AppPreferences.shared.usePlatformSDKVPN), didConfirm: \(AppPreferences.shared.didConfirmPlatformSDKMigration)")
            completion(false)
            return
        }

        guard !AppPreferences.shared.didCleanupLegacyVPNProfiles, AppPreferences.shared.wasLaunched else {
            log.info("shouldConfirmPlatformSDKMigration: migrating without asking, didCleanup: \(AppPreferences.shared.didCleanupLegacyVPNProfiles), wasLaunched: \(AppPreferences.shared.wasLaunched)")
            AppPreferences.shared.didConfirmPlatformSDKMigration = true
            completion(false)
            return
        }

        // The caller holds the launch screen until it hears back, and the read below can stall.
        // Timing out answers "no": this launch stays on the legacy profiles and asks again.
        var didAnswer = false
        let answer: (Bool) -> Void = { shouldConfirm in
            didAnswer = true
            completion(shouldConfirm)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.vpnStatusTimeout) {
            guard !didAnswer else { return }

            log.error("shouldConfirmPlatformSDKMigration: timed out, staying on the legacy profiles")
            answer(false)
        }

        Self.loadIsVPNConnected { isConnected in
            guard !didAnswer else {
                log.info("shouldConfirmPlatformSDKMigration: status arrived after the timeout, connected: \(isConnected)")
                return
            }

            guard isConnected else {
                log.info("shouldConfirmPlatformSDKMigration: no live or on-demand tunnel, migrating without asking")
                AppPreferences.shared.didConfirmPlatformSDKMigration = true
                answer(false)
                return
            }

            log.info("shouldConfirmPlatformSDKMigration: live or on-demand tunnel, asking for consent")
            answer(true)
        }
    }

    func confirmPlatformSDKMigration() {
        log.info("confirmPlatformSDKMigration: user confirmed the migration to the PlatformSDK tunnel")
        AppPreferences.shared.didConfirmPlatformSDKMigration = true
    }

    // MARK: - Migrating to the PlatformSDK tunnel

    /// One-time deletion of every VPN configuration this app owns, so the PlatformSDK tunnel starts
    /// from a clean slate.
    func cleanupLegacyVPNProfilesIfNeeded() {
        guard shouldUsePlatformSDKTunnel, !AppPreferences.shared.didCleanupLegacyVPNProfiles else {
            log.info("cleanupLegacyVPNProfiles: skipped, shouldUsePlatformSDKTunnel: \(shouldUsePlatformSDKTunnel), didCleanup: \(AppPreferences.shared.didCleanupLegacyVPNProfiles)")
            return
        }

        let supportedTypes: [KapePlatformSDKVPNType] = [
            .automatic,
            .wireGuard,
            .openVPN
        ]

        if !supportedTypes.map(\.rawValue).contains(Client.preferences.vpnType) {
            let editable = Client.preferences.editable()
            editable.vpnType = KapePlatformSDKVPNType.automatic.rawValue
            editable.commit()
        }

        Self.loadIsVPNConnected { wasConnected in
            NETunnelProviderManager.loadAllFromPreferences { managers, error in
                // Retried on the next launch when the configurations cannot be read.
                guard let managers else {
                    log.error("cleanupLegacyVPNProfiles: could not load the VPN configurations (\(error?.localizedDescription ?? "no error")), retrying on the next launch")
                    return
                }

                log.info("cleanupLegacyVPNProfiles: removing \(managers.count) VPN configuration(s), connected: \(wasConnected)")

                let group = DispatchGroup()
                for manager in managers {
                    group.enter()
                    manager.connection.stopVPNTunnel()
                    manager.removeFromPreferences { _ in group.leave() }
                }

                // The IKEv2 configuration sits in the non-tunnel-provider slot, which the load above
                // never returns.
                group.enter()
                IKEv2Profile().remove { _ in group.leave() }

                group.notify(queue: .main) {
                    // Re-read instead of trusting the removals: bootstrap reinstalls the PlatformSDK
                    // configuration on this launch, so anything else left is a failed removal.
                    NETunnelProviderManager.loadAllFromPreferences { managers, _ in
                        let didCleanupLegacyVPNProfiles = managers?.allSatisfy { manager in
                            (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == AppConstants.Extensions.tunnelPlatformSDKBundleIdentifier
                        }

                        log.info("cleanupLegacyVPNProfiles: removal verified: \(didCleanupLegacyVPNProfiles == true), remaining: \(managers?.count ?? -1)")
                        AppPreferences.shared.didCleanupLegacyVPNProfiles = (didCleanupLegacyVPNProfiles == true)
                    }

                    // Deleting a live tunnel's configuration disconnects the user.
                    guard wasConnected, Client.providers.accountProvider.isLoggedIn else {
                        log.info("cleanupLegacyVPNProfiles: not reconnecting, wasConnected: \(wasConnected), isLoggedIn: \(Client.providers.accountProvider.isLoggedIn)")
                        return
                    }

                    self.reconnectAfterCleanup()
                }
            }
        }
    }

    /// Reconnects once the tunnel can authenticate. A Dedicated IP server cached by a build before
    /// 3.36 keeps its token but not `dipUsername`, the WireGuard credential, until the first server
    /// download maps it again. Connecting before that fails ahead of the VPN permission prompt.
    private func reconnectAfterCleanup() {
        let targetServer = try? Client.providers.serverProvider.targetServer
        if let targetServer, targetServer.dipToken != nil, targetServer.dipUsername?.isEmpty ?? true {
            log.info("cleanupLegacyVPNProfiles: waiting for the server list to restore the Dedicated IP credentials")

            let dashboard = DashboardViewController.instanceInNavigationStack()
            dashboard?.showLoadingAnimation()

            // The loading locks the UI: release it if the server list is slow, the reconnect keeps waiting.
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.reconnectAfterCleanupLoadingTimeout) {
                dashboard?.hideLoadingAnimation()
            }

            reconnectAfterCleanupCancellable = NotificationCenter.default
                .publisher(for: .PIAServerDidUpdateCurrentServers)
                .first()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    dashboard?.hideLoadingAnimation()

                    // The user may have connected, or logged out, while the list was refreshing.
                    guard Client.providers.accountProvider.isLoggedIn, Client.providers.vpnProvider.vpnStatus == .disconnected else {
                        log.info("cleanupLegacyVPNProfiles: server list updated, not reconnecting, isLoggedIn: \(Client.providers.accountProvider.isLoggedIn), vpnStatus: \(Client.providers.vpnProvider.vpnStatus)")
                        return
                    }

                    self?.reconnectAfterCleanup()
                }
            return
        }

        log.info("cleanupLegacyVPNProfiles: reconnecting, dedicated IP: \(targetServer?.dipToken != nil)")
        Client.providers.vpnProvider.connect { error in
            if let error {
                log.error("cleanupLegacyVPNProfiles: could not reconnect (\(error.localizedDescription))")
            }
        }
    }

    // MARK: - Rolling back to the legacy profiles

    /// Reverses the migration when the tunnel is turned back off: no legacy profile answers to
    /// `automatic`, so the protocol maps back onto WireGuard, and the consent and cleanup are
    /// re-armed for a flag that returns.
    func migrateToLegacyVPNProfilesIfNeeded() {
        AppPreferences.shared.didCleanupLegacyVPNProfiles = false
        AppPreferences.shared.didConfirmPlatformSDKMigration = false

        if Client.preferences.vpnType == KapePlatformSDKVPNType.automatic.rawValue {
            let preferences = Client.preferences.editable()
            preferences.vpnType = PIAWGTunnelProfile.vpnType
            preferences.commit()
        }

        removePlatformSDKVPNProfiles()
    }

    /// Nothing else prunes these: the profile is no longer registered, so its on-demand rules would
    /// keep starting a tunnel the app no longer tracks. No-ops once nothing matches, so a failed
    /// removal is retried on the next launch.
    private func removePlatformSDKVPNProfiles() {
        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            let platformSDKManagers = (managers ?? []).filter { manager in
                (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == AppConstants.Extensions.tunnelPlatformSDKBundleIdentifier
            }

            guard !platformSDKManagers.isEmpty else { return }

            let wasConnected = platformSDKManagers.contains(where: Self.isConnectedOrOnDemand)

            log.info("removePlatformSDKVPNProfiles: removing \(platformSDKManagers.count) PlatformSDK configuration(s), connected: \(wasConnected)")

            let group = DispatchGroup()
            for manager in platformSDKManagers {
                group.enter()
                // Disarm on-demand first, so a failed removal cannot start the tunnel again.
                manager.isOnDemandEnabled = false
                manager.saveToPreferences { _ in
                    manager.connection.stopVPNTunnel()
                    manager.removeFromPreferences { _ in group.leave() }
                }
            }

            group.notify(queue: .main) {
                // Removing a live tunnel's configuration disconnects the user.
                guard wasConnected, Client.providers.accountProvider.isLoggedIn else {
                    return
                }

                Client.providers.vpnProvider.connect { error in
                    if let error {
                        log.error("removePlatformSDKVPNProfiles: could not reconnect (\(error.localizedDescription))")
                    }
                }
            }
        }
    }
    // MARK: - Helpers

    /// Reads the NE preferences rather than `VPNProvider.isVPNConnected`, so it works before
    /// bootstrap, and covers the IKEv2 slot that `loadAllFromPreferences` never returns.
    /// Counts a configuration armed for on-demand as connected, see `isConnectedOrOnDemand(_:)`.
    static func loadIsVPNConnected(_ completion: @escaping (Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error {
                log.error("loadIsVPNConnected: could not load the VPN configurations (\(error.localizedDescription))")
            }
            log.info("loadIsVPNConnected: \(managers?.count ?? 0) configuration(s)\((managers ?? []).map { "\n  \(describeForLog($0))" }.joined())")

            let isTunnelProviderConnected = managers?.contains(where: isConnectedOrOnDemand) == true

            guard !isTunnelProviderConnected else {
                DispatchQueue.main.async { completion(true) }
                return
            }

            let ikEv2Manager = NEVPNManager.shared()
            ikEv2Manager.loadFromPreferences { _ in
                log.info("loadIsVPNConnected: IKEv2 \(describeForLog(ikEv2Manager))")
                let isIKEv2Connected = isConnectedOrOnDemand(ikEv2Manager)
                DispatchQueue.main.async { completion(isIKEv2Connected) }
            }
        }
    }

    /// A manual disconnect turns on-demand off, so an enabled configuration still armed for it
    /// belongs to a user who meant to stay connected, even when the tunnel is down at launch (seen
    /// on iOS 15 after the app update: `disconnected`, enabled, on-demand on).
    private static func isConnectedOrOnDemand(_ manager: NEVPNManager) -> Bool {
        return liveVPNStatuses.contains(manager.connection.status) || (manager.isEnabled && manager.isOnDemandEnabled)
    }

    private static func describeForLog(_ manager: NEVPNManager) -> String {
        let bundleIdentifier = (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier ?? "none"
        return "\(bundleIdentifier) status: \(describeForLog(manager.connection.status)), enabled: \(manager.isEnabled), onDemand: \(manager.isOnDemandEnabled)"
    }

    private static func describeForLog(_ status: NEVPNStatus) -> String {
        switch status {
        case .invalid: return "invalid"
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .reasserting: return "reasserting"
        case .disconnecting: return "disconnecting"
        @unknown default: return "unknown(\(status.rawValue))"
        }
    }
}
