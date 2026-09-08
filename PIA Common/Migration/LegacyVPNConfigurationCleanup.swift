//
//  LegacyVPNConfigurationCleanup.swift
//  PIA Common
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import NetworkExtension
import PIALibrary

private let log = PIALogger.logger(for: LegacyVPNConfigurationCleanup.self)

/// One-time removal of the legacy IKEv2 VPN configuration left behind by pre-PlatformSDK installs.
///
/// IKEv2 lived in the *personal* VPN slot (`NEVPNManager.shared()`), which
/// `NETunnelProviderManager.loadAllFromPreferences` never returns — so it has to be removed
/// separately from the packet-tunnel configurations. Shared by both apps:
/// - **tvOS** only ever shipped IKEv2, so this is its entire cleanup.
/// - **iOS** also had OpenVPN and WireGuard tunnel providers; this covers the personal-slot half of
///   its prune, while `Bootstrapper+PlatformSDKMigration` handles the tunnel-provider half.
///
/// The PlatformSDK tunnel is a packet-tunnel provider with its own `NETunnelProviderManager`, so
/// removing the personal configuration here can never disturb the profile the app now connects
/// with — and, deliberately, this type never writes the app's VPN status
/// (`Client.database.transient.vpnStatus` / `lastKnownVpnStatus`), which the legacy
/// `IKEv2Profile.disconnect` used to do.
enum LegacyVPNConfigurationCleanup {

    /// Removes the legacy configuration, if one is still installed.
    ///
    /// - Parameter completion: `true` when no legacy configuration is left on the device — either it
    ///   was removed cleanly, or there was none to begin with. `false` means the attempt should be
    ///   repeated on the next launch, so the caller must not record the migration as done.
    static func remove(_ completion: @escaping (Bool) -> Void) {
        let manager = NEVPNManager.shared()

        manager.loadFromPreferences { error in
            if let error {
                log.error(
                    "Legacy VPN cleanup: could not load the personal VPN configuration (\(error.localizedDescription)); retrying on next launch"
                )
                completion(false)
                return
            }

            // A device that never had the legacy profile — or that has already been migrated — has
            // an empty personal VPN slot. Nothing to remove, so the migration is satisfied.
            guard manager.protocolConfiguration != nil else {
                log.debug("Legacy VPN cleanup: no legacy configuration installed")
                completion(true)
                return
            }

            // Stop the tunnel and disarm on-demand *before* removing, so an on-demand rule cannot
            // restart the legacy tunnel while the removal is in flight.
            manager.connection.stopVPNTunnel()
            manager.isEnabled = false
            manager.isOnDemandEnabled = false

            manager.saveToPreferences { saveError in
                if let saveError {
                    // Not fatal: the removal below drops the configuration, and its on-demand rules
                    // with it.
                    log.error(
                        "Legacy VPN cleanup: could not disable the legacy configuration (\(saveError.localizedDescription)); removing it anyway"
                    )
                }

                manager.removeFromPreferences { removeError in
                    if let removeError {
                        log.error(
                            "Legacy VPN cleanup: could not remove the legacy configuration (\(removeError.localizedDescription)); retrying on next launch"
                        )
                        completion(false)
                        return
                    }

                    log.info("Legacy VPN cleanup: removed the legacy IKEv2 configuration")
                    completion(true)
                }
            }
        }
    }
}
