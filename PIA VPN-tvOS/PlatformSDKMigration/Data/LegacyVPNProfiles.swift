//
//  LegacyVPNProfiles.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import NetworkExtension
import PIALibrary

private let log = PIALogger.logger(for: LegacyVPNProfiles.self)

final class LegacyVPNProfiles: LegacyVPNProfilesType {

    private static let liveVPNStatuses: [NEVPNStatus] = [.connected, .connecting, .reasserting]

    func isVPNConnected(_ completion: @escaping (Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, _ in
            let isTunnelProviderConnected =
                managers?.contains { manager in
                    !Self.isPlatformSDKTunnel(manager) && Self.liveVPNStatuses.contains(manager.connection.status)
                } == true

            guard !isTunnelProviderConnected else {
                DispatchQueue.main.async {
                    completion(true)
                }

                return
            }

            let ikEv2Manager = NEVPNManager.shared()
            ikEv2Manager.loadFromPreferences { _ in
                let isIKEv2Connected = Self.liveVPNStatuses.contains(ikEv2Manager.connection.status)
                DispatchQueue.main.async { completion(isIKEv2Connected) }
            }
        }
    }

    /// Removes the legacy IKEv2 configuration from the personal-VPN slot.
    ///
    /// `IKEv2Profile` is gone with the rest of the legacy stack (KM-18239), so this delegates to
    /// `LegacyVPNConfigurationCleanup` — shared with the iOS app, which needs the same personal-slot
    /// removal as one half of its wider prune. That helper already treats "no configuration
    /// installed" as success and never writes the app's VPN status, so the missing-configuration and
    /// re-read fallbacks this method used to need are handled inside it.
    func removeAll(_ completion: @escaping (Bool) -> Void) {
        LegacyVPNConfigurationCleanup.remove { didRemove in
            DispatchQueue.main.async { completion(didRemove) }
        }
    }

    private static func isPlatformSDKTunnel(_ manager: NETunnelProviderManager) -> Bool {
        let providerBundleIdentifier = (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier
        return providerBundleIdentifier == AppConstants.Extensions.tunnelPlatformSDKTvOSBundleIdentifier
    }

}
