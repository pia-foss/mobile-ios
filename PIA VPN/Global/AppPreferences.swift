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

import PIALibrary
#if canImport(TunnelKitCore)
import TunnelKitCore
import TunnelKitOpenVPN
#endif
import Intents
import UIKit

private let log = PIALogger.logger(for: AppPreferences.self)

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
        static let wireGuardUseSmallPackets = "WireGuardUseSmallPackets"
        static let ikeV2UseSmallPackets = "IKEV2UseSmallPackets"
        static let usesCustomDNS = "usesCustomDNS"
        
        static let favoriteServerIdentifiersGen4_deprecated = "FavoriteServerIdentifiersGen4"

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
        static let todayWidgetTrustedNetwork = "vpn.widget.trusted.network"

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
        static let lastPositiveRatingSubmitted = "lastPositiveRatingSubmitted"
        static let lastNegativeRatingSubmitted = "lastNegativeRatingSubmitted"
        static let successDisconnections = "successDisconnections"

        // GEO servers
        static let showGeoServers = "ShowGeoServers"

        // Dismissed messages
        static let dismissedMessages = "DismissedMessages"
        
        // Dedicated IP relations
        static let tokenIPRelation_deprecated = "TokenIPRelation"

        // In app messages
        static let showServiceMessages = "showServiceMessages"

        // Features
        static let disablesMultiDipTokens = "disablesMultiDipTokens"
        static let checksDipExpirationRequest = "checksDipExpirationRequest"
        static let showNewInitialScreen = "showNewInitialScreen"
        static let showLeakProtection = "showLeakProtection"
        static let showLeakProtectionNotifications = "showLeakProtectionNotifications"
        static let showDynamicIslandLiveActivity = "showDynamicIslandLiveActivity"
        
        // Survey
        static let userInteractedWithSurvey = "userInteractedWithSurvey"
        static let successConnectionsUntilSurvey = "successConnectionsUntilSurvey"
        
        // Dev
        static let appEnvironmentIsProduction = "AppEnvironmentIsProduction"
        static let stagingVersion = "StagingVersion"
        
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
#if os(iOS)
    var currentThemeCode: ThemeCode {
        get {
            let rawCode = defaults.integer(forKey: Entries.themeCode)
            return ThemeCode(rawValue: rawCode) ?? .light
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.themeCode)
        }
    }
#endif
    var lastVPNConnectionStatus: PIALibrary.VPNStatus {
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
#if os(iOS)
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
                return .rsa4096
            }
            return OpenVPN.Configuration.Handshake(rawValue: rawValue) ??
                OpenVPN.Configuration.Handshake.rsa4096
        }
        set {
            defaults.set(newValue.rawValue, forKey: Entries.piaHandshake)
        }
    }
