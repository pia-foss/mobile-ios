//
//  MockVPNProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Simulates VPN-related operations
public class MockVPNProvider: VPNProvider, ConfigurationAccess, DatabaseAccess {

    /// Fakes the public IP address.
    public var mockPublicIP: String? = "192.168.12.78"
    
    /// Fakes the VPN IP address.
    public var mockVpnIP: String? = "4.4.4.4"
    
    /// :nodoc:
    public init() {
    }
    
    // MARK: VPNProvider

    /// :nodoc:
    public var availableVPNTypes: [String] = []
    
    /// :nodoc:
    public var currentVPNType: String {
        return "Mock"
    }

    /// :nodoc:
    public var vpnStatus: VPNStatus {
        get {
            return accessedDatabase.transient.vpnStatus
        }
        set {
            accessedDatabase.transient.vpnStatus = newValue
        }
    }
    
    /// :nodoc:
    public var profileServer: Server? {
        return nil
    }
    
    /// :nodoc:
    public func prepare() {
        accessedDatabase.transient.isNetworkReachable = true
        accessedDatabase.transient.isInternetReachable = true
        accessedDatabase.transient.publicIP = mockPublicIP
        accessedDatabase.transient.vpnIP = mockVpnIP

        Macros.postNotification(.PIADaemonsDidUpdateVPNStatus)
    }
    
    /// :nodoc:
    public func install(_ callback: SuccessLibraryCallback?) {
        Macros.postNotification(.PIAVPNDidInstall)
        callback?(nil)
    }
    
    /// :nodoc:
    public func uninstall(_ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    /// :nodoc:
    public func uninstallAll() {
    }
    
    /// :nodoc:
    public func connect(_ callback: SuccessLibraryCallback?) {
        vpnStatus = .connected
        Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
        callback?(nil)
    }
    
    /// :nodoc:
    public func disable(_ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    /// :nodoc:
    public func disconnect(_ callback: SuccessLibraryCallback?) {
        vpnStatus = .disconnected
        Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
        callback?(nil)
    }
    
    /// :nodoc:
    public func updatePreferences(_ callback: SuccessLibraryCallback?) {
        Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
        callback?(nil)
    }
    
    /// :nodoc:
    public func reconnect(after delay: Int?, _ callback: SuccessLibraryCallback?) {
        let disconnectionDelay: Int
//        if (vpnStatus == .changingServer) {
//            disconnectionDelay = 1000
//        } else {
            vpnStatus = .disconnecting
            disconnectionDelay = 200
//        }

        Macros.dispatch(after: .milliseconds(disconnectionDelay)) {
            self.vpnStatus = .disconnected
            Macros.postNotification(.PIADaemonsDidUpdateConnectivity)

            Macros.dispatch(after: .milliseconds(delay ?? self.accessedConfiguration.vpnReconnectionDelay)) {
                self.vpnStatus = .connected
                Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
                callback?(nil)
            }
        }
    }
    
    /// :nodoc:
    public func submitLog(_ callback: ((DebugLog?, Error?) -> Void)?) {
        callback?(nil, ClientError.unsupported)
    }
}
