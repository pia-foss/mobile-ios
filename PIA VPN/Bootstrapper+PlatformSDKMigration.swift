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

        Self.loadIsVPNConnected { wasConnected in
            NETunnelProviderManager.loadAllFromPreferences { managers, _ in
                // Retried on the next launch when the configurations cannot be read.
                guard let managers else { return }

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

                        AppPreferences.shared.didCleanupLegacyVPNProfiles = (didCleanupLegacyVPNProfiles == true)
                    }

                    // Deleting a live tunnel's configuration disconnects the user.
                    guard wasConnected, Client.providers.accountProvider.isLoggedIn else {
                        return
                    }

                    Client.providers.vpnProvider.connect { error in
                        if let error {
                            log.error("cleanupLegacyVPNProfiles: could not reconnect (\(error.localizedDescription))")
                        }
                    }
                }
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