#endif
    var favoriteServerIdentifiersGen4: [String] {
        get {
            let keychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
            if let favorites = try? keychain.getFavorites() {
                return favorites
            }
            return []
        }
        set {
            let keychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
            try? keychain.set(favorites: newValue)
        }
    }

    var regionFilter: RegionFilter {
        get {
            guard let rawValue = defaults.string(forKey: Entries.regionFilter) else {
                return .latency
            }
            return RegionFilter(rawValue: rawValue) ?? .latency
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
            return defaults.string(forKey: Entries.todayWidgetVpnStatus) ?? L10n.Localizable.Today.Widget.login
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

    var todayWidgetTrustedNetwork: Bool {
        get {
            return defaults.bool(forKey: Entries.todayWidgetTrustedNetwork)
        }
        set {
            defaults.set(newValue, forKey: Entries.todayWidgetTrustedNetwork)
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
    
    var wireGuardUseSmallPackets: Bool {
        get {
            return defaults.bool(forKey: Entries.wireGuardUseSmallPackets)
        }
        set {
            defaults.set(newValue, forKey: Entries.wireGuardUseSmallPackets)
        }
    }
    
    var ikeV2UseSmallPackets: Bool {
        get {
            return defaults.bool(forKey: Entries.ikeV2UseSmallPackets)
        }
        set {
            defaults.set(newValue, forKey: Entries.ikeV2UseSmallPackets)
        }
    }
    
    var usesCustomDNS: Bool {
        get {
            return defaults.bool(forKey: Entries.usesCustomDNS)
        }
        set {
            defaults.set(newValue, forKey: Entries.usesCustomDNS)
        }
    }
    
    var dedicatedTokenIPReleation: [String: String] {
        get {
            let keychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
            if let relations = try? keychain.getDIPRelations() {
                return relations
            }
            return [:]
        }
        set {
            let keychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)
            for (key, value) in newValue {
                try? keychain.set(dipRelationKey: key, dipRelationValue: value)
            }
        }
    }
#if os(iOS)
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
#endif
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

    var lastPositiveRatingSubmitted: Date? {
        get {
            return defaults.object(forKey: Entries.lastPositiveRatingSubmitted) as? Date
        }
        set {
            defaults.set(newValue, forKey: Entries.lastPositiveRatingSubmitted)
        }
    }

    var lastNegativeRatingSubmitted: Date? {
        get {
            return defaults.object(forKey: Entries.lastNegativeRatingSubmitted) as? Date
        }
        set {
            defaults.set(newValue, forKey: Entries.lastNegativeRatingSubmitted)
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
    
    var successDisconnections: Int {
        get {
            return defaults.integer(forKey: Entries.successDisconnections)
        }
        set {
            defaults.set(newValue, forKey: Entries.successDisconnections)
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

    var showServiceMessages: Bool {
        get {
            return defaults.bool(forKey: Entries.showServiceMessages)
        }
        set {
            defaults.set(newValue, forKey: Entries.showServiceMessages)
        }
    }
    
    var disablesMultiDipTokens: Bool {
        get {
            return defaults.bool(forKey: Entries.disablesMultiDipTokens)
        }
        set {
            defaults.set(newValue, forKey: Entries.disablesMultiDipTokens)
        }
    }
    
    var showNewInitialScreen: Bool {
        get {
            return defaults.bool(forKey: Entries.showNewInitialScreen)
        }
        set {
            defaults.set(newValue, forKey: Entries.showNewInitialScreen)
        }
    }
    
    var showLeakProtection: Bool {
        get {
            return defaults.bool(forKey: Entries.showLeakProtection)
        }
        set {
            defaults.set(newValue, forKey: Entries.showLeakProtection)
        }
    }
    
    var showLeakProtectionNotifications: Bool {
        get {
            return defaults.bool(forKey: Entries.showLeakProtectionNotifications)
        }
        set {
            defaults.set(newValue, forKey: Entries.showLeakProtectionNotifications)
        }
    }
  
    var showDynamicIslandLiveActivity: Bool {
        get {
            return defaults.bool(forKey: Entries.showDynamicIslandLiveActivity)
        }
        set {
            defaults.set(newValue, forKey: Entries.showDynamicIslandLiveActivity)
        }
    }
    
    var checksDipExpirationRequest: Bool {
        get {
            return defaults.bool(forKey: Entries.checksDipExpirationRequest)
        }
        set {
            defaults.set(newValue, forKey: Entries.checksDipExpirationRequest)
        }
    }
    
    var appEnvironmentIsProduction: Bool {
        get {
            return defaults.bool(forKey: Entries.appEnvironmentIsProduction)
        }
        set {
            defaults.set(newValue, forKey: Entries.appEnvironmentIsProduction)
        }
    }
    
    var stagingVersion: Int {
        get {
            return defaults.integer(forKey: Entries.stagingVersion)
        }
        set {
            defaults.set(newValue, forKey: Entries.stagingVersion)
        }
    }
    
    var userInteractedWithSurvey: Bool {
        get {
            return defaults.bool(forKey: Entries.userInteractedWithSurvey)
        }
        set {
            defaults.set(newValue, forKey: Entries.userInteractedWithSurvey)
        }
    }
    
    var successConnectionsUntilSurvey: Int? {
        get {
            return defaults.value(forKey: Entries.successConnectionsUntilSurvey) as? Int
        }
        set {
            defaults.set(newValue, forKey: Entries.successConnectionsUntilSurvey)
        }
    }
    
    private init() {
        self.defaults = UserDefaults(suiteName: AppConstants.appGroup) ?? .standard
#if os(iOS)
        defaults.register(defaults: [
            
            Entries.version: AppPreferences.currentVersion,
            Entries.appVersion: "",
            Entries.launched: false,
            Entries.regionFilter: RegionFilter.latency.rawValue,
            Entries.didAskToEnableNotifications: false,
            Entries.themeCode: ThemeCode.light.rawValue,
            Entries.useConnectSiriShortcuts: false,
            Entries.useDisconnectSiriShortcuts: false,
            Entries.todayWidgetButtonTitle: L10n.Localizable.Today.Widget.login,
            
            Entries.todayWidgetVpnProtocol: PIAWGTunnelProfile.vpnType,
            
            Entries.todayWidgetVpnPort: "1337",
            Entries.todayWidgetVpnSocket: "UDP",
            Entries.todayWidgetTrustedNetwork: false,
            Entries.quickSettingThemeVisible: true,
            Entries.quickSettingKillswitchVisible: true,
            Entries.quickSettingNetworkToolVisible: true,
            Entries.quickSettingPrivateBrowserVisible: true,
            Entries.useSmallPackets: false,
            Entries.wireGuardUseSmallPackets: false,
            Entries.ikeV2UseSmallPackets: false,
            Entries.usesCustomDNS: false,
            Entries.canAskAgainForReview: false,
            Entries.successDisconnections: 0,
            Entries.successConnections: 0,
            Entries.failureConnections: 0,
            Entries.showGeoServers: true,
            Entries.dismissedMessages: [],
            Entries.showServiceMessages: false,
            Entries.disablesMultiDipTokens: true,
            Entries.checksDipExpirationRequest: true,
            Entries.userInteractedWithSurvey: false,
            Entries.stagingVersion: 0,
            Entries.appEnvironmentIsProduction: Client.environment == .production ? true : false,
        ])
    #endif
        migrateDIP()
    }

    private func migrateDIP() {
        let keychain = PIALibrary.Keychain(team: AppConstants.teamId, group: AppConstants.appGroup)

        // Migrate relations
        if let relations = defaults.dictionary(forKey: Entries.tokenIPRelation_deprecated) as? [String: String] {
            if (relations.isEmpty) {
                return
            }

            defaults.removeObject(forKey: Entries.tokenIPRelation_deprecated)
            for (key, value) in relations {
                try? keychain.set(dipRelationKey: key, dipRelationValue: value)
            }
        }

        // Migrate favorites
        if let favorites = defaults.array(forKey: Entries.favoriteServerIdentifiersGen4_deprecated) as? [String] {
            if (favorites.isEmpty) {
                return
            }

            defaults.removeObject(forKey: Entries.favoriteServerIdentifiersGen4_deprecated)
            try? keychain.set(favorites: favorites)
        }
    }
    #if os(iOS)
    func migrateOVPN() {

        guard let currentOpenVPNConfiguration = Client.preferences.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration ??
            Client.preferences.defaults.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? OpenVPNProvider.Configuration else {
            return
        }
        
        let handshake = AppPreferences.shared.piaHandshake
        //override the default handshake
        AppPreferences.shared.piaHandshake = handshake

        var pendingOpenVPNConfiguration = currentOpenVPNConfiguration.sessionConfiguration.builder()
        var shouldUpdate = false
        
        if pendingOpenVPNConfiguration.cipher == nil || pendingOpenVPNConfiguration.cipher == OpenVPN.Cipher.aes128cbc || pendingOpenVPNConfiguration.cipher == OpenVPN.Cipher.aes256cbc {
            shouldUpdate = true
            pendingOpenVPNConfiguration.cipher = .aes256gcm
        }
        
        if pendingOpenVPNConfiguration.digest != OpenVPN.Digest.sha256 {
            shouldUpdate = true
            pendingOpenVPNConfiguration.digest = OpenVPN.Digest.sha256
        }
        
        if shouldUpdate {
            var builder = OpenVPNProvider.ConfigurationBuilder(sessionConfiguration: pendingOpenVPNConfiguration.build())
            if AppPreferences.shared.useSmallPackets {
                builder.sessionConfiguration.mtu = AppConstants.OpenVPNPacketSize.smallPacketSize
            } else {
                builder.sessionConfiguration.mtu = AppConstants.OpenVPNPacketSize.defaultPacketSize
            }
            builder.shouldDebug = true

            let pendingPreferences = Client.preferences.editable()
            pendingPreferences.setVPNCustomConfiguration(builder.build(), for: pendingPreferences.vpnType)
            pendingPreferences.commit()
        }
        
    }

    func migrateWireguard() {
        let isWireguardMigrationPerformed = IsWireguardMigrationPerformed(
            preferences: Client.preferences
        )
        let isIkev2SelectedWithDefaultSettings = IsIkev2SelectedWithDefaultSettings(
            preferences: Client.preferences
        )
        let performWireguardMigration = PerformWireguardMigration(
            preferences: Client.preferences
        )
        let setWireguardMigrationPerformed = SetWireguardMigrationPerformed(
            preferences: Client.preferences
        )

        if (isWireguardMigrationPerformed()) {
            log.debug("Wireguard migration already performed. Return")
            return
        }

        setWireguardMigrationPerformed()

        if (!isIkev2SelectedWithDefaultSettings()) {
            log.debug("Wireguard migration aborted as the user is not on default settings. Return")
            return
        }

        performWireguardMigration()
    }
    #endif
    
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
        #if os(iOS)
        piaHandshake = .rsa4096
        piaSocketType = nil
        favoriteServerIdentifiersGen4 = []
        useConnectSiriShortcuts = false
        useDisconnectSiriShortcuts = false
        connectShortcut = nil
        disconnectShortcut = nil
        #endif
        let preferences = Client.preferences.editable().reset()
        preferences.commit()
        quickSettingThemeVisible = true
        quickSettingKillswitchVisible = true
        quickSettingNetworkToolVisible = true
        quickSettingPrivateBrowserVisible = true
        usesCustomDNS = false
        useSmallPackets = false
        ikeV2UseSmallPackets = false
        wireGuardUseSmallPackets = false
        #if os(iOS)
        todayWidgetVpnStatus = L10n.Localizable.Today.Widget.login
        todayWidgetButtonTitle = L10n.Localizable.Today.Widget.login
        todayWidgetVpnProtocol = PIAWGTunnelProfile.vpnType
        #endif
        todayWidgetVpnPort = "1337"
        todayWidgetVpnSocket = "UDP"
        todayWidgetTrustedNetwork = false
        Client.resetServers(completionBlock: {_ in })
        successDisconnections = 0
        successConnections = 0
        failureConnections = 0
        lastRatingRejection = nil
        lastPositiveRatingSubmitted = nil
        lastNegativeRatingSubmitted = nil
        showGeoServers = true
        showServiceMessages = false
        dismissedMessages = []
        dedicatedTokenIPReleation = [:]
        appEnvironmentIsProduction = Client.environment == .production ? true : false
        #if os(iOS)
        MessagesManager.shared.reset()
        #endif
        userInteractedWithSurvey = false
        successConnectionsUntilSurvey = nil
        Client.preferences.lastKnownException = nil
    }
    
//    + (void)eraseForTesting;
#if os(iOS)
    func transitionTheme(to code: ThemeCode, withDuration duration: Double = AppConfiguration.Animations.duration) {
        guard !isTransitioningTheme else {
            return
        }
        guard (code != AppPreferences.shared.currentThemeCode) else {
            return
        }
        
        AppPreferences.shared.currentThemeCode = code
        guard let window = UIApplication.shared.windows.first else {
            log.error("No window available for theme transition")
            return
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
        DispatchQueue.main.async {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                AppPreferences.shared.transitionTheme(to: .dark, withDuration: duration)
            default:
                AppPreferences.shared.transitionTheme(to: .light, withDuration: duration)
            }
        }
    }
#endif
    
    // MARK: Connections
    func incrementSuccessConnections() {
        successConnections += 1
    }

    func resetSuccessConnections() {
        successConnections = 1
    }
    
    func incrementSuccessDisconnections() {
        successDisconnections += 1
    }
}
