//
//  Notification+Library.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/24/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

extension Notification.Name {

    // MARK: Daemons (passive updates)
    
    /// The daemons finished pinging the servers.
    ///
    /// - Seealso: `Client.Daemons`
    public static let PIADaemonsDidPingServers = Notification.Name("PIADaemonsDidPingServers")
    
    /// The daemons did update connectivity status.
    ///
    /// - Seealso: `Client.Daemons`
    public static let PIADaemonsDidUpdateConnectivity = Notification.Name("PIADaemonsDidUpdateConnectivity")
    
    /// The daemons did report a VPN status update.
    ///
    /// - Seealso: `Client.Daemons`
    public static let PIADaemonsDidUpdateVPNStatus = Notification.Name("PIADaemonsDidUpdateVPNStatus")
    
    // MARK: Servers
    
    /// The target server has been updated.
    ///
    /// - Seealso: `Client.Daemons`
    public static let PIAServerHasBeenUpdated = Notification.Name("PIAServerHasBeenUpdated")
    
}

extension NotificationKey {
    
    /// A `VPNStatus` object.
    public static let vpnStatus = NotificationKey("VPNStatusKey")

    /// A `VPNAction` object.
    public static let vpnAction = NotificationKey("VPNActionKey")
}
