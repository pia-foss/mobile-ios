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

import Foundation
import NetworkExtension
import PIALibrary

private let log = PIALogger.logger(for: Bootstrapper.self)

/// Migration between the legacy VPN profiles and the PlatformSDK tunnel.
extension Bootstrapper {

    // MARK: - Constants

    private static let liveVPNStatuses: [NEVPNStatus] = [.connected, .connecting, .reasserting]
    /// Also counts a tunnel on its way down: an app upgrade tears the extension down, so a
    /// connection the user still wants can read `.disconnecting` for the length of this launch.
    private static let liveOrClosingVPNStatuses: [NEVPNStatus] = liveVPNStatuses + [.disconnecting]
    private static let vpnStatusTimeout: DispatchTimeInterval = .seconds(3)

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
            completion(false)
            return
        }

        guard !AppPreferences.shared.didCleanupLegacyVPNProfiles, AppPreferences.shared.wasLaunched else {
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
            guard !didAnswer else { return }

            guard isConnected else {
                log.info("shouldConfirmPlatformSDKMigration: no live tunnel, migrating without asking")
                AppPreferences.shared.didConfirmPlatformSDKMigration = true
                answer(false)
                return
            }

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

        Self.loadShouldReconnectAfterCleanup { wasConnected in
            NETunnelProviderManager.loadAllFromPreferences { managers, _ in
                // Retried on the next launch when the configurations cannot be read.
                guard let managers else { return }

                log.info("cleanupLegacyVPNProfiles: removing \(managers.count) VPN configuration(s), connected: \(wasConnected)")

                // Recorded before anything is torn down, so a crash or a kill mid-migration still
                // leaves the next launch with the reconnect to finish. Only ever adds to the intent
                // captured before bootstrap, which saw a persisted status this read no longer can.
                AppPreferences.shared.pendingPlatformSDKReconnect =
                    AppPreferences.shared.pendingPlatformSDKReconnect || wasConnected

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

                        DispatchQueue.main.async {
                            AppPreferences.shared.didCleanupLegacyVPNProfiles = (didCleanupLegacyVPNProfiles == true)

                            // Deleting a live tunnel's configuration disconnects the user.
                            self.reconnectAfterMigrationIfNeeded()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Finishing the migration

    /// Records the reconnect the migration owes the user, read from the status persisted across
    /// launches. Must run before `Client.bootstrap()`: its status reconciliation writes that value
    /// back as `.disconnected` when the PlatformSDK configuration does not exist yet.
    func capturePlatformSDKMigrationIntentIfNeeded() {
        guard
            PlatformSDKMigrationDecision.shouldOweReconnectBeforeBootstrap(
                usesPlatformSDKTunnel: shouldUsePlatformSDKTunnel,
                didCleanup: AppPreferences.shared.didCleanupLegacyVPNProfiles,
                hasStoredValue: AppPreferences.shared.hasPendingPlatformSDKReconnectValue,
                lastKnownStatus: Client.daemons.lastKnownVPNStatus
            )
        else {
            return
        }

        log.info("capturePlatformSDKMigrationIntent: the last known status was connected, owing a reconnect")
        AppPreferences.shared.pendingPlatformSDKReconnect = true
    }

    /// Finishes a migration that owes the user a reconnect. Idempotent and safe to call on every
    /// launch: the intent is only cleared once the VPN reports connected.
    func reconnectAfterMigrationIfNeeded() {
        guard shouldUsePlatformSDKTunnel,
            // Reconnecting before the cleanup has finished would only install a configuration for
            // its removal loop to delete again.
            AppPreferences.shared.didCleanupLegacyVPNProfiles,
            AppPreferences.shared.pendingPlatformSDKReconnect,
            Client.providers.accountProvider.isLoggedIn,
            Client.daemons.vpnStatus != .connected
        else {
            return
        }

        // The cleanup removed every configuration this app owns, so install before connecting:
        // without a saved configuration there are no on-demand rules to bring the tunnel back.
        Client.providers.vpnProvider.install(force: true) { error in
            if let error {
                log.error("reconnectAfterMigration: could not install the VPN configuration (\(error.localizedDescription))")
                return
            }

            Client.providers.vpnProvider.connect { error in
                if let error {
                    log.error("reconnectAfterMigration: could not reconnect (\(error.localizedDescription))")
                }
            }
        }
    }

    /// Clears the intent once the reconnect has visibly succeeded. Anything short of that leaves it
    /// set, so the next launch tries again.
    func clearPendingPlatformSDKReconnect() {
        guard AppPreferences.shared.pendingPlatformSDKReconnect else {
            return
        }

        AppPreferences.shared.pendingPlatformSDKReconnect = false
    }

    // MARK: - Rolling back to the legacy profiles

    /// Reverses the migration when the tunnel is turned back off: no legacy profile answers to
    /// `automatic`, so the protocol maps back onto WireGuard, and the consent and cleanup are
    /// re-armed for a flag that returns.
    func migrateToLegacyVPNProfilesIfNeeded() {
        AppPreferences.shared.didCleanupLegacyVPNProfiles = false
        AppPreferences.shared.didConfirmPlatformSDKMigration = false
        AppPreferences.shared.pendingPlatformSDKReconnect = false

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

            let wasConnected = platformSDKManagers.contains { manager in
                Self.liveVPNStatuses.contains(manager.connection.status)
            }

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

    /// Whether deleting the legacy configurations owes the user a reconnect.
    ///
    /// Deliberately wider than ``loadIsVPNConnected``, which only decides whether to warn about an
    /// interruption: the live status alone is a false negative when the upgrade has just torn the
    /// extension down, so armed on-demand rules and the persisted status are weighed in too.
    private static func loadShouldReconnectAfterCleanup(_ completion: @escaping (Bool) -> Void) {
        let lastKnownStatus = Client.daemons.lastKnownVPNStatus

        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            let managers = managers ?? []
            let isTunnelProviderLive = managers.contains { manager in
                liveOrClosingVPNStatuses.contains(manager.connection.status)
            }
            let isTunnelProviderOnDemandArmed = managers.contains { $0.isOnDemandEnabled }

            let ikEv2Manager = NEVPNManager.shared()
            ikEv2Manager.loadFromPreferences { _ in
                let shouldReconnect = PlatformSDKMigrationDecision.shouldReconnectAfterCleanup(
                    isNativeLive: isTunnelProviderLive || liveOrClosingVPNStatuses.contains(ikEv2Manager.connection.status),
                    isOnDemandArmed: isTunnelProviderOnDemandArmed || ikEv2Manager.isOnDemandEnabled,
                    lastKnownStatus: lastKnownStatus
                )

                DispatchQueue.main.async { completion(shouldReconnect) }
            }
        }
    }

    /// Reads the NE preferences rather than `VPNProvider.isVPNConnected`, so it works before
    /// bootstrap, and covers the IKEv2 slot that `loadAllFromPreferences` never returns.
    static func loadIsVPNConnected(_ completion: @escaping (Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            let isTunnelProviderConnected =
                managers?.contains { manager in
                    liveVPNStatuses.contains(manager.connection.status)
                } == true

            guard !isTunnelProviderConnected else {
                DispatchQueue.main.async { completion(true) }
                return
            }

            let ikEv2Manager = NEVPNManager.shared()
            ikEv2Manager.loadFromPreferences { _ in
                let isIKEv2Connected = liveVPNStatuses.contains(ikEv2Manager.connection.status)
                DispatchQueue.main.async { completion(isIKEv2Connected) }
            }
        }
    }
}
