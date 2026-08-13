//
//  NetworkExtensionProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/25/17.
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

private let log = PIALogger.logger(for: NetworkExtensionProfile.self)

/// Specific protocol bridging a `VPNProfile` to a native `NEVPNProtocol` from Apple's NetworkExtension framwork.
public protocol NetworkExtensionProfile: VPNProfile {

    /**
     Returns a native `NEVPNProtocol` from this profile given a configuration.

     - Parameter configuration: The `VPNConfiguration` to build the protocol upon.
     - Returns: A native `NEVPNProtocol` object for use with NetworkExtension.
     */
    func generatedProtocol(withConfiguration configuration: VPNConfiguration) throws -> NEVPNProtocol
}

extension NetworkExtensionProfile {

    /// :nodoc:
    private var neProfile: NEVPNManager? {
        return native as? NEVPNManager
    }

    /// :nodoc:
    public var serverAddress: String? {
        return neProfile?.protocolConfiguration?.serverAddress
    }

    /**
     Takes care of saving the profile as `NEVPNProtocol` to a given `NEVPNManager`.

     - Parameter vpn: The target `NEVPNManager` to which the generated protocol will be committed.
     - Parameter configuration: The `VPNConfiguration` to use for generating the `NEVPNProtocol` object.
     - Parameter force: If `true`, apply changes forcibly.
     - Parameter callback: Returns `nil` on success.
     - Seealso: `NetworkExtensionProfile.generatedProtocol(...)`
     */
    public func doSave(_ vpn: NEVPNManager, withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
        do {
            vpn.protocolConfiguration = try generatedProtocol(withConfiguration: configuration)
        } catch {
            callback?(error)
            return
        }

        let protocolConfiguration = vpn.protocolConfiguration!  // Safe to force unwrap

        vpn.localizedDescription = configuration.name
        vpn.isOnDemandEnabled = Client.providers.vpnProvider.isVPNConnected || vpn.isEnabled ? configuration.isOnDemand : false  //if the VPN is disconnected, don't activate the onDemand property to don't autoconnect the VPN without user permission

        let trustedNetworks = Client.preferences.nmtTrustedNetworkRules

        vpn.onDemandRules = []

        if vpn.isOnDemandEnabled {

            if Client.preferences.nmtRulesEnabled {
                log.debug("Network Management Rule Enabled: \(Client.preferences.nmtRulesEnabled)")
                log.debug("Network Management Rules for Trusted Networks: \(Client.preferences.nmtTrustedNetworkRules)")
                log.debug("Network Management Generic rules: \(Client.preferences.nmtGenericRules)")
                self.configureOnDemandOnWiFiNetworksFor(trustedNetworks, vpn)
                self.configureOnDemandOnCellularNetworks(vpn)
            } else {
                log.debug("Network Management Tool is not enabled")
                self.configureDefaultOnDemandRules(force, vpn, configuration)
            }
        }
        #if os(iOS)
            let selectedProtocol = Client.preferences.vpnType
            let isWireGuard = selectedProtocol == PIAWGTunnelProfile.vpnType
            let isOpenVPN = selectedProtocol == PIATunnelProfile.vpnType

            // Do not apply Leak Protection settings on WireGuard and OpenVPN
            if isWireGuard || isOpenVPN {
                vpn.protocolConfiguration?.includeAllNetworks = false
                vpn.protocolConfiguration?.excludeLocalNetworks = true
            } else {
                // Apply Leak Protection settings when the Feature Flag is enabled
                if Client.configuration.featureFlags[.showLeakProtection] {
                    vpn.protocolConfiguration?.includeAllNetworks = configuration.leakProtection
                    vpn.protocolConfiguration?.excludeLocalNetworks = configuration.allowLocalDeviceAccess
                } else {
                    vpn.protocolConfiguration?.includeAllNetworks = false
                    vpn.protocolConfiguration?.excludeLocalNetworks = true
                }
            }
        #endif

        log.debug("Configured with server: \(protocolConfiguration.serverAddress ?? "none")")
        log.debug("On-demand is now \(vpn.isOnDemandEnabled ? "ENABLED" : "DISABLED")")
        log.debug("Raw manager: \(vpn)")

        vpn.isEnabled = true
        vpn.saveToPreferences { (error) in
            if let error = error {
                callback?(error)
                return
            }
            vpn.loadFromPreferences { (error) in
                callback?(nil)
            }
        }
    }

