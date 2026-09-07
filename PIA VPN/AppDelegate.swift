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

import Combine
import PIALibrary
import PIALocalizations
import UIKit

private let log = PIALogger.logger(for: AppDelegate.self)

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private var hotspotHelper: PIAHotspotHelper!
    #if !targetEnvironment(macCatalyst)
        private(set) var liveActivityManager: PIAConnectionLiveActivityManagerType?
    #endif
    var cancellables = Set<AnyCancellable>()

    /// The scene starts the app once the migration check clears, and a scene can connect more than
    /// once over the process' lifetime.
    private var didStartApp = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        AppPreferences.shared.reloadTheme(withAnimationDuration: 0)

        return true
    }

    /// Called by `SceneDelegate` once the PlatformSDK migration check has been answered.
    func startApp() {
        guard !didStartApp else { return }
        didStartApp = true

        Bootstrapper.shared.bootstrap()
        hotspotHelper = PIAHotspotHelper()
        _ = hotspotHelper.configureHotspotHelper()

        #if !targetEnvironment(macCatalyst)
            instantiateLiveActivityManagerIfNeeded()
        #endif

        setupDebugMenuObserver()
    }

    #if !targetEnvironment(macCatalyst)
        func instantiateLiveActivityManagerIfNeeded() {
            if #available(iOS 16.2, *) {
                // Only instantiates the LiveActivities if the Feature Flag for it is enabled
                guard AppPreferences.shared.showDynamicIslandLiveActivity else {
                    liveActivityManager = nil
                    return
                }

                liveActivityManager = PIAConnectionLiveActivityManager.shared
            }
        }
    #endif

    func applicationWillTerminate(_ application: UIApplication) {
        Bootstrapper.shared.dispose()

        #if !targetEnvironment(macCatalyst)
            Task.blockingThreadUnsafe { [weak liveActivityManager] in
                await liveActivityManager?.endLiveActivities()
            }
        #endif
    }

    // MARK: Orientations

    // Deprecated in favour of `UIWindowSceneDelegate.supportedInterfaceOrientations(for:)`, which
    // is iOS 27+ only. This stays on the app delegate until the deployment target allows the move.
    @available(iOS, deprecated: 27.0)
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard UserInterface.isPhone else {
            return .all
        }

        let rootViewController = Self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController)
        switch rootViewController {
        // Matched on a protocol rather than a concrete class: the previous
        // `is GetStartedViewController` check would have silently stopped locking the orientation
        // the moment that screen was replaced.
        case is PortraitLockedViewController, is PIACardsViewController:
            return .portrait
        default:
            return .all
        }
    }

    static func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if let nav = rootViewController as? UINavigationController {
            return topViewControllerWithRootViewController(rootViewController: nav.visibleViewController)
        }
        if let split = rootViewController as? UISplitViewController {
            if let secondary = split.viewController(for: .secondary) {
                return topViewControllerWithRootViewController(rootViewController: secondary)
            }
            if let last = split.viewControllers.last {
                return topViewControllerWithRootViewController(rootViewController: last)
            }
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
            L10n.Notifications.Disabled.title,
            L10n.Notifications.Disabled.message
        )
        alert.addActionWithTitle(L10n.Notifications.Disabled.settings) {
            application.open(
                URL(string: UIApplication.openSettingsURLString)!,
                options: [:],
                completionHandler: nil)
        }
        alert.addCancelAction(L10n.Global.ok)
        RootCoordinator.shared.topPresentedViewController()?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("Received local notification: \(notification)")

        application.applicationIconBadgeNumber = 0
    }

}

extension AppDelegate {
    static func delegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    static func getRootTopViewController() -> UIViewController? {
        return RootCoordinator.shared.topPresentedViewController()
    }
}
