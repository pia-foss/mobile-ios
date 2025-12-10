//
//  PIATunnelProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
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
#if os(iOS)
import Foundation
import TunnelKitOpenVPN
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
            
            // prevent reconnection
            vpn.isOnDemandEnabled = false

            vpn.saveToPreferences { (error) in
                if let error = error {
                    vpn.connection.stopVPNTunnel()
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
                callback?(nil)
            }
        }
    }

    /// :nodoc:
    public func disable(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                return
            }
            vpn.isEnabled = false
            vpn.isOnDemandEnabled = false
            vpn.saveToPreferences(completionHandler: callback)
        }
    }
    
    /// :nodoc:
    public func remove(_ callback: SuccessLibraryCallback?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil)
                return
            }
            vpn.removeFromPreferences(completionHandler: callback)
        }
    }
    
    /// :nodoc:
    public func parsedCustomConfiguration(from map: [String : Any]) -> VPNCustomConfiguration? {
        //Migrate OVPN library
        if map.count > 5 {
            //old client. needs migration
            var newMap = migrateOVPNConfigurationMap(from: map)
            return try? OpenVPNProvider.Configuration.parsed(from: newMap)
        }
        return try? OpenVPNProvider.Configuration.parsed(from: map)
    }
    
    private func migrateOVPNConfigurationMap(from map: [String: Any]) -> [String: Any] {
        var updatedMap = [String: Any]()
        updatedMap["appGroup"] = map["AppGroup"]
        updatedMap["prefersResolvedAddresses"] = map["PrefersResolvedAddresses"]
        updatedMap["masksPrivateData"] = map["MasksPrivateData"]
        updatedMap["shouldDebug"] = map["Debug"]
        
        var sessionConfigurationMap = [String: Any]()
        sessionConfigurationMap["cipher"] = map["CipherAlgorithm"]
        sessionConfigurationMap["digest"] = map["DigestAlgorithm"]
        sessionConfigurationMap["ca"] = map["CA"]
        sessionConfigurationMap["mtu"] = map["MTU"]
        sessionConfigurationMap["usesPIAPatches"] = map["UsesPIAPatches"]
        sessionConfigurationMap["dnsServers"] = map["DNSServers"]
        sessionConfigurationMap["endpointProtocols"] = map["EndpointProtocols"]
        sessionConfigurationMap["renegotiatesAfter"] = map["RenegotiatesAfter"]

        updatedMap["sessionConfiguration"] = sessionConfigurationMap
        
        return updatedMap
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
                try session?.sendProviderMessage(OpenVPNProvider.Message.requestLog.data) { (data) in
                    guard let data = data, !data.isEmpty else {
                        guard let providerConfiguration = customConfiguration as? OpenVPNProvider.Configuration else {
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

    /// :nodoc:
    public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: ((Usage?, Error?) -> Void)?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil, error)
                return
            }
            
            do {
                let session = vpn.connection as? NETunnelProviderSession
                try session?.sendProviderMessage(OpenVPNProvider.Message.dataCount.data) { (data) in
                    guard let data = data, !data.isEmpty else {
                        guard let _ = customConfiguration as? OpenVPNProvider.Configuration else {
                            callback?(nil, nil)
                            return
                        }
                        callback?(nil, ClientError.vpnProfileUnavailable)
                        return
                    }
                    
                    let downloaded = data.getInt64(start: 0)
                    let uploaded = data.getInt64(start: 8)
                    let usage = Usage(uploaded: uploaded, downloaded: downloaded)
                    callback?(usage,
                              nil)
                }
            } catch let e {
                callback?(nil, e)
            }
        }
    }
    
    // MARK: NetworkExtensionProfile
    
    /// :nodoc:
    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {
        
        var serverAddress = ""
        var customCfg = configuration.customConfiguration
        if let piaCfg = customCfg as? OpenVPNProvider.Configuration {
            var builder = piaCfg.builder()
            
            if let usesVanillaOpenVPN = configuration.server.bestAddressForOVPN(tcp: true)?.van, usesVanillaOpenVPN == true {
                builder.sessionConfiguration.usesPIAPatches = false
            } else {
                builder.sessionConfiguration.usesPIAPatches = true //SET TO FALSE TO USE NATIVE OVPN
            }

            if let protocols = builder.sessionConfiguration.endpointProtocols, protocols.contains(where: {$0.socketType == .tcp }) {
                if let bestAddress = configuration.server.bestAddressForOVPN(tcp: true)?.ip {
                    serverAddress = bestAddress
                    builder.resolvedAddresses = [bestAddress]
                }
            } else {
                if let bestAddress = configuration.server.bestAddressForOVPN(tcp: false)?.ip {
                    serverAddress = bestAddress
                    builder.resolvedAddresses = [bestAddress]
                }
            }
            customCfg = builder.build()
        }
        
        var username = configuration.username
        var passwordReference = configuration.passwordReference
        
        if let accountVpnUsername = Client.providers.accountProvider.vpnTokenUsername,
           let accountVpnPassword = Client.providers.accountProvider.vpnTokenPassword {
            username =  accountVpnUsername
            Client.database.secure.setPassword(accountVpnPassword, for: username)
        }
        
        if let accountVpnPasswordreference = Client.database.secure.passwordReference(for: username) {
            passwordReference = accountVpnPasswordreference
        }

        let cfg = NETunnelProviderProtocol()
        cfg.disconnectOnSleep = configuration.disconnectsOnSleep
        cfg.username = configuration.server.dipUsername ?? username
        cfg.passwordReference =  configuration.server.dipUsername != nil ? configuration.server.dipPassword() : passwordReference
        cfg.serverAddress = serverAddress
        cfg.providerBundleIdentifier = bundleIdentifier
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

    private func lastLogSnapshot(withProviderConfiguration providerConfiguration: OpenVPNProvider.Configuration) -> String? {
        guard let defaults = UserDefaults(suiteName: Client.Configuration.appGroup) else {
            return nil
        }
        guard let lines = defaults.array(forKey: Client.Configuration.debugLogKey) as? [String] else {
            return nil
        }
        return lines.joined(separator: "\n")
    }
}
#endif
