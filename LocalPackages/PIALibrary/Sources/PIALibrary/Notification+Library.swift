//
//  Notification+Library.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/24/17.
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
    
    public static let PIADaemonsConnectingVPNStatus = Notification.Name("PIADaemonsStillConnectingVPNStatus")

    // MARK: Servers
    
    /// The target server has been updated.
    ///
    /// - Seealso: `Client.Daemons`
    public static let PIAServerHasBeenUpdated = Notification.Name("PIAServerHasBeenUpdated")
    
    public static let PIASettingsHaveChanged = Notification.Name("PIASettingsHaveChanged")
    public static let PIAQuickSettingsHaveChanged = Notification.Name("PIAQuickSettingsHaveChanged")

    public static let PIAPersistentConnectionSettingHaveChanged = Notification.Name("PIAPersistentConnectionSettingHaveChanged")
    public static let PIAPersistentConnectionTileHaveChanged = Notification.Name("PIAPersistentConnectionTileHaveChanged")

    public static let PIADIPRegionExpiring = Notification.Name("PIADIPRegionExpiring")
    public static let PIADIPCheckIP = Notification.Name("PIADIPCheckIP")

}

extension NotificationKey {
    
    /// A `VPNStatus` object.
    public static let vpnStatus = NotificationKey("VPNStatusKey")

    /// A `VPNAction` object.
    public static let vpnAction = NotificationKey("VPNActionKey")
}
