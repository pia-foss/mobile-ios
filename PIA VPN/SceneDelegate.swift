//
//  SceneDelegate.swift
//  PIA VPN
//
//  Created by Mario on 02/09/26.
//  Copyright © 2026 Private Internet Access, Inc.
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
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import UIKit

private let log = PIALogger.logger(for: SceneDelegate.self)

/// Owns one instance of the app's UI. `AppDelegate` keeps the process-level setup; everything that
/// belongs to a window — the root view controller, the foreground/background transitions, and the
/// URL, quick action and Siri entry points — lives here.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private enum ShortcutItem: String {
        case connect

        case disconnect

        case selectRegion
    }

    private let defaultMilliseconds = 200

    /// Set by UIKit from `UISceneStoryboardFile` before `scene(_:willConnectTo:options:)` runs.
    var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Scene life cycle

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Keep the launch screen presented while the migration check runs
        window?.rootViewController = UIStoryboard(name: "Launch Screen", bundle: nil).instantiateInitialViewController() ?? UIViewController()

        Bootstrapper.shared.shouldConfirmPlatformSDKMigration { [weak self] shouldConfirm in
            guard shouldConfirm else {
                self?.startApp(with: connectionOptions)
                return
            }

            self?.window?.rootViewController = PlatformSDKMigrationViewController {
                Bootstrapper.shared.confirmPlatformSDKMigration()
                self?.startApp(with: connectionOptions)
            }
        }
    }

    private func startApp(with connectionOptions: UIScene.ConnectionOptions) {
        AppDelegate.delegate().startApp()

        observeVPNStatusForShortcutItems()

        if let window {
            RootCoordinator.shared.install(in: window)
        }

        handle(connectionOptions)
    }

    /// Replays the reason the scene was created. UIKit delivers a cold-launch URL, quick action or
    /// user activity here instead of through the callbacks below, and all three handlers need the
    /// root already installed.
    private func handle(_ connectionOptions: UIScene.ConnectionOptions) {
        for urlContext in connectionOptions.urlContexts {
            handle(url: urlContext.url)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItemIfLoggedIn(shortcutItem)
        }

        for userActivity in connectionOptions.userActivities {
            handle(userActivity: userActivity)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        refreshShortcutItems()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Remove the Non compliant Wifi local notification as the app is in foreground now
        Macros.removeLocalNotification(NotificationCategory.nonCompliantWifi)

        #if !targetEnvironment(macCatalyst)
            AppDelegate.delegate().instantiateLiveActivityManagerIfNeeded()
        #endif

        let accountInformationVerifier = AccountInformationAvailabilityFactory.makeAccountInformationAvailabilityVerifier()

        accountInformationVerifier.verifyAccountInformationAvailabity(after: AccountInformationAvailabilityVerifier.defaultDeadlineInSeconds, completion: nil)

        Client.providers.accountProvider.featureFlags { _ in
            if Client.configuration.featureFlags[.forceUpdate] {
                NotificationCenter.default.post(name: Notification.Name.__AppDidFetchForceUpdateFeatureFlag, object: nil)
            }
        }
    }

    // MARK: URLs

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            handle(url: urlContext.url)
        }
    }

    @discardableResult
    private func handle(url: URL) -> Bool {
        log.debug("Opened app from URL: \(url)")

        if url.absoluteString.starts(with: AppConstants.MagicLink.url) {

            log.debug("Trying to login using magic link")

            guard !Client.providers.accountProvider.isLoggedIn else {
                log.debug("User is already logged in")
                return false
            }

            guard let signupCoordinator = RootCoordinator.shared.activeSignupCoordinator else {
                log.error("Magic link opened with no signup flow on screen")
                return false
            }

            let rootViewController = AppDelegate.topViewControllerWithRootViewController(rootViewController: window?.rootViewController)
            rootViewController?.navigationController?.popToRootViewController(animated: false)

            let token = url.absoluteString[AppConstants.MagicLink.url.count...]
            signupCoordinator.handleMagicLink(token: token)

        } else if url.absoluteString.starts(with: AppConstants.Widget.connect), #unavailable(iOS 17) {
            if Client.providers.vpnProvider.isVPNConnected {
                disconnectAfter(milliseconds: defaultMilliseconds)
            } else {
                connectAfter(milliseconds: defaultMilliseconds)
            }
        } else if url.absoluteString.starts(with: AppConstants.QRSignin.url) {
            let token = url.absoluteString[AppConstants.QRSignin.url.count...]
            Client.configuration.tvOSBindToken = token

            if let dashboardViewController = RootCoordinator.shared.dashboard {
                if let apiToken = Client.providers.accountProvider.apiToken,
                    let viewController = ValidateQRLoginFactory.makeValidateQRLoginViewController(apiToken: apiToken, tvOSBindToken: token)
                {
                    viewController.modalPresentationStyle = .fullScreen
                    dashboardViewController.present(viewController, animated: true)
                }
            }
        }

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

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcutItemIfLoggedIn(shortcutItem))
    }

    @discardableResult
    private func handleShortcutItemIfLoggedIn(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        log.debug("Opened app from shortcut item: \(shortcutItem.type)")

        guard Client.providers.accountProvider.isLoggedIn else {
            return false
        }

        handleShortcutItem(shortcutItem)
        return true
    }

    private func observeVPNStatusForShortcutItems() {
        // call first on app open
        refreshShortcutItems()
        // observe vpn status change
        NotificationCenter.default
            .publisher(for: .PIADaemonsDidUpdateVPNStatus)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in
                let status = Client.providers.vpnProvider.vpnStatus
                guard status == .connected || status == .disconnected else { return }
                self?.refreshShortcutItems()
            }
            .store(in: &cancellables)
    }

    private func refreshShortcutItems() {
        guard Client.providers.accountProvider.isLoggedIn else {
            DispatchQueue.main.async { UIApplication.shared.shortcutItems = [] }
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

        DispatchQueue.main.async {
            UIApplication.shared.shortcutItems = items
        }
    }

    private func handleShortcutItem(_ item: UIApplicationShortcutItem) {
        guard let type = ShortcutItem(rawValue: item.type) else {
            return
        }

        switch type {
        case .connect:
            if !Client.providers.vpnProvider.isVPNConnected {
                // Dismiss any modally presented view controller on dashboard
                NotificationCenter.default.post(name: .PIADashboardShouldDismissModal, object: nil)

                // this time delay seems to fix a strange issue of the VPN connecting from a fresh launch
                connectAfter(milliseconds: defaultMilliseconds)
            }

        case .disconnect:
            if Client.providers.vpnProvider.isVPNConnected {
                // Dismiss any modally presented view controller on dashboard
                NotificationCenter.default.post(name: .PIADashboardShouldDismissModal, object: nil)

                // Dismiss the Leak Protection alert if present when disconnecting from a Quick Action
                dismissLeakProtectionAlert()

                // this time delay seems to fix a strange issue of the VPN disconnecting and
                // then automatically reconnecting when it's done from a fresh launch
                disconnectAfter(milliseconds: defaultMilliseconds)
            }

        case .selectRegion:
            guard let dashboard = RootCoordinator.shared.dashboard else {
                return
            }
            dashboard.selectRegion(animated: true)
        }
    }

    // MARK: Siri Shortcuts

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handle(userActivity: userActivity)
    }

    @discardableResult
    private func handle(userActivity: NSUserActivity) -> Bool {
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

    // MARK: Helpers

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

    private func dismissLeakProtectionAlert() {
        if let presentedAlert = RootCoordinator.shared.topPresentedViewController() as? UIAlertController {
            let leakProtectionAlertTitle = L10n.Dashboard.Vpn.Leakprotection.Alert.title

            if presentedAlert.title == leakProtectionAlertTitle {
                presentedAlert.dismiss(animated: true)
            }
        }
    }
}
