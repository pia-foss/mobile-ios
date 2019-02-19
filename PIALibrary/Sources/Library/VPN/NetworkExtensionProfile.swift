//
//  NetworkExtensionProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/25/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
        vpn.isOnDemandEnabled = configuration.isOnDemand
        
        let trustedNetworks = Client.preferences.trustedNetworks
        let ruleDisconnect = NEOnDemandRuleDisconnect()
        ruleDisconnect.ssidMatch = trustedNetworks
        
        vpn.onDemandRules = []
        
        if vpn.isOnDemandEnabled {
            let wiFiRule = NEOnDemandRuleConnect()
            wiFiRule.interfaceTypeMatch = .wiFi
            vpn.onDemandRules = [wiFiRule]
            if Client.preferences.useWiFiProtection,
                Client.preferences.disconnectOnTrusted,
                trustedNetworks.count > 0 {
                vpn.onDemandRules?.append(ruleDisconnect)
            }
        }

        //Configure onDemand rules
        if !Client.preferences.trustCellularData {
            vpn.isOnDemandEnabled = true
            let cellularRule = NEOnDemandRuleConnect()
            cellularRule.interfaceTypeMatch = .cellular
            vpn.onDemandRules?.append(cellularRule)
            if Client.preferences.useWiFiProtection,
                Client.preferences.disconnectOnTrusted,
                trustedNetworks.count > 0 {
                vpn.onDemandRules?.append(ruleDisconnect)
            }
        } else {
            //trust cellular data = true
            if Client.preferences.disconnectOnTrusted {
                let cellularRule = NEOnDemandRuleDisconnect()
                cellularRule.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(cellularRule)
            } else {
                let cellularRule = NEOnDemandRuleConnect()
                cellularRule.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(cellularRule)
            }
        }
        
        if !Client.preferences.connectOnUntrusted {
            let wiFiRule = NEOnDemandRuleDisconnect()
            wiFiRule.interfaceTypeMatch = .wiFi
            vpn.onDemandRules = [wiFiRule]
            if !Client.preferences.trustCellularData {
                let cellularRule = NEOnDemandRuleDisconnect()
                cellularRule.interfaceTypeMatch = .cellular
                vpn.onDemandRules?.append(cellularRule)
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
}
