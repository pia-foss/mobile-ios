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
        
        vpn.onDemandRules = []
        
        if vpn.isOnDemandEnabled {
            
            if Client.preferences.disconnectOnTrusted {
                let ruleDisconnect = NEOnDemandRuleDisconnect()
                ruleDisconnect.interfaceTypeMatch = .wiFi
                ruleDisconnect.ssidMatch = trustedNetworks
                if Client.preferences.useWiFiProtection {
                    let ruleConnect = NEOnDemandRuleConnect()
                    ruleConnect.interfaceTypeMatch = .wiFi
                    if Client.preferences.shouldConnectForAllNetworks {
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
                if !Client.preferences.trustCellularData {
                    let ruleConnect = NEOnDemandRuleConnect()
                    ruleConnect.interfaceTypeMatch = .cellular
                    vpn.onDemandRules?.append(ruleConnect)
                } else {
                    if let _ = UIDevice.current.WiFiSSID { //If trying to connect from a Cellular network...
                        let ruleDisconnect = NEOnDemandRuleDisconnect()
                        ruleDisconnect.interfaceTypeMatch = .cellular
                        vpn.onDemandRules?.append(ruleDisconnect)
                    } else {
                        let ruleIgnore = NEOnDemandRuleIgnore()
                        ruleIgnore.interfaceTypeMatch = .cellular
                        vpn.onDemandRules?.append(ruleIgnore)
                    }
                }
            } else {
                if !Client.preferences.trustCellularData {
                    let ruleConnect = NEOnDemandRuleConnect()
                    ruleConnect.interfaceTypeMatch = .cellular
                    vpn.onDemandRules?.append(ruleConnect)
                }
                
                if Client.preferences.useWiFiProtection {
                    if Client.preferences.shouldConnectForAllNetworks {
                        let ruleConnect = NEOnDemandRuleConnect()
                        ruleConnect.interfaceTypeMatch = .wiFi
                        vpn.onDemandRules?.append(ruleConnect)
                    } else {
                        let ruleIgnore = NEOnDemandRuleIgnore()
                        ruleIgnore.interfaceTypeMatch = .wiFi
                        ruleIgnore.ssidMatch = trustedNetworks
                        vpn.onDemandRules?.append(ruleIgnore)
                        
                        let ruleConnect = NEOnDemandRuleConnect()
                        ruleConnect.interfaceTypeMatch = .wiFi
                        vpn.onDemandRules?.append(ruleConnect)
                    }
                }
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
