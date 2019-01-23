//
//  IKEv2Profile.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 21/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension
import SwiftyBeaver

private let log = SwiftyBeaver.self

/// Implementation of `VPNProfile` providing IKEv2 connectivity.
public class IKEv2Profile: NetworkExtensionProfile {
    
    private var currentVPN: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    init() {
    }
    
    // MARK: VPNProfile
    
    /// :nodoc:
    public static var vpnType: String {
        return "IKEv2"
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
            if Client.preferences.trustCellularData {
                self.currentVPN.isOnDemandEnabled = false
            }
            
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
            if Client.preferences.trustCellularData {
                self.currentVPN.isOnDemandEnabled = false
            }
            self.currentVPN.saveToPreferences(completionHandler: callback)
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
        let cfg = NEVPNProtocolIKEv2()
        cfg.serverAddress = configuration.server.hostname
        cfg.remoteIdentifier = configuration.server.hostname
        cfg.localIdentifier = configuration.username
        cfg.username = configuration.username
        cfg.passwordReference = configuration.passwordReference
        
        cfg.authenticationMethod = .none
        cfg.disconnectOnSleep = false
        cfg.useExtendedAuthentication = true
        
        return cfg
    }
}
