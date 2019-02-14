//
//  Bootstrapper.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/4/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import PIATunnel
import SwiftyBeaver
import iRate
#if PIA_DEV
import HockeySDK
import Firebase
import Fabric
import Crashlytics
#endif

class Bootstrapper {
    static let shared = Bootstrapper()
    
    private init() {
    }
    
    private var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }

    func bootstrap() {
        
        let console = ConsoleDestination()
        #if PIA_DEV
        console.minLevel = .debug
        let hockey = BITHockeyManager.shared()
        hockey.isMetricsManagerDisabled = true
        hockey.configure(withIdentifier: AppConstants.hockeyAppId)
        hockey.start()
        
        if let path = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist"),
            let plist = NSDictionary(contentsOf: path) as? [String: Any],
            plist.count > 0 {
            FirebaseApp.configure()
            Fabric.sharedSDK().debug = true
            Fabric.with([Crashlytics.self()])
        }
        #else
        console.minLevel = .info
        #endif
        SwiftyBeaver.addDestination(console)

        // Load the database first
        Client.database = Client.Database(team: AppConstants.teamId, group: AppConstants.appGroup)

        // Check if should clean the account after delete the app and install again
        if Client.providers.accountProvider.shouldCleanAccount {
            //If first install, we need to ensure we don't have data from previous sessions in the Secure Keychain
            Client.providers.accountProvider.cleanDatabase()
        }

        AppPreferences.shared.migrate()

        // PIALibrary
        
        guard let bundledRegionsURL = AppConstants.Regions.bundleURL else {
            fatalError("Could not find bundled regions file")
        }
        let bundledServersJSON: Data
        do {
            try bundledServersJSON = Data(contentsOf: bundledRegionsURL)
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }

        Client.environment = AppConfiguration.clientEnvironment
        Client.configuration.isDevelopment = Flags.shared.usesDevelopmentClient
        if let stagingUrl = AppConstants.Web.stagingEndpointURL {
            Client.configuration.setBaseURL(stagingUrl.absoluteString, for: .staging)
        }
        if Client.configuration.isDevelopment, let customServers = AppConstants.Servers.customServers {
            for server in customServers {
                Client.configuration.addCustomServer(server)
            }
        }
        
        Client.configuration.enablesConnectivityUpdates = true
        Client.configuration.enablesServerUpdates = true
        Client.configuration.enablesServerPings = true
        Client.configuration.bundledServersJSON = bundledServersJSON
        Client.configuration.webTimeout = AppConfiguration.ClientConfiguration.webTimeout
        Client.configuration.vpnProfileName = AppConfiguration.VPN.profileName
        Client.configuration.addVPNProfile(PIATunnelProfile(bundleIdentifier: AppConstants.Extensions.tunnelBundleIdentifier))
        
        let defaults = Client.preferences.defaults
        defaults.isPersistentConnection = true
        defaults.mace = false
        defaults.vpnType = PIATunnelProfile.vpnType
        defaults.vpnCustomConfigurations = [
            PIATunnelProfile.vpnType: AppConfiguration.VPN.piaDefaultConfigurationBuilder.build()
        ]
        
        Client.configuration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)
        Client.configuration.setPlan(.legacyYearly, forProductIdentifier: AppConstants.LegacyInApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.legacyMonthly, forProductIdentifier: AppConstants.LegacyInApp.monthlyProductIdentifier)

        if (self.isSimulator || Flags.shared.usesMockVPN) {
            Client.configuration.enablesConnectivityUpdates = false
            Client.useMockVPNProvider()
        }
        if Flags.shared.usesMockInApp {
            Client.useMockInAppProvider()
        }
        if Flags.shared.usesMockAccount {
            Client.useMockAccountProvider(AppConfiguration.Mock.accountProvider)
        }
        
        Client.bootstrap()
        
        // Preferences
        
        let pref = Client.preferences.editable()
        
        // as per App Store guidelines
        if !Flags.shared.enablesMACESetting {
            pref.mace = false
        }
        
        pref.commit()
        
        // Business objects
        
        AccountObserver.shared.start()
        //        DataCounter.shared.startCounting()
        
        // Third parties
        
        let rater = iRate.sharedInstance()!
        rater.usesUntilPrompt = AppConfiguration.Rating.usesUntilPrompt
        rater.eventsUntilPrompt = AppConfiguration.Rating.eventsUntilPrompt
        rater.daysUntilPrompt = AppConfiguration.Rating.daysUntilPrompt
        rater.remindPeriod = AppConfiguration.Rating.remindPeriod
        
        // Notifications
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reloadTheme), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(self.vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        
        // PIALibrary (Theme)
        
        AppPreferences.shared.currentThemeCode.apply(theme: Theme.current, reload: true)
        
        // show walkthrough on upgrade except for logged in users
        if Client.providers.accountProvider.isLoggedIn {
            AppPreferences.shared.wasLaunched = true
        }

    }

    func dispose() {
        Client.dispose()
    }
    
    // MARK: Notifications

    @objc private func reloadTheme() {
        Theme.current.applySideMenu()
        Theme.current.applyAppearance()
    }
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        guard (Client.providers.vpnProvider.vpnStatus == .connected) else {
            return
        }
        iRate.sharedInstance()!.logEvent(false)
    }
}
