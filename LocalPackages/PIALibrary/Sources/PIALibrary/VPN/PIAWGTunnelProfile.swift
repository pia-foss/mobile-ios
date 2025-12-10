//
//  PIAWGTunnelProfile.swift
//  PIALibrary
//  
//  Created by Jose Antonio Blaya Garcia on 06/02/2020.
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
#if os(iOS)
import PIAWireguard
import NetworkExtension

/// Implementation of `VPNProfile` providing OpenVPN connectivity.

public class PIAWGTunnelProfile: NetworkExtensionProfile {
    
    public func parsedCustomConfiguration(from map: [String : Any]) -> VPNCustomConfiguration? {
        
        let S = PIAWireguardConfiguration.Keys.self
        let defaultMTU = 1280

        if let dnsServers = map[S.dnsServers] as? [String], let packetSize = map[S.packetSize] as? Int {
            return PIAWireguardConfiguration(customDNSServers: dnsServers, packetSize: packetSize)
        }
        
        return PIAWireguardConfiguration(customDNSServers: [], packetSize: defaultMTU)

    }
    
    
    public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<String>?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil, error)
                return
            }
            
            do {
                let session = vpn.connection as? NETunnelProviderSession
                if #available(iOS 12.0, *) {
                    try session?.sendProviderMessage(WGPacketTunnelProvider.Message.requestLog.data) { (data) in
                        guard let data = data, !data.isEmpty else {
                            callback?(nil, nil)
                            return
                        }
                        let log = String(data: data, encoding: .utf8)
                        callback?(log, nil)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } catch let e {
                callback?(nil, e)
            }
        }

    }
    
    public func requestDataUsage(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: LibraryCallback<Usage>?) {
        find { (vpn, error) in
            guard let vpn = vpn else {
                callback?(nil, error)
                return
            }
            
            do {
                let session = vpn.connection as? NETunnelProviderSession
                if #available(iOS 12.0, *) {
                    try session?.sendProviderMessage(WGPacketTunnelProvider.Message.dataCount.data) { (data) in
                        guard let data = data, !data.isEmpty else {
                            callback?(nil, ClientError.vpnProfileUnavailable)
                            return
                        }
                        
                        let downloaded = data.getInt64(start: 0)
                        let uploaded = data.getInt64(start: 8)
                        let usage = Usage(uploaded: uploaded, downloaded: downloaded)
                        callback?(usage,
                                  nil)
                    }
                } else {
                    // Fallback on earlier versions
                }
            } catch let e {
                callback?(nil, e)
            }
        }

    }
    
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
        return "PIAWG"
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
        
    // MARK: NetworkExtensionProfile
    
    /// :nodoc:
    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) throws -> NEVPNProtocol {
        var serverAddress = configuration.server.hostname
        var serverCN = ""
        if let ip = configuration.server.bestAddress()?.ip,
            let cn = configuration.server.bestAddress()?.cn {
            serverAddress = ip
            serverCN = cn
        }

        let cfg = NETunnelProviderProtocol()
        cfg.providerBundleIdentifier = bundleIdentifier
        cfg.serverAddress = serverAddress
        cfg.username = Client.providers.accountProvider.publicUsername
        cfg.disconnectOnSleep = configuration.disconnectsOnSleep

        let token = configuration.server.dipUsername != nil ? configuration.server.dipUsername : (Client.providers.accountProvider.vpnToken ?? Client.providers.accountProvider.oldToken)
        guard let token = token else {
            throw ClientError.missingWireguardToken
        }

        cfg.providerConfiguration = [PIAWireguardConfiguration.Keys.token: token,
                                     PIAWireguardConfiguration.Keys.ping: configuration.server.bestAddress()?.description,
                                     PIAWireguardConfiguration.Keys.serial: configuration.server.serial,
                                     PIAWireguardConfiguration.Keys.cn: serverCN,
                                     PIAWireguardConfiguration.Keys.useIP: true]

        var customCfg = configuration.customConfiguration
        if let piaCfg = customCfg as? PIAWireguardConfiguration {
            cfg.providerConfiguration?[PIAWireguardConfiguration.Keys.dnsServers] = piaCfg.customDNSServers
            cfg.providerConfiguration?[PIAWireguardConfiguration.Keys.packetSize] = piaCfg.packetSize
        }

        return cfg
    }
    
    // MARK: Helpers
    
    private func find(completionHandler: LibraryCallback<NETunnelProviderManager>?) {
        PIAWGTunnelProfile.find(withBundleIdentifier: bundleIdentifier) { (vpn, error) in
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

}
#endif
