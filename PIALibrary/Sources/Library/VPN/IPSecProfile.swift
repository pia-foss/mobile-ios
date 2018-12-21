//
//  IPSecProfile.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

private let log = SwiftyBeaver.self

/// Implementation of `VPNProfile` providing IPsec connectivity.
public class IPSecProfile: NetworkExtensionProfile {
    private static let identity = "client-ikev1"
    
//    private static let identityCommonName = "*.privateinternetaccess.com"
    
    private static let identityData: Data = {
        let bundle = Bundle(for: IPSecProfile.self)
        guard let url = bundle.url(forResource: "IPsec-Client", withExtension: "p12") else {
            fatalError("Could not find IPSec identity file")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load IPSec identity data")
        }
        return data
    }()
    
    private static let identityPassword = "password12"

    private var currentVPN: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    init() {
    }
    
    // MARK: VPNProfile

    /// :nodoc:
    public static var vpnType: String {
        return "IPsec"
    }
    
    /// :nodoc:
    public static var isTunnel: Bool {
        return false
    }

    /// :nodoc:
    public var native: Any? {
        return currentVPN
    }
    
    /// :nodoc:
    public func prepare() {
        currentVPN.loadFromPreferences { (_) in
        }
    }
    
    /// :nodoc:
    public func save(withConfiguration configuration: VPNConfiguration, force: Bool, _ callback: SuccessLibraryCallback?) {
        currentVPN.loadFromPreferences { (error) in
            if let error = error {
                callback?(error)
                return
            }
            self.doSave(self.currentVPN, withConfiguration: configuration, force: force, callback)
        }
    }
    
    /// :nodoc:
    public func connect(withConfiguration configuration: VPNConfiguration, _ callback: SuccessLibraryCallback?) {
        save(withConfiguration: configuration, force: true) { (error) in
            if let error = error {
                callback?(error)
                return
            }
            do {
                try self.currentVPN.connection.startVPNTunnel()
                callback?(nil)
            } catch let e {
                callback?(e)
            }
        }
    }
    
    /// :nodoc:
    public func disconnect(_ callback: SuccessLibraryCallback?) {
        currentVPN.loadFromPreferences { (error) in
            if let error = error {
                callback?(error)
                return
            }

            // prevent reconnection
            self.configureOnDemandSetting()
            self.currentVPN.saveToPreferences { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                self.currentVPN.connection.stopVPNTunnel()
                callback?(nil)
            }
        }
    }
    
    /// :nodoc:
    public func updatePreferences(_ callback: SuccessLibraryCallback?) {
        currentVPN.loadFromPreferences { (error) in
            if let error = error {
                callback?(error)
                return
            }
            
            // prevent reconnection
            self.configureOnDemandSetting()
            self.currentVPN.saveToPreferences { (error) in
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
        currentVPN.loadFromPreferences { (error) in
            self.currentVPN.removeFromPreferences(completionHandler: callback)
        }
    }
    
    /// :nodoc:
    public func disable(_ callback: SuccessLibraryCallback?) {
        currentVPN.loadFromPreferences { (error) in
            self.currentVPN.isEnabled = false
            self.configureOnDemandSetting()
            self.currentVPN.saveToPreferences(completionHandler: callback)
        }
    }
    
    private func configureOnDemandSetting() {
        if Client.preferences.trustCellularData {
            self.currentVPN.isOnDemandEnabled = false
        } else {
            self.currentVPN.isOnDemandEnabled = true
            let cellularRule = NEOnDemandRuleConnect()
            cellularRule.interfaceTypeMatch = .cellular
            self.currentVPN.onDemandRules = [cellularRule]
        }
    }

    /// :nodoc:
    public func parsedCustomConfiguration(from map: [String: Any]) -> VPNCustomConfiguration? {
        return nil
    }
    
    /// :nodoc:
    public func requestLog(withCustomConfiguration customConfiguration: VPNCustomConfiguration?, _ callback: ((String?, Error?) -> Void)?) {
        callback?(nil, ClientError.unsupported)
    }
    
    // MARK: NetworkExtensionProfile
    
    /// :nodoc:
    public func generatedProtocol(withConfiguration configuration: VPNConfiguration) -> NEVPNProtocol {
        let cfg = NEVPNProtocolIPSec()
        cfg.localIdentifier = IPSecProfile.identity
        cfg.remoteIdentifier = configuration.server.hostname
        cfg.useExtendedAuthentication = true
        cfg.authenticationMethod = .certificate
        cfg.disconnectOnSleep = configuration.disconnectsOnSleep
        
        cfg.identityData = IPSecProfile.identityData
        cfg.identityDataPassword = IPSecProfile.identityPassword
        cfg.username = configuration.username
        cfg.passwordReference = configuration.passwordReference
        cfg.serverAddress = configuration.server.hostname
        return cfg
    }
}
