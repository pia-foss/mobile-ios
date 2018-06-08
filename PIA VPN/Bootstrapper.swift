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
        #else
        console.minLevel = .info
        #endif
        SwiftyBeaver.addDestination(console)
        
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
        defaults.vpnType = IPSecProfile.vpnType
        defaults.vpnCustomConfigurations = [
            PIATunnelProfile.vpnType: AppConfiguration.VPN.piaDefaultConfigurationBuilder.build()
        ]

        Client.configuration.setPlan(.yearly, forProductIdentifier: AppConstants.InApp.yearlyProductIdentifier)
        Client.configuration.setPlan(.monthly, forProductIdentifier: AppConstants.InApp.monthlyProductIdentifier)

        Client.database = Client.Database(team: AppConstants.teamId, group: AppConstants.appGroup)

        if (isSimulator || Flags.shared.usesMockVPN) {
            Client.configuration.enablesConnectivityUpdates = false
            Client.useMockVPNProvider()
        }
        if Flags.shared.usesMockInApp {
            Client.useMockInAppProvider()
        }
        if Flags.shared.usesMockAccount {
            Client.useMockAccountProvider(AppConfiguration.Mock.accountProvider)
        }
        
        // as per App Store guidelines
        let pref = Client.preferences.editable()
        let tunnelConfiguration = pref.vpnCustomConfiguration(for: PIATunnelProfile.vpnType) as? PIATunnelProvider.Configuration
        var tunnelConfigurationBuilder = tunnelConfiguration?.builder()
        if !Flags.shared.enablesMACESetting {
            pref.mace = false
        }
        if !Flags.shared.enablesRemotePortSetting {
            pref.preferredPort = nil
        }
        if !Flags.shared.enablesSocketSetting {
            pref.preferredPort = nil
            tunnelConfigurationBuilder?.socketType = .udp
        }
        if let newConfiguration = tunnelConfigurationBuilder?.build() {
            pref.setVPNCustomConfiguration(newConfiguration, for: PIATunnelProfile.vpnType)
        }
        pref.commit()

        Client.bootstrap()

        // Business objects
        
        AccountObserver.shared.start()
//        DataCounter.shared.startCounting()

        // Third parties
        
        let rater = iRate.sharedInstance()!
        rater.usesUntilPrompt = AppConfiguration.Rating.usesUntilPrompt
        rater.eventsUntilPrompt = AppConfiguration.Rating.eventsUntilPrompt
        rater.daysUntilPrompt = AppConfiguration.Rating.daysUntilPrompt
        rater.remindPeriod = AppConfiguration.Rating.remindPeriod
        
        #if PIA_DEV
        let hockey = BITHockeyManager.shared()
        hockey.isMetricsManagerDisabled = true
        hockey.configure(withIdentifier: AppConstants.hockeyAppId)
        hockey.start()
        #endif

        // Notifications
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(reloadTheme), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)

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
