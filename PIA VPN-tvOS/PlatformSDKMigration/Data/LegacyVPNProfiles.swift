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

    func removeAll(_ completion: @escaping (Bool) -> Void) {
        let legacyProfile = IKEv2Profile()
        legacyProfile.disconnect { _ in
            legacyProfile.remove { error in
                if let error, !Self.isConfigurationMissing(error) {
                    log.error("removeAll: could not remove the legacy profile (\(error.localizedDescription))")
                    Self.loadIsLegacyProfileRemoved(completion)
                    return
                }

                DispatchQueue.main.async { completion(true) }
            }
        }
    }

    private static func isPlatformSDKTunnel(_ manager: NETunnelProviderManager) -> Bool {
        let providerBundleIdentifier = (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier
        return providerBundleIdentifier == AppConstants.Extensions.tunnelPlatformSDKTvOSBundleIdentifier
    }

    private static func isConfigurationMissing(_ error: Error) -> Bool {
        let error = error as NSError
        return error.domain == "NEConfigurationErrorDomain" && error.code == 7
    }

    private static func loadIsLegacyProfileRemoved(_ completion: @escaping (Bool) -> Void) {
        let ikEv2Manager = NEVPNManager.shared()
        ikEv2Manager.loadFromPreferences { _ in
            let isRemoved = ikEv2Manager.protocolConfiguration == nil
            DispatchQueue.main.async { completion(isRemoved) }
        }
    }
}
