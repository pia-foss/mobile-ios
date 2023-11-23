//
//  AppDelegate.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
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

import UIKit
import PIALibrary
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
    
    private let defaultMilliseconds = 200

    var window: UIWindow?
    private var hotspotHelper: PIAHotspotHelper!
    private (set) var liveActivityManager: PIAConnectionLiveActivityManagerType?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppPreferences.shared.reloadTheme(withAnimationDuration: 0)

        Bootstrapper.shared.bootstrap()
        application.shortcutItems = []
        hotspotHelper = PIAHotspotHelper()
        _ = hotspotHelper.configureHotspotHelper()

        instantiateLiveActivityManagerIfNeeded()
        return true
    }
    
    private func instantiateLiveActivityManagerIfNeeded() {
        if #available(iOS 16.2, *) {
            // Only instantiates the LiveActivities if the Feature Flag for it is enabled
            guard AppPreferences.shared.showDynamicIslandLiveActivity else {
                liveActivityManager = nil
                return
            }
            
            liveActivityManager = PIAConnectionLiveActivityManager.shared
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Bootstrapper.shared.dispose()

        liveActivityManager?.endLiveActivities()
    }
    
    // MARK: Orientations
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: Selector(("onlyPortrait")))) {
                return .portrait
            }
        }

        return .allButUpsideDown
    }
    
    func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        }
        return rootViewController
    }
    
    // MARK: Notifications registration

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        log.debug("Registered user notification settings: \(notificationSettings) (\(notificationSettings.types))");

        guard (!AppPreferences.shared.didAskToEnableNotifications && (notificationSettings.types == .none)) else {
            return
        }

        AppPreferences.shared.didAskToEnableNotifications = true

        let alert = Macros.alert(
            L10n.Localizable.Notifications.Disabled.title,
            L10n.Localizable.Notifications.Disabled.message
        )
        alert.addActionWithTitle(L10n.Localizable.Notifications.Disabled.settings) {
            application.open(URL(string: UIApplication.openSettingsURLString)!,
                             options: [:],
                             completionHandler: nil)
        }
        alert.addCancelAction(L10n.Localizable.Global.ok)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("Received local notification: \(notification)")

        application.applicationIconBadgeNumber = 0
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        log.debug("Opened app from URL: \(url)")
        
        if url.absoluteString.starts(with: AppConstants.MagicLink.url) {

            log.debug("Trying to login using magic link")

            guard !Client.providers.accountProvider.isLoggedIn else {
                log.debug("User is already logged in")
                return false
            }

            if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
                rootViewController.navigationController?.popToRootViewController(animated: false)
                if let getStartedViewController = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) as? GetStartedViewController {
                    getStartedViewController.navigateToLoginView()
                    getStartedViewController.showLoadingAnimation()
                    Macros.dispatch(after: .milliseconds(1000)) { //TODO: Improve this, we are giving some time to push the view
                        let token = url.absoluteString[AppConstants.MagicLink.url.count...]
                        Client.providers.accountProvider.login(with: token) { (user, error) in
                            var userInfo: [NotificationKey: Any]? = nil
                            if let error = error {
                                userInfo = [.error: error]
                            }
                            getStartedViewController.hideLoadingAnimation()
                            Macros.postNotification(.PIAFinishLoginWithMagicLink, userInfo)
                        }
                    }
                }
            }

        } else if url.absoluteString.starts(with: AppConstants.Widget.connect) {
            if Client.providers.vpnProvider.isVPNConnected {
                disconnectAfter(milliseconds: defaultMilliseconds)
            } else {
                connectAfter(milliseconds: defaultMilliseconds)
            }
        }
        
        guard let host = url.host else {
            return false
        }

        switch host {
        case AppConstants.AppURL.hostRegion:

            // in case it's too early for notification delivery (vc not loaded)
            TransientState.shouldDisplayRegionPicker = true
            
        case VPNStatus.connected.rawValue:
            if Client.providers.vpnProvider.isVPNConnected {
                disconnectAfter(milliseconds: defaultMilliseconds)
            }
        case VPNStatus.disconnected.rawValue:
            if !Client.providers.vpnProvider.isVPNConnected {
                connectAfter(milliseconds: defaultMilliseconds)
            }

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
        // Remove the Non compliant Wifi local notification as the app is in foreground now
        Macros.removeLocalNotification(NotificationCategory.nonCompliantWifi)
        
        instantiateLiveActivityManagerIfNeeded()

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
        let connectionStatusString = (isNotDisconnected ? L10n.Localizable.Shortcuts.disconnect : L10n.Localizable.Shortcuts.connect)
        
        var items: [UIApplicationShortcutItem] = []
        
        itemAsset = (isNotDisconnected ? Asset.Images.icon3dtDisconnect : Asset.Images.icon3dtConnect)
        let connectionStatusIcon = UIApplicationShortcutIcon(templateImageName: itemAsset.name)
        let connect = UIApplicationShortcutItem(
            type: connectionStatusType.rawValue,
            localizedTitle: connectionStatusString,
            localizedSubtitle: nil,
            icon: connectionStatusIcon,
            userInfo: nil
        )
        items.append(connect)
        
        itemAsset = Asset.Images.icon3dtSelectRegion
        let selectRegionIcon = UIApplicationShortcutIcon(templateImageName: itemAsset.name)
        let selectRegion = UIApplicationShortcutItem(
            type: ShortcutItem.selectRegion.rawValue,
            localizedTitle: L10n.Localizable.Shortcuts.selectRegion,
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
                connectAfter(milliseconds: defaultMilliseconds)
            }

        case .disconnect:
            if Client.providers.vpnProvider.isVPNConnected {
                // Dismiss the Leak Protection alert if present when disconnecting from a Quick Action
                dismissLeakProtectionAlert()
                
                // this time delay seems to fix a strange issue of the VPN disconnecting and
                // then automatically reconnecting when it's done from a fresh launch
                disconnectAfter(milliseconds: defaultMilliseconds)
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
    
    //MARK: Siri Shortcuts
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == AppConstants.SiriShortcuts.shortcutConnect {
            guard AppPreferences.shared.useConnectSiriShortcuts, !TrustedNetworkUtils.isTrustedNetwork else {
                return false
            }
            Client.configuration.connectedManually = true
            connectAfter(milliseconds: defaultMilliseconds)
        } else {
            guard AppPreferences.shared.useDisconnectSiriShortcuts, !TrustedNetworkUtils.isTrustedNetwork else {
                return false
            }
            
            Client.configuration.disconnectedManually = true
            disconnectAfter(milliseconds: defaultMilliseconds)
        }
        return true
    }
    
    private func connectAfter(milliseconds: Int) {
        Macros.dispatch(after: .milliseconds(milliseconds)) {
            Client.providers.vpnProvider.connect(nil)
        }
    }
    
    private func disconnectAfter(milliseconds: Int) {
        Macros.dispatch(after: .milliseconds(milliseconds)) {
            Client.providers.vpnProvider.disconnect(nil)
        }
    }

}

extension AppDelegate {

    // MARK: - App Delegate Ref
    class func delegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func getRootViewController() -> UIViewController? {
        return AppDelegate.delegate().topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    }
    
}


extension AppDelegate {
    
    private func dismissLeakProtectionAlert() {
        if let presentedAlert = window?.rootViewController?.presentedViewController as? UIAlertController {
            let leakProtectionAlertTitle = L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.title
            
            if presentedAlert.title == leakProtectionAlertTitle {
                presentedAlert.dismiss(animated: true)
            }
        }
    }
}
