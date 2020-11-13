//
//  AppPreferences.swift
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
import TunnelKit
import SwiftyBeaver
import Intents

private let log = SwiftyBeaver.self

class AppPreferences {
    
    private struct Entries {
        
        static let appVersion = "AppVersion"
        
        static let version = "Version"
        
        static let launched = "Launched" // discard 2.2 key and invert logic
                
        static let didAskToEnableNotifications = "DidAskToEnableNotifications"

        static let themeCode = "Theme" // reuse 2.2 key

        static let lastVPNConnectionStatus = "LastVPNConnectionStatus"

        static let piaHandshake = "PIAHandshake"

        static let piaSocketType = "PIASocketType"

        static let useSmallPackets = "UseSmallPackets"

        static let favoriteServerIdentifiersGen4 = "FavoriteServerIdentifiersGen4"

        static let regionFilter = "RegionFilter"

        static let useConnectSiriShortcuts = "UseConnectSiriShortcuts"
        static let connectShortcut = "ConnectShortcut"
        
        static let useDisconnectSiriShortcuts = "UseDisconnectSiriShortcuts"
        static let disconnectShortcut = "disconnectShortcut"

        static let todayWidgetVpnStatus = "vpn.status"
        static let todayWidgetButtonTitle = "vpn.button.description"
        static let todayWidgetVpnProtocol = "vpn.widget.protocol"
        static let todayWidgetVpnPort = "vpn.widget.port"
        static let todayWidgetVpnSocket = "vpn.widget.socket"
        
        // Quick Settings options
        static let quickSettingThemeVisible = "quickSettingThemeVisible"
        static let quickSettingKillswitchVisible = "quickSettingKillswitchVisible"
        static let quickSettingNetworkToolVisible = "quickSettingNetworkToolVisible"
        static let quickSettingPrivateBrowserVisible = "quickSettingPrivateBrowserVisible"

        // Rating Settings
        static let successConnections = "successConnections"
        static let failureConnections = "failureConnections"
        static let canAskAgainForReview = "canAskAgainForReview"
        static let lastRatingRejection = "lastRatingRejection"

        // GEO servers
        static let showGeoServers = "ShowGeoServers"

        // Dismissed messages
        static let dismissedMessages = "DismissedMessages"

    }

    static let shared = AppPreferences()
    
    private static let currentVersion = "5.3"
    
    private let defaults: UserDefaults

    private var isTransitioningTheme = false
    
    var wasLaunched: Bool {
        get {
            return defaults.bool(forKey: Entries.launched)
        }
        set {
            defaults.set(newValue, forKey: Entries.launched)
        }
    }
    
    var didAskToEnableNotifications: Bool {
        get {
            return defaults.bool(forKey: Entries.didAskToEnableNotifications)
        }
        set {
            defaults.set(newValue, forKey: Entries.didAskToEnableNotifications)
        }
    }
    