    /**
     Runs a block once the connection is no longer tearing down, immediately if it
     is not.

     NetworkExtension silently drops a start request issued while the connection is
     `.disconnecting`, and no further status change follows to trigger a retry. A
     reconnect hits that window routinely: `disconnect()` calls back as soon as its
     preferences round-trip lands, well before the tunnel is actually down. The
     on-demand rules used to hide this by bringing the tunnel back up, but with the
     kill switch off — in particular on the reconnect that follows disabling it —
     nothing does, and the VPN stays down for good.

     Rethrows whatever `perform` throws when it runs right away. A deferred run
     happens after this returns, so its failure is logged rather than reported.

     - Parameter connection: The connection whose teardown must complete first.
     - Parameter perform: Issues the actual start request.
     */
    func afterTeardown(of connection: NEVPNConnection, perform: @escaping () throws -> Void) throws {
        guard connection.status == .disconnecting else {
            try perform()
            return
        }

        log.debug("The tunnel is still disconnecting, deferring the start until it is down")

        var observer: NSObjectProtocol?
        var hasRun = false

        let performOnce = {
            guard !hasRun else { return }
            hasRun = true
            if let token = observer {
                NotificationCenter.default.removeObserver(token)
                // Also breaks the retain cycle: the block below captures this very
                // token, so removing the observation alone would not release it.
                observer = nil
            }
            // The user may have given up on the attempt while the teardown was in
            // flight. Never bring the tunnel back up against that intent — the
            // disconnect that expressed it is what put us in this window.
            guard !Client.configuration.disconnectedManually else {
                log.debug("Abandoning the deferred tunnel start — the user gave up on the attempt")
                return
            }
            do {
                try perform()
            } catch let e {
                log.error("The deferred tunnel start failed: \(e)")
            }
        }

        observer = NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: connection, queue: .main) { _ in
            guard connection.status != .disconnecting else { return }
            performOnce()
        }
        // The teardown may have completed while the observer was being installed,
        // in which case no further status change is coming.
        if connection.status != .disconnecting {
            performOnce()
        }
        // A wedged teardown must not swallow the start for good.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { performOnce() }
    }

    private func configureOnDemandOnWiFiNetworksFor(
        _ trustedNetworks: [String: Int],
        _ vpn: NEVPNManager
    ) {

        let genericRules = Client.preferences.nmtGenericRules
        let rule = genericRules[NMTType.protectedWiFi.rawValue]

        vpn.onDemandRules = []

        //First, Open networks
        let openNetworks = Client.preferences.nmtTemporaryOpenNetworks
        openNetworks.forEach { network in

            switch genericRules[NMTType.openWiFi.rawValue] {
            case NMTRules.alwaysConnect.rawValue:
                let ruleConnect = NEOnDemandRuleConnect()
                ruleConnect.interfaceTypeMatch = .wiFi
                ruleConnect.ssidMatch = [network]
                vpn.onDemandRules?.append(ruleConnect)
            case NMTRules.alwaysDisconnect.rawValue:
                let ruleDisconnect = NEOnDemandRuleDisconnect()
                ruleDisconnect.interfaceTypeMatch = .wiFi
                ruleDisconnect.ssidMatch = [network]
                vpn.onDemandRules?.append(ruleDisconnect)
            default:
                let ruleIgnore = NEOnDemandRuleIgnore()
                ruleIgnore.interfaceTypeMatch = .wiFi
                ruleIgnore.ssidMatch = [network]
                vpn.onDemandRules?.append(ruleIgnore)
            }

        }

        //Next, apply rules for each network
        trustedNetworks.forEach { (key, value) in

            switch value {
            case NMTRules.alwaysConnect.rawValue:
                let ruleConnect = NEOnDemandRuleConnect()
                ruleConnect.interfaceTypeMatch = .wiFi
                ruleConnect.ssidMatch = [key]
                vpn.onDemandRules?.append(ruleConnect)
            case NMTRules.alwaysDisconnect.rawValue:
                let ruleDisconnect = NEOnDemandRuleDisconnect()
                ruleDisconnect.interfaceTypeMatch = .wiFi
                ruleDisconnect.ssidMatch = [key]
                vpn.onDemandRules?.append(ruleDisconnect)
            default:
                let ruleIgnore = NEOnDemandRuleIgnore()
                ruleIgnore.interfaceTypeMatch = .wiFi
                ruleIgnore.ssidMatch = [key]
                vpn.onDemandRules?.append(ruleIgnore)
            }

        }

        //Last, apply generic rules to WiFi
        switch rule {
        case NMTRules.alwaysConnect.rawValue:
            let ruleConnect = NEOnDemandRuleConnect()
            ruleConnect.interfaceTypeMatch = .wiFi
            vpn.onDemandRules?.append(ruleConnect)
        case NMTRules.alwaysDisconnect.rawValue:
            let ruleDisconnect = NEOnDemandRuleDisconnect()
            ruleDisconnect.interfaceTypeMatch = .wiFi
            vpn.onDemandRules?.append(ruleDisconnect)
        default:
            let ruleIgnore = NEOnDemandRuleIgnore()
            ruleIgnore.interfaceTypeMatch = .wiFi
            vpn.onDemandRules?.append(ruleIgnore)
        }

        let preferences = Client.preferences.editable()
        preferences.nmtTemporaryOpenNetworks = []
        preferences.commit()

    }

    private func configureOnDemandOnCellularNetworks(_ vpn: NEVPNManager) {
        #if os(iOS)
            let rules = Client.preferences.nmtGenericRules
            let cellularRule = rules[NMTType.cellular.rawValue]

            switch cellularRule {
            case NMTRules.alwaysConnect.rawValue:
                let ruleConnect = NEOnDemandRuleConnect()
                ruleConnect.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(ruleConnect)
            case NMTRules.alwaysDisconnect.rawValue:
                let ruleDisconnect = NEOnDemandRuleDisconnect()
                ruleDisconnect.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(ruleDisconnect)
            default:
                let ruleIgnore = NEOnDemandRuleIgnore()
                ruleIgnore.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(ruleIgnore)
            }
        #endif
    }

    private func configureDefaultOnDemandRules(
        _ force: Bool,
        _ vpn: NEVPNManager,
        _ configuration: VPNConfiguration
    ) {
        if force {
            vpn.isOnDemandEnabled = configuration.isOnDemand
        } else {
            vpn.isOnDemandEnabled = vpn.isOnDemandEnabled && configuration.isOnDemand
        }
        if vpn.isOnDemandEnabled {
            vpn.onDemandRules = [NEOnDemandRuleConnect()]
        }
    }

}
