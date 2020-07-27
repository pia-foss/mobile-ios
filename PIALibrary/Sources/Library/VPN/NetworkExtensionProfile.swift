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
public protocol NetworkExtensionProfile: VPNProfile {

    /**
     Returns a native `NEVPNProtocol` from this profile given a configuration.
     
     - Parameter configuration: The `VPNConfiguration` to build the protocol upon.
     - Returns: A native `NEVPNProtocol` object for use with NetworkExtension.
     */
    func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol
}

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
        vpn.protocolConfiguration = generatedProtocol(withConfiguration: configuration)
        guard let protocolConfiguration = vpn.protocolConfiguration else {
            fatalError("Never provided a configuration?")
        }
        
        vpn.localizedDescription = configuration.name
        vpn.isOnDemandEnabled = Client.providers.vpnProvider.isVPNConnected || vpn.isEnabled ?
            configuration.isOnDemand :
            false //if the VPN is disconnected, don't activate the onDemand property to don't autoconnect the VPN without user permission
        
        //TODO
        let trustedNetworks = [""] //Client.preferences.nmtTrustedNetworkRules
        
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
    
    
    private func configureOnDemandOnWiFiNetworksFor(_ trustedNetworks: [String],
                                                    _ vpn: NEVPNManager) {
        
        if true {
            
            let ruleDisconnect = NEOnDemandRuleDisconnect()
            ruleDisconnect.interfaceTypeMatch = .wiFi
            if let currentSSID = UIDevice.current.WiFiSSID {
                let filteredNetworkList = trustedNetworks.filter({
                    return $0 != currentSSID
                })
                ruleDisconnect.ssidMatch = filteredNetworkList
                let ruleIgnore = NEOnDemandRuleIgnore()
                ruleIgnore.interfaceTypeMatch = .wiFi
                ruleIgnore.ssidMatch = [currentSSID]
                if trustedNetworks.contains(currentSSID) {
                    vpn.onDemandRules?.append(ruleIgnore) //Only add the ignore rule if the current WiFi network is a trusted network
                }
            } else {
                ruleDisconnect.ssidMatch = trustedNetworks
            }
            
            let ruleConnect = NEOnDemandRuleConnect()
            ruleConnect.interfaceTypeMatch = .wiFi
            if true {
                vpn.onDemandRules = [ruleConnect]
            } else if ruleDisconnect.ssidMatch?.count == 0 {
                vpn.onDemandRules?.append(ruleConnect)
            } else {
                vpn.onDemandRules?.append(contentsOf: [ruleDisconnect, ruleConnect])
            }
        } else {
            if let _ = UIDevice.current.WiFiSSID { //If trying to connect from a WiFi network...
                let ruleIgnore = NEOnDemandRuleIgnore()
                ruleIgnore.interfaceTypeMatch = .wiFi
                vpn.onDemandRules?.append(ruleIgnore)
            } else {
                let ruleDisconnect = NEOnDemandRuleDisconnect()
                ruleDisconnect.interfaceTypeMatch = .wiFi
                vpn.onDemandRules?.append(ruleDisconnect)
            }
        }
    }
    
    private func configureOnDemandOnCellularNetworks(_ vpn: NEVPNManager) {
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
