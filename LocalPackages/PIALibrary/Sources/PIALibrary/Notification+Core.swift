//
//  Notification+Core.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
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
    
    // MARK: Account

    /// - Seealso: `AccountProvider.login(...)`
    public static let PIAAccountDidLogin = Notification.Name("PIAAccountDidLogin")
    
    /// - Seealso: `AccountProvider.refreshAccountInfo(...)`
    public static let PIAAccountDidRefresh = Notification.Name("PIAAccountDidRefresh")
    
    /// - Seealso: `AccountProvider.update(...)`
    public static let PIAAccountDidUpdate = Notification.Name("PIAAccountDidUpdate")
    
    /// - Seealso: `AccountProvider.login(...)`
    public static let PIAAccountDidLogout = Notification.Name("PIAAccountDidLogout")
    
    /// - Seealso: `AccountProvider.signup(...)`
    public static let PIAAccountDidSignup = Notification.Name("PIAAccountDidSignup")
    
    /// - Seealso: `AccountProvider.renew(...)`
    public static let PIAAccountDidRenew = Notification.Name("PIAAccountDidRenew")
    
    public static let PIAAccountLapsed = Notification.Name("PIAAccountLapsed")
    
    // MARK: Server
    
    /// - Seealso: `ServerProvider.currentServers`
    public static let PIAServerDidUpdateCurrentServers = Notification.Name("PIAServerDidUpdateCurrentServers")

    // MARK: VPN

    /// - Seealso: `VPNProvider.install(...)`
    public static let PIAVPNDidInstall = Notification.Name("PIAVPNDidInstall")

    public static let PIAVPNUsageUpdate = Notification.Name("PIAVPNUsageUpdate")

    public static let PIAVPNDidFail = Notification.Name("PIAVPNDidFail")

    #if os(iOS) || os(tvOS)
    
    // MARK: InApp
    
    public static let __InAppDidFetchProducts = Notification.Name("__InAppDidFetchProducts")
    
    public static let __InAppDidAddUncredited = Notification.Name("__InAppDidAddUncredited")
    
    // MARK: Feature Flags
    
    public static let __AppDidFetchFeatureFlags = Notification.Name("__AppDidFetchFeatureFlags")
    
    #endif
}