    var currentThemeCode: ThemeCode {
        get {
            let rawCode = defaults.integer(forKey: Entries.themeCode)
            return ThemeCode(rawValue: rawCode) ?? .light
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.themeCode)
        }
    }
    
    var lastVPNConnectionStatus: VPNStatus {
        get {
            guard let rawValue = defaults.string(forKey: Entries.lastVPNConnectionStatus) else {
                return .disconnected
            }
            return VPNStatus(rawValue: rawValue) ?? .disconnected
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.lastVPNConnectionStatus)
        }
    }
    
    // nil = automatic
    var piaSocketType: SocketType? {
        get {
            guard let rawValue = defaults.string(forKey: Entries.piaSocketType) else {
                return nil
            }
            return SocketType(rawValue: rawValue)
        }
        set {
            if let rawValue = newValue?.rawValue {
                defaults.set(rawValue, forKey: Entries.piaSocketType)
            } else {
                defaults.removeObject(forKey: Entries.piaSocketType)
            }
        }
    }
    
    var piaHandshake: OpenVPN.Configuration.Handshake {
        get {
            guard let rawValue = defaults.string(forKey: Entries.piaHandshake) else {
                return .rsa2048
            }
            return OpenVPN.Configuration.Handshake(rawValue: rawValue) ??
                OpenVPN.Configuration.Handshake.rsa2048
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.piaHandshake)
        }
    }
    
    var favoriteServerIdentifiersGen4: [String] {
        get {
            if let serverIdentifiers = defaults.array(forKey: Entries.favoriteServerIdentifiersGen4) as? [String] {
                return serverIdentifiers
            }
            return []
        }
        set {
            defaults.set(newValue, forKey: Entries.favoriteServerIdentifiersGen4)
        }
    }


    var regionFilter: RegionFilter {
        get {
            guard let rawValue = defaults.string(forKey: Entries.regionFilter) else {
                return .name
            }
            return RegionFilter(rawValue: rawValue) ?? .name
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.regionFilter)
        }
    }
    
    var useConnectSiriShortcuts: Bool {
        get {
            return defaults.bool(forKey: Entries.useConnectSiriShortcuts)
        }
        set {
            defaults.set(newValue, forKey: Entries.useConnectSiriShortcuts)
        }
    }

    var useDisconnectSiriShortcuts: Bool {
        get {
            return defaults.bool(forKey: Entries.useDisconnectSiriShortcuts)
        }
        set {
            defaults.set(newValue, forKey: Entries.useDisconnectSiriShortcuts)
        }
    }
    
    var todayWidgetVpnStatus: String? {
        get {
            return defaults.string(forKey: Entries.todayWidgetVpnStatus) ?? L10n.Today.Widget.login
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetVpnStatus)
        }
    }
    
    var todayWidgetButtonTitle: String? {
        get {
            return defaults.string(forKey: Entries.todayWidgetButtonTitle) ?? nil
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetButtonTitle)
        }
    }
    
    var todayWidgetVpnProtocol: String? {
        get {
            return defaults.string(forKey: Entries.todayWidgetVpnProtocol) ?? nil
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetVpnProtocol)
        }
    }
    
    var todayWidgetVpnPort: String? {
        get {
            return defaults.string(forKey: Entries.todayWidgetVpnPort) ?? nil
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetVpnPort)
        }
    }
    
    var todayWidgetVpnSocket: String? {
        get {
            return defaults.string(forKey: Entries.todayWidgetVpnSocket) ?? nil
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetVpnSocket)
        }
    }

    var useSmallPackets: Bool {
        get {
            return defaults.bool(forKey: Entries.useSmallPackets)
        }
        set {
            defaults.set(newValue, forKey: Entries.useSmallPackets)
        }
    }

    
    @available(iOS 12.0, *)
    var connectShortcut: INVoiceShortcut? {
        get {
            if let data = defaults.object(forKey: Entries.connectShortcut) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? INVoiceShortcut
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let encodedObject = NSKeyedArchiver.archivedData(withRootObject: newValue)
                defaults.set(encodedObject, forKey: Entries.connectShortcut)
            }
        }
    }
    
    @available(iOS 12.0, *)
    var disconnectShortcut: INVoiceShortcut? {
        get {
            if let data = defaults.object(forKey: Entries.disconnectShortcut) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? INVoiceShortcut
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let encodedObject = NSKeyedArchiver.archivedData(withRootObject: newValue)
                defaults.set(encodedObject, forKey: Entries.disconnectShortcut)
            }
        }    }

    var quickSettingThemeVisible: Bool{
        get {
            return defaults.bool(forKey: Entries.quickSettingThemeVisible)
        }
        set {
            defaults.set(newValue, forKey: Entries.quickSettingThemeVisible)
        }
    }
    
    var quickSettingKillswitchVisible: Bool{
        get {
            return defaults.bool(forKey: Entries.quickSettingKillswitchVisible)
        }
        set {
            defaults.set(newValue, forKey: Entries.quickSettingKillswitchVisible)
        }
    }
    
    var quickSettingNetworkToolVisible: Bool{
        get {
            return defaults.bool(forKey: Entries.quickSettingNetworkToolVisible)
        }
        set {
            defaults.set(newValue, forKey: Entries.quickSettingNetworkToolVisible)
        }
    }
    
    var quickSettingPrivateBrowserVisible: Bool{
        get {
            return defaults.bool(forKey: Entries.quickSettingPrivateBrowserVisible)
        }
        set {
            defaults.set(newValue, forKey: Entries.quickSettingPrivateBrowserVisible)
        }
    }
    
    var canAskAgainForReview: Bool{
        get {
            return defaults.bool(forKey: Entries.canAskAgainForReview)
        }
        set {
            defaults.set(newValue, forKey: Entries.canAskAgainForReview)
        }
    }
    
    var successConnections: Int{
        get {
            return defaults.integer(forKey: Entries.successConnections)
        }
        set {
            defaults.set(newValue, forKey: Entries.successConnections)
        }
    }

    var failureConnections: Int{
        get {
            return defaults.integer(forKey: Entries.failureConnections)
        }
        set {
            defaults.set(newValue, forKey: Entries.failureConnections)
        }
    }

    var lastRatingRejection: Date? {
        get {
            return defaults.object(forKey: Entries.lastRatingRejection) as? Date
        }
        set {
            defaults.set(newValue, forKey: Entries.lastRatingRejection)
        }
    }
    
    var showGeoServers: Bool {
        get {
            return defaults.bool(forKey: Entries.showGeoServers)
        }
        set {
            defaults.set(newValue, forKey: Entries.showGeoServers)
        }
    }
    
    var appVersion: String? {
        get {
            return defaults.string(forKey: Entries.appVersion)
        }
        set {
            defaults.set(newValue, forKey: Entries.appVersion)
        }
    }
    
    var dismissedMessages: [String]{
        get {
            return defaults.array(forKey: Entries.dismissedMessages) as? [String] ?? []
        }
        set {
            defaults.set(newValue, forKey: Entries.dismissedMessages)
        }
    }


    private init() {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroup) else {
            fatalError("Unable to initialize app preferences")
        }
        self.defaults = defaults

        defaults.register(defaults: [
            Entries.version: AppPreferences.currentVersion,
            Entries.appVersion: "",
            Entries.launched: false,
            Entries.regionFilter: RegionFilter.name.rawValue,
            Entries.favoriteServerIdentifiersGen4: [],
            Entries.didAskToEnableNotifications: false,
            Entries.themeCode: ThemeCode.light.rawValue,
            Entries.useConnectSiriShortcuts: false,
            Entries.useDisconnectSiriShortcuts: false,
            Entries.todayWidgetButtonTitle: L10n.Today.Widget.login,
            Entries.todayWidgetVpnProtocol: IKEv2Profile.vpnType,
            Entries.todayWidgetVpnPort: "500",
            Entries.todayWidgetVpnSocket: "UDP",
            Entries.quickSettingThemeVisible: true,
            Entries.quickSettingKillswitchVisible: true,
            Entries.quickSettingNetworkToolVisible: true,
            Entries.quickSettingPrivateBrowserVisible: true,
            Entries.useSmallPackets: false,
            Entries.canAskAgainForReview: false,
            Entries.successConnections: 0,
            Entries.failureConnections: 0,
            Entries.showGeoServers: true,
            Entries.dismissedMessages: []
        ])
    }
    
    func migrateNMT() {
        
        if !Client.preferences.nmtMigrationSuccess {
            if Client.preferences.nmtRulesEnabled {
                
                //First, migrate the trusted networks
                var trustedNetworkRules = [String:Int]()
                Client.preferences.trustedNetworks.forEach {
                    trustedNetworkRules[$0] = NMTRules.alwaysDisconnect.rawValue
                }
                
                //Now, migrate the generic rules
                var genericRules = [String:Int]()
                genericRules[NMTType.protectedWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
                genericRules[NMTType.openWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
                genericRules[NMTType.cellular.rawValue] = NMTRules.alwaysConnect.rawValue

                if Client.preferences.trustCellularData {
                    genericRules[NMTType.cellular.rawValue] = NMTRules.alwaysDisconnect.rawValue
                }
                
                if Client.preferences.useWiFiProtection {
                    genericRules[NMTType.protectedWiFi.rawValue] = NMTRules.alwaysDisconnect.rawValue
                }
                
                let preferences = Client.preferences.editable()
                preferences.nmtGenericRules = genericRules
                preferences.nmtTrustedNetworkRules = trustedNetworkRules
                preferences.nmtMigrationSuccess = true
                preferences.commit()
                
            } else {
                
                var genericRules = [String:Int]()
                genericRules[NMTType.protectedWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
                genericRules[NMTType.openWiFi.rawValue] = NMTRules.alwaysConnect.rawValue
                genericRules[NMTType.cellular.rawValue] = NMTRules.alwaysConnect.rawValue

                let preferences = Client.preferences.editable()
                preferences.nmtGenericRules = genericRules
                preferences.nmtTrustedNetworkRules = [:]
                preferences.nmtMigrationSuccess = true
                preferences.commit()

            }
        }
        
    }
    
    func migrate() {
        let oldVersion = defaults.string(forKey: Entries.version)
        defaults.set(AppPreferences.currentVersion, forKey: Entries.version)
        
        guard (oldVersion == nil) else {
            if oldVersion != AppPreferences.currentVersion {
                Client.providers.accountProvider.logout(nil)
            }
            return
        }

        // new install or app version < 2.1
        let oldDefaults = UserDefaults.standard
        
        // migrate username to new key
        let legacyUsername = oldDefaults.string(forKey: "Username")
        var maybeLoggedUsername = oldDefaults.string(forKey: "LoggedUsername")
        if ((legacyUsername != nil) && (maybeLoggedUsername == nil)) {
            oldDefaults.removeObject(forKey: "Username")
            maybeLoggedUsername = legacyUsername
        }
        
        // no old login means logged out or new install, no migration needed
        guard let loggedUsername = maybeLoggedUsername else {
            return
        }
        
        // otherwise, app version < 2.1 (local defaults/keychain)
        
        // it used to be here in app version <= 2.0
        let oldKeychain = PIALibrary.Keychain()
        let newKeychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
        
        // migrate credentials from local to shared keychain
        if let legacyPassword = try? oldKeychain.password(for: loggedUsername) {
            oldDefaults.removeObject(forKey: "Username")
            oldDefaults.removeObject(forKey: "LoggedUsername")
            oldKeychain.removePassword(for: loggedUsername)
            
            // store to new defaults/keychain
            defaults.set(loggedUsername, forKey: "LoggedUsername")
            try? newKeychain.set(password: legacyPassword, for: loggedUsername)
        }
        
        // migrate settings
        wasLaunched = !oldDefaults.bool(forKey: "FirstLaunch")
        didAskToEnableNotifications = oldDefaults.bool(forKey: Entries.didAskToEnableNotifications)
        
        // discard these, will be fetched on login
//        NSString *subscriptionExpirationDate = [oldDefaults objectForKey:@"SubscriptionExpirationDate"];
//        NSString *subscriptionPlan = [oldDefaults objectForKey:@"SubscriptionPlan"];
        oldDefaults.removeObject(forKey: "SubscriptionExpirationDate")
        oldDefaults.removeObject(forKey: "SubscriptionPlan")
        
        migrateAPItoV2()
        
    }
    
    private func migrateAPItoV2() {
        // Migrate users from v1 to v2
        log.debug("Migration to api v2")
        //For v1 we stored the username in the plain database. We move the value to the keychain database.
        //After refresh the account, the token will be generated
        if let oldUsername = defaults.string(forKey: "LoggedUsername"),
            let _ = try? PIALibrary.Keychain(team: AppConstants.teamId,
                                             group: AppConstants.appGroup).password(for: oldUsername) {
            //User is loggedIn
            try? PIALibrary.Keychain().set(username: oldUsername)
            try? PIALibrary.Keychain().set(publicUsername: oldUsername)
            defaults.removeObject(forKey: "LoggedUsername")
            defaults.synchronize()
        }
    }

    func reset() {
        piaHandshake = .rsa2048
        piaSocketType = nil
        favoriteServerIdentifiersGen4 = []
        useConnectSiriShortcuts = false
        useDisconnectSiriShortcuts = false
        if #available(iOS 12.0, *) {
            connectShortcut = nil
            disconnectShortcut = nil
        }
        let preferences = Client.preferences.editable().reset()
        preferences.commit()
        guard #available(iOS 13.0, *) else {
            transitionTheme(to: .light)
            return
        }
        quickSettingThemeVisible = true
        quickSettingKillswitchVisible = true
        quickSettingNetworkToolVisible = true
        quickSettingPrivateBrowserVisible = true
        useSmallPackets = false
        todayWidgetVpnProtocol = IKEv2Profile.vpnType
        todayWidgetVpnPort = "500"
        todayWidgetVpnSocket = "UDP"
        Client.resetServers(completionBlock: {_ in })
        failureConnections = 0
        showGeoServers = true
    }
    
    func clean() {
        piaHandshake = .rsa2048
        piaSocketType = nil
        favoriteServerIdentifiersGen4 = []
        useConnectSiriShortcuts = false
        useDisconnectSiriShortcuts = false
        if #available(iOS 12.0, *) {
            connectShortcut = nil
            disconnectShortcut = nil
        }
        todayWidgetVpnStatus = L10n.Today.Widget.login
        todayWidgetButtonTitle = L10n.Today.Widget.login
        todayWidgetVpnProtocol = IKEv2Profile.vpnType
        todayWidgetVpnPort = "500"
        todayWidgetVpnSocket = "UDP"
        quickSettingThemeVisible = true
        quickSettingKillswitchVisible = true
        quickSettingNetworkToolVisible = true
        quickSettingPrivateBrowserVisible = true
        useSmallPackets = false
        let preferences = Client.preferences.editable().reset()
        preferences.commit()
        Client.resetServers(completionBlock: {_ in })
        failureConnections = 0
        showGeoServers = true
        dismissedMessages = []
    }
    
//    + (void)eraseForTesting;

    func transitionTheme(to code: ThemeCode, withDuration duration: Double = AppConfiguration.Animations.duration) {
        guard !isTransitioningTheme else {
            return
        }
        guard (code != AppPreferences.shared.currentThemeCode) else {
            return
        }
        
        AppPreferences.shared.currentThemeCode = code
        guard let window = UIApplication.shared.windows.first else {
            fatalError("No window?")
        }
        isTransitioningTheme = true
        UIView.animate(withDuration: duration, animations: {
            window.alpha = 0.0
        }, completion: { (success) in
            code.apply(theme: Theme.current, reload: true)
            
            UIView.animate(withDuration: duration) {
                window.alpha = 1.0
                self.isTransitioningTheme = false
            }
        })
    }
    
    //MARK: Dark Mode
    public func reloadTheme(withAnimationDuration duration: Double = AppConfiguration.Animations.duration) {
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
              switch UITraitCollection.current.userInterfaceStyle {
              case .dark:
                  AppPreferences.shared.transitionTheme(to: .dark, withDuration: duration)
              default:
                  AppPreferences.shared.transitionTheme(to: .light, withDuration: duration)
              }
            }
        }
    }
}
