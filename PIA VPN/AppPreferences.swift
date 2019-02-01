//
//  AppPreferences.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import PIATunnel
import SwiftyBeaver

private let log = SwiftyBeaver.self

class AppPreferences {
    private struct Entries {
        static let version = "Version"
        
        static let launched = "Launched" // discard 2.2 key and invert logic
        
        static let seenContentBlocker = "SeenContentBlocker"
        
        static let didAskToEnableNotifications = "DidAskToEnableNotifications"

        static let themeCode = "Theme" // reuse 2.2 key

        static let lastVPNConnectionStatus = "LastVPNConnectionStatus"

        static let piaSocketType = "PIASocketType"
    }

    static let shared = AppPreferences()
    
    private static let currentVersion = "5.1"
    
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
    
    var didSeeContentBlocker: Bool {
        get {
            return defaults.bool(forKey: Entries.seenContentBlocker)
        }
        set {
            defaults.set(newValue, forKey: Entries.seenContentBlocker)
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
    var piaSocketType: PIATunnelProvider.SocketType? {
        get {
            guard let rawValue = defaults.string(forKey: Entries.piaSocketType) else {
                return nil
            }
            return PIATunnelProvider.SocketType(rawValue: rawValue)
        }
        set {
            if let rawValue = newValue?.rawValue {
                defaults.set(rawValue, forKey: Entries.piaSocketType)
            } else {
                defaults.removeObject(forKey: Entries.piaSocketType)
            }
        }
    }

    private init() {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroup) else {
            fatalError("Unable to initialize app preferences")
        }
        self.defaults = defaults

        defaults.register(defaults: [
            Entries.version: AppPreferences.currentVersion,
            Entries.launched: false,
            Entries.didAskToEnableNotifications: false,
            Entries.themeCode: ThemeCode.light.rawValue
        ])
    }
    
    private func refreshAPIToken() {
        if Client.preferences.authMigrationSuccess == false {
            Client.providers.accountProvider.refreshAndLogoutUnauthorized(force: true)
        }
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
    
    func migrate() {
        let oldVersion = defaults.string(forKey: Entries.version)
        defaults.set(AppPreferences.currentVersion, forKey: Entries.version)
        
        guard (oldVersion == nil) else {
            if oldVersion != AppPreferences.currentVersion ||
                !Client.preferences.authMigrationSuccess { //First time for each update or if the auth token has not been updated
                migrateAPItoV2()
                refreshAPIToken()
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

    func reset() {
        piaSocketType = nil
        transitionTheme(to: .light)
    }
    
//    + (void)eraseForTesting;

    func transitionTheme(to code: ThemeCode) {
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
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            window.alpha = 0.0
        }, completion: { (success) in
            code.apply(theme: Theme.current, reload: true)
            
            UIView.animate(withDuration: AppConfiguration.Animations.duration) {
                window.alpha = 1.0
                self.isTransitioningTheme = false
            }
        })
    }
}
