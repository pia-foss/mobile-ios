//
//  Notification+App.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
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
import PIALibrary

extension Notification.Name {
    
    static let RefreshSettings = Notification.Name("RefreshSettings")
    static let ReloadSettings = Notification.Name("ReloadSettings")
    static let ResetSettingsNavigationStack = Notification.Name("ResetSettingsNavigationStack")
    static let Unauthorized = Notification.Name("Unauthorized")
    static let OpenSettings = Notification.Name("OpenSettings")
    static let RefreshNMTRules = Notification.Name("RefreshNMTRules")
    static let ShowCustomNMTNetworks = Notification.Name("ShowCustomNMTNetworks")
    static let TrustedNetworkAdded = Notification.Name("TrustedNetworkAdded")
    static let OpenSettingsAndActivateWireGuard = Notification.Name("OpenSettingsAndActivateWireGuard")
    static let RefreshWireGuardSettings = Notification.Name("RefreshWireGuardSettings")
    static let DedicatedIpReload = Notification.Name("DedicatedIpReload")
    static let DedicatedIpShowAnimation = Notification.Name("DedicatedIpShowAnimation")
    static let DedicatedIpHideAnimation = Notification.Name("DedicatedIpHideAnimation")

}

extension NotificationKey {
    static let downloaded = NotificationKey("DownloadedKey")

    static let uploaded = NotificationKey("UploadedKey")

}
