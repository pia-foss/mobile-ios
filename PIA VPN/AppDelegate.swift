//
//  AppDelegate.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import SideMenu
import SwiftyBeaver
import NetworkExtension

private let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: NSObject, UIApplicationDelegate {
    
    private enum ShortcutItem: String {
        case connect

        case disconnect
        
        case selectRegion
    }

    var window: UIWindow?
    private var hotspotHelper: PIAHotspotHelper!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        Bootstrapper.shared.bootstrap()
        application.shortcutItems = []
        hotspotHelper = PIAHotspotHelper()
        _ = hotspotHelper.configureHotspotHelper()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Bootstrapper.shared.dispose()
    }
    
    // MARK: Notifications registration

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        log.debug("Registered user notification settings: \(notificationSettings) (\(notificationSettings.types))");

        guard (!AppPreferences.shared.didAskToEnableNotifications && (notificationSettings.types == .none)) else {
            return
        }

        AppPreferences.shared.didAskToEnableNotifications = true

        let alert = Macros.alert(
            L10n.Notifications.Disabled.title,
            L10n.Notifications.Disabled.message
        )
        alert.addActionWithTitle(L10n.Notifications.Disabled.settings) {
            application.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addCancelAction(L10n.Global.ok)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("Received local notification: \(notification)")

        application.applicationIconBadgeNumber = 0
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        log.debug("Opened app from URL: \(url)")
        guard let host = url.host else {
            return false
        }

        switch host {
        case AppConstants.AppURL.hostRegion:

            // in case it's too early for notification delivery (vc not loaded)
            TransientState.shouldDisplayRegionPicker = true
            
        default:
            return false
        }

        return true
    }
    
    // MARK: Shortcut items

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        log.debug("Opened app from shortcut item: \(shortcutItem.type)")

        guard Client.providers.accountProvider.isLoggedIn else {
            completionHandler(false)
            return
        }

        handleShortcutItem(shortcutItem)
        completionHandler(true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        refreshShortcutItems(in: application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    private func refreshShortcutItems(in application: UIApplication) {
        guard Client.providers.accountProvider.isLoggedIn else {
            return
        }

        let connected = Client.providers.vpnProvider.isVPNConnected
        let connecting = (Client.providers.vpnProvider.vpnStatus == .connecting)
        let disconnecting = (Client.providers.vpnProvider.vpnStatus == .disconnecting)
        let isNotDisconnected = (connected || connecting) && !disconnecting
        var itemAsset: ImageAsset!
        
        let connectionStatusType = (isNotDisconnected ? ShortcutItem.disconnect : ShortcutItem.connect)
        let connectionStatusString = (isNotDisconnected ? L10n.Shortcuts.disconnect : L10n.Shortcuts.connect)
        
        var items: [UIApplicationShortcutItem] = []
        
        itemAsset = (isNotDisconnected ? Asset.icon3dtDisconnect : Asset.icon3dtConnect)
        let connectionStatusIcon = UIApplicationShortcutIcon(templateImageName: itemAsset.name)
        let connect = UIApplicationShortcutItem(
            type: connectionStatusType.rawValue,
            localizedTitle: connectionStatusString,
            localizedSubtitle: nil,
            icon: connectionStatusIcon,
            userInfo: nil
        )
        items.append(connect)
        
        itemAsset = Asset.icon3dtSelectRegion
        let selectRegionIcon = UIApplicationShortcutIcon(templateImageName: itemAsset.name)
        let selectRegion = UIApplicationShortcutItem(
            type: ShortcutItem.selectRegion.rawValue,
            localizedTitle: L10n.Shortcuts.selectRegion,
            localizedSubtitle: nil,
            icon: selectRegionIcon,
            userInfo: nil
        )
        items.append(selectRegion)
        
        application.shortcutItems = items
    }
    
    private func handleShortcutItem(_ item: UIApplicationShortcutItem) {
        guard let type = ShortcutItem(rawValue: item.type) else {
            return
        }

        switch type {
        case .connect:
            if !Client.providers.vpnProvider.isVPNConnected {
                // this time delay seems to fix a strange issue of the VPN connecting from a fresh launch
                Macros.dispatch(after: .milliseconds(200)) {
                    Client.providers.vpnProvider.connect(nil)
                }
            }

        case .disconnect:
            if Client.providers.vpnProvider.isVPNConnected {
                
                // this time delay seems to fix a strange issue of the VPN disconnecting and
                // then automatically reconnecting when it's done from a fresh launch
                Macros.dispatch(after: .milliseconds(200)) {
                    Client.providers.vpnProvider.disconnect(nil)
                }
            }

        case .selectRegion:
            guard let rootNavVC = window?.rootViewController as? UINavigationController else {
                return
            }
            guard let mainVC = rootNavVC.viewControllers.first as? DashboardViewController else {
                return
            }
            mainVC.selectRegion(animated: true)
        }
    }
    
}
