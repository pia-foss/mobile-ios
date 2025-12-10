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
import SwiftyBeaver

private let log = SwiftyBeaver.self

/// Specific protocol bridging a `VPNProfile` to a native `NEVPNProtocol` from Apple's NetworkExtension framwork.
@available(tvOS 17.0, *)
public protocol NetworkExtensionProfile: VPNProfile {

    /**
     Returns a native `NEVPNProtocol` from this profile given a configuration.
     
     - Parameter configuration: The `VPNConfiguration` to build the protocol upon.
     - Returns: A native `NEVPNProtocol` object for use with NetworkExtension.
     */
    func generatedProtocol(withConfiguration configuration: VPNConfiguration) throws -> NEVPNProtocol
}

@available(tvOS 17.0, *)
extension NetworkExtensionProfile {
    
    /// :nodoc:
    private var neProfile: NEVPNManager? {
        return native as? NEVPNManager
    }
    
    /// :nodoc:
    public var serverIdentifier: String? {
        guard let serverAddress = neProfile?.protocolConfiguration?.serverAddress else {
            return nil
        }
        let components = serverAddress.components(separatedBy: ".")
        return components.first
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

        guard let protocolConfiguration = vpn.protocolConfiguration else {
            fatalError("Never provided a configuration?")
        }
        
        vpn.localizedDescription = configuration.name
        vpn.isOnDemandEnabled = Client.providers.vpnProvider.isVPNConnected || vpn.isEnabled ?
            configuration.isOnDemand :
            false //if the VPN is disconnected, don't activate the onDemand property to don't autoconnect the VPN without user permission
        
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
        if #available(iOS 14.2, *) {
            let selectedProtocol = Client.preferences.vpnType
            let isWireGuard = selectedProtocol == PIAWGTunnelProfile.vpnType
            let isOpenVPN = selectedProtocol == PIATunnelProfile.vpnType
            
            // Do not apply Leak Protection settings on WireGuard and OpenVPN
            if isWireGuard || isOpenVPN {
                vpn.protocolConfiguration?.includeAllNetworks = false
                vpn.protocolConfiguration?.excludeLocalNetworks = true
            } else {
                // Apply Leak Protection settings when the Feature Flag is enabled
                if Client.configuration.featureFlags.contains(Client.FeatureFlags.showLeakProtection) {
                    vpn.protocolConfiguration?.includeAllNetworks = configuration.leakProtection
                    vpn.protocolConfiguration?.excludeLocalNetworks = configuration.allowLocalDeviceAccess
                } else {
                    vpn.protocolConfiguration?.includeAllNetworks = false
                    vpn.protocolConfiguration?.excludeLocalNetworks = true
                }
            }
        }
        #endif
        
        log.debug("Configured with server: \(protocolConfiguration.serverAddress!)")
        log.debug("Username: \(protocolConfiguration.username!)")
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
    
    
    private func configureOnDemandOnWiFiNetworksFor(_ trustedNetworks: [String: Int],
                                                    _ vpn: NEVPNManager) {
                
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
    
    private func configureDefaultOnDemandRules(_ force: Bool,
                                               _ vpn: NEVPNManager,
                                               _ configuration: VPNConfiguration) {
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
