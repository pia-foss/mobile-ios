//
//  MockVPNProvider.swift
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

import Foundation

/// Simulates VPN-related operations
@available(tvOS 17.0, *)
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
        accessedDatabase.plain.publicIP = mockPublicIP
        accessedDatabase.transient.vpnIP = mockVpnIP

        Macros.postNotification(.PIADaemonsDidUpdateVPNStatus)
    }
    
    /// :nodoc:
    public func install(force forceInstall: Bool, _ callback: SuccessLibraryCallback?) {
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
    public func reconnect(after delay: Int?, forceDisconnect: Bool = false, _ callback: SuccessLibraryCallback?) {
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
    public func submitDebugReport(_ shouldSendPersistedData: Bool, _ callback: LibraryCallback<String>?) {
        callback?(nil, ClientError.unsupported)
    }
    
    /// :nodoc:
    public func dataUsage(_ callback: LibraryCallback<Usage>?) {
        callback?(nil, ClientError.unsupported)
    }
    
    public func needsMigrationToGEN4() -> Bool {
        return false
    }
}
