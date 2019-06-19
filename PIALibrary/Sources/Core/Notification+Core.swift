//
//  Notification+Core.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    
    // MARK: Server
    
    /// - Seealso: `ServerProvider.currentServers`
    public static let PIAServerDidUpdateCurrentServers = Notification.Name("PIAServerDidUpdateCurrentServers")

    // MARK: VPN

    /// - Seealso: `VPNProvider.install(...)`
    public static let PIAVPNDidInstall = Notification.Name("PIAVPNDidInstall")

    public static let PIAVPNUsageUpdate = Notification.Name("PIAVPNUsageUpdate")

    #if os(iOS)
    
    // MARK: InApp
    
    static let __InAppDidFetchProducts = Notification.Name("__InAppDidFetchProducts")
    
    static let __InAppDidAddUncredited = Notification.Name("__InAppDidAddUncredited")
    
    #endif
}
