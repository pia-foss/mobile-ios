//
//  PIATunnelProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIATunnel
import NetworkExtension

/// Implementation of `VPNProfile` providing OpenVPN connectivity.
public class PIATunnelProfile: NetworkExtensionProfile {
    private let bundleIdentifier: String

    /**
     Default initializer.
     
     - Parameter bundleIdentifier: The bundle identifier of a Packet Tunnel Provider extension subclassing `PIATunnelProvider` from `PIATunnel`.
     */
    public init(bundleIdentifier: String) {
        self.bundleIdentifier = bundleIdentifier
    }
    
    // MARK: VPNProfile
    
    /// :nodoc:
    public static var vpnType: String {
        return "PIA"
    }
    
    /// :nodoc:
    public static var isTunnel: Bool {
        return true
    }
    
    /// :nodoc:
    public var native: Any?
    
    /// :nodoc:
    public func prepare() {
        find(completionHandler: nil)
    }
    
    /// :nodoc:
    public func save(withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }
            self.doSave(vpn, withConfiguration: configuration, force: force, callback)
        }
    }
    
    /// :nodoc:
    public func connect(withConfiguration configuration: VPNConfiguration, _ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }
            self.doSave(vpn, withConfiguration: configuration, force: true) { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                do {
                    let session = vpn.connection as? NETunnelProviderSession
                    try session?.startTunnel(options: nil)
                    callback?(nil)
                } catch let e {
                    callback?(e)
                }
            }
        }
    }
    
    /// :nodoc:
    public func disconnect(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }
            
            vpn.saveToPreferences { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                vpn.connection.stopVPNTunnel()
                callback?(nil)
            }
        }
    }
    
    /// :nodoc:
    public func updatePreferences(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(error)
                return
            }
            
            vpn.saveToPreferences { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                self.configureOnDemandSetting()
                callback?(nil)
            }
        }
    }
    
    private func configureOnDemandSetting() {
        find { (vpn, error) in
            guard let vpn = vpn else {
                return
            }
            if Client.preferences.trustCellularData {
                vpn.isOnDemandEnabled = false
            } else {
                vpn.isOnDemandEnabled = true
                let cellularRule = NEOnDemandRuleConnect()
                cellularRule.interfaceTypeMatch = .cellular
                vpn.onDemandRules = [cellularRule]
            }
            vpn.saveToPreferences(completionHandler: nil)
        }

    }

    /// :nodoc:
    public func disable(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                return
            }
            vpn.isEnabled = false
            vpn.saveToPreferences(completionHandler: callback)
            vpn.saveToPreferences { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                callback?(nil)
            }
        }
    }
    
    /// :nodoc:
    public func remove(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                return
            }
            vpn.removeFromPreferences(completionHandler: callback)
        }
    }
    
    /// :nodoc:
    public func parsedCustomConfiguration(from map: [String : Any]) -> VPNCustomConfiguration? {
        return try? PIATunnelProvider.Configuration.parsed(from: map)
    }
    
    /// :nodoc:
    public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: ((String?, Error?) -> Void)?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil, error)
                return
            }
            
            do {
                let session = vpn.connection as? NETunnelProviderSession
                try session?.sendProviderMessage(PIATunnelProvider.Message.requestLog.data) { (data) in
                    guard let data = data, !data.isEmpty else {
                        guard let providerConfiguration = customConfiguration as? PIATunnelProvider.Configuration else {
                            callback?(nil, nil)
                            return
                        }
                        guard let recentLog = self.lastLogSnapshot(withProviderConfiguration: providerConfiguration) else {
                            callback?(nil, nil)
                            return
                        }
                        callback?(recentLog, nil)
                        return
                    }
                    let log = String(data: data, encoding: .utf8)
                    callback?(log, nil)
                }
            } catch let e {
                callback?(nil, e)
            }
        }
    }
    
    // MARK: NetworkExtensionProfile
    
    /// :nodoc:
    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {
        let cfg = NETunnelProviderProtocol()
        cfg.disconnectOnSleep = configuration.disconnectsOnSleep
        
        cfg.username = configuration.username
        cfg.passwordReference = configuration.passwordReference
        cfg.serverAddress = configuration.server.hostname
        cfg.providerBundleIdentifier = bundleIdentifier
        
        var customCfg = configuration.customConfiguration
        if let piaCfg = customCfg as? PIATunnelProvider.Configuration {
            var builder = piaCfg.builder()
            if let bestAddress = configuration.server.bestOpenVPNAddressForUDP?.hostname { // XXX: UDP address = TCP address
                builder.resolvedAddresses = [bestAddress]
            }
            customCfg = builder.build()
        }

        cfg.providerConfiguration = customCfg?.serialized()
        return cfg
    }
    
    // MARK: Helpers
    
    private func find(completionHandler: LibraryCallback<NETunnelProviderManager>?) {
        PIATunnelProfile.find(withBundleIdentifier: bundleIdentifier) { (vpn, error) in
            self.native = vpn
            completionHandler?(vpn, error)
        }
    }

    private static func find(withBundleIdentifier identifier: String?, completionHandler: LibraryCallback<NETunnelProviderManager>?) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers else {
                completionHandler?(nil, error)
                return
            }
            var foundVPN: NETunnelProviderManager?
            for m in managers {
                guard let tunnelProtocol = m.protocolConfiguration as? NETunnelProviderProtocol else {
                    continue
                }
                guard ((identifier == nil) || (tunnelProtocol.providerBundleIdentifier == identifier)) else {
                    continue
                }
                foundVPN = m
                break
            }
            let vpn = foundVPN ?? NETunnelProviderManager()
            completionHandler?(vpn, nil)
        }
    }

    private func lastLogSnapshot(withProviderConfiguration providerConfiguration: PIATunnelProvider.Configuration) -> String? {
        guard let logKey = providerConfiguration.debugLogKey else {
            return nil
        }
        guard let defaults = UserDefaults(suiteName: providerConfiguration.appGroup) else {
            return nil
        }
        guard let lines = defaults.array(forKey: logKey) as? [String] else {
            return nil
        }
        return lines.joined(separator: "\n")
    }
}
