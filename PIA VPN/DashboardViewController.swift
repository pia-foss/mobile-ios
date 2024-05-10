//
//  DashboardViewController.swift
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
import SideMenu
import SwiftyBeaver
import WidgetKit
import NetworkExtension
import ActivityKit

private let log = SwiftyBeaver.self

enum DashboardVPNConnectingStatus: Int {
    case none = 0
    case pleaseWait
    case takingTime
    case stillLoading
}

class DashboardViewController: AutolayoutViewController {
    
    enum TileSize: CGFloat {
        case standard = 89.0
        case big = 150.0
    }
    
    enum NavBarTheme {
        case green
        case orange
        case normal
    }
    
    struct UsageTileReloadSeconds {
        static let afterConnect: TimeInterval = 5
        static let afterDisconnect: TimeInterval = 1
    }
    
    private var viewContentHeight: CGFloat = 0
    @IBOutlet weak var viewContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContentLandscapeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var viewContent: UIView!
    @IBOutlet private weak var toggleConnection: PIAConnectionButton!
    
    @IBOutlet private weak var viewRows: UIView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var currentPageIndex = 0
    private var isDisconnecting = false
    private var isUnauthorized = false

    private var currentStatus: VPNStatus = .disconnected {
        didSet {
            if #available(iOS 16.2, *) {
                startConnectionLiveActivityIfNeeded()
            }
        }
    }
    private var connectingStatus: DashboardVPNConnectingStatus = .none

    private var tileModeStatus: TileStatus = .normal {
        didSet {
            self.updateTileLayout()
        }
    }
    
    private var shouldReconnect = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadTheme()
        setupCollectionView()
        setupNavigationBarButtons()
        
        viewContent.isHidden = true
        viewRows.isHidden = true
        
        currentPageIndex = 0

        setupMenu()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(accountDidLogout(notification:)), name: .PIAAccountDidLogout, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidInstall(notification:)), name: .PIAVPNDidInstall, object: nil)
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        
        if UserInterface.isIpad {
            nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        nc.addObserver(self, selector: #selector(updateCurrentStatus), name: .PIAThemeDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateTiles), name: .PIATilesDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateFixedTileWithAnimation), name: .PIAUpdateFixedTiles, object: nil)
        nc.addObserver(self, selector: #selector(vpnShouldReconnect), name: .PIAQuickSettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(vpnShouldReconnect), name: .PIASettingsHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(presentKillSwitchAlert), name: .PIAPersistentConnectionTileHaveChanged, object: nil)
        nc.addObserver(self, selector: #selector(closeSession), name: .PIAAccountLapsed, object: nil)
        nc.addObserver(self, selector: #selector(reloadTheme), name: .PIAThemeShouldChange, object: nil)
        nc.addObserver(self, selector: #selector(checkAccountEmail), name: .PIAAccountDidRefresh, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidFail), name: .PIAVPNDidFail, object: nil)
        nc.addObserver(self, selector: #selector(unauthorized), name: .Unauthorized, object: nil)
        nc.addObserver(self, selector: #selector(openSettings), name: .OpenSettings, object: nil)
        nc.addObserver(self, selector: #selector(openSettingsAndWireGuard), name: .OpenSettingsAndActivateWireGuard, object: nil)
        nc.addObserver(self, selector: #selector(checkVPNConnectingStatus(notification:)), name: .PIADaemonsConnectingVPNStatus, object: nil)
        
        nc.addObserver(self, selector: #selector(connectionVPNStatusDidChange(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        nc.addObserver(self, selector: #selector(handleDidConnectToRFC1918CompliantWifi(_:)), name: NSNotification.Name.DeviceDidConnectToRFC1918CompliantWifi, object: nil)
        nc.addObserver(self, selector: #selector(checkConnectToRFC1918VulnerableWifi(_:)), name: NSNotification.Name.DeviceDidConnectToRFC1918VulnerableWifi, object: nil)
        
        self.viewContentHeight = self.viewContentHeightConstraint.constant
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBarButtons()
        
        AppPreferences.shared.wasLaunched = true
        
        guard Client.providers.accountProvider.isLoggedIn else {
            presentLogin()
            AppPreferences.shared.todayWidgetVpnStatus = L10n.Localizable.Today.Widget.login
            AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Today.Widget.login
            return
        }
        
        #if !TARGET_IPHONE_SIMULATOR
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        #endif

        AppPreferences.shared.todayWidgetVpnStatus = Client.providers.vpnProvider.vpnStatus.rawValue
        if Client.providers.vpnProvider.vpnStatus == .disconnected {
            AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Shortcuts.connect
        } else {
            AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Shortcuts.disconnect
        }
        
        viewContent.isHidden = false
        viewRows.isHidden = false

        collectionView.reloadData()
        updateCurrentStatus()
        setupCallingCards()
        
        // Checks if survey needs to be shown
        if UserSurveyManager.shouldShowSurveyMessage() {
            MessagesManager.shared.showInAppSurveyMessage()
        }
        
        checkTVOSTokenToBind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        guard Client.providers.accountProvider.isLoggedIn else {
            return
        }

        if TransientState.shouldDisplayRegionPicker {
            TransientState.shouldDisplayRegionPicker = false
            selectRegion(animated: false)
        }

        // give up pending signup if logged in
        TransientState.didRetryPendingSignup = true
        
        // check account email
        checkAccountEmail()

    }
    
    private func checkTVOSTokenToBind() {
        guard let apiToken = Client.providers.accountProvider.apiToken,
        let token = Client.configuration.tvOSBindToken else { return }
        
        guard let viewController = ValidateQRLoginFactory.makeValidateQRLoginViewController(apiToken: apiToken, tvOSBindToken: token) else { return }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    // MARK: Menu
    private func setupMenu() {
        if SideMenuManager.default.leftMenuNavigationController == nil {
            SideMenuManager.default.leftMenuNavigationController = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        }
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        if let menuNavigationController = SideMenuManager.default.leftMenuNavigationController {
            setMenuDelegate(menuNavigationController: menuNavigationController)
        }
    }
    
    private func setMenuDelegate(menuNavigationController: UINavigationController) {
        guard let menu = menuNavigationController.topViewController as? MenuViewController else {
            return
        }
        menu.delegate = self
    }
    
    // MARK: Calling Cards
    private func setupCallingCards() {
        
        if AppPreferences.shared.appVersion == nil || (AppPreferences.shared.appVersion != nil && AppPreferences.shared.appVersion != Macros.versionString()) {
            
            let callingCards = CardFactory.getCardsForVersion(Macros.versionString())
            if !callingCards.isEmpty {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let cardsController = storyboard.instantiateViewController(withIdentifier: "PIACardsViewController") as? PIACardsViewController {
                    cardsController.setupWith(cards: callingCards)
                    cardsController.modalPresentationStyle = .overCurrentContext
                    self.present(cardsController, animated: true)
                }
            }
            
            AppPreferences.shared.appVersion = Macros.versionString()

        }

    }
    
    // MARK: Actions
    private func setupCollectionView() {
        let collectionViewUtil = DashboardCollectionViewUtil()
        collectionViewUtil.registerCellsFor(collectionView)
    }
    
    private func setupNavigationBarButtons() {
        
        guard AppPreferences.shared.wasLaunched,
            Client.providers.accountProvider.isLoggedIn else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            return
        }

        switch self.tileModeStatus { //change the status
        case .normal:
            if let leftBarButton = navigationItem.leftBarButtonItem,
                leftBarButton.accessibilityLabel != L10n.Localizable.Global.cancel {
                leftBarButton.image = Asset.Images.itemMenu.image
                leftBarButton.action = #selector(openMenu(_:))
            } else {
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: Asset.Images.itemMenu.image,
                    style: .plain,
                    target: self,
                    action: #selector(openMenu(_:))
                )
            }
            navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Localizable.Menu.Accessibility.item
            navigationItem.leftBarButtonItem?.accessibilityIdentifier = Accessibility.Id.Dashboard.menu
            
            if navigationItem.rightBarButtonItem == nil {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: Asset.Images.Piax.Global.iconEditTile.image,
                    style: .plain,
                    target: self,
                    action: #selector(updateEditTileStatus(_:))
                )
                navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Localizable.Menu.Accessibility.Edit.tile
            }
            
        case .edit:
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .stop,
                target: self,
                action: #selector(closeTileEditingMode(_:))
            )
            navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Localizable.Global.cancel
            navigationItem.leftBarButtonItem?.accessibilityIdentifier = nil
            navigationItem.rightBarButtonItem = nil
            
        }
        
    }

    private func updateTileLayout() {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            self.toggleConnection.alpha = self.tileModeStatus == .normal ? 1 : 0
            self.viewContentHeightConstraint.constant = self.tileModeStatus == .normal ? self.viewContentHeight : 0
            self.viewContentLandscapeHeightConstraint.constant = self.tileModeStatus == .normal ? self.viewContentHeight : 0
            self.view.layoutIfNeeded()
        })
        collectionView.reloadData()
        setupNavigationBarButtons()
    }
    
    private func presentLogin() {
        
        dismissExistingViewController()
        
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.shouldRecoverPendingSignup = false//!TransientState.didRetryPendingSignup
        if !TransientState.didRetryPendingSignup {
            TransientState.didRetryPendingSignup = true
        }

        let vc = GetStartedViewController.with(preset: preset, delegate: self)
        vc.modalPresentationStyle = .fullScreen
        
        if let presented = self.navigationController?.presentedViewController,
            presented != self {
            self.present(vc, animated: true, completion: {
                presented.dismiss(animated: true, completion: nil)
            })
        } else {
            present(vc, animated: false, completion: nil)
        }
        
        if isUnauthorized {
            Macros.displayImageNote(withImage: Asset.Images.iconWarning.image, message: L10n.Localizable.Account.unauthorized)
            isUnauthorized = false
        }
        
    }
    
    public static func instanceInNavigationStack() -> DashboardViewController? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let rootNavVC = appDelegate.window?.rootViewController as? UINavigationController,
            let dashboard = rootNavVC.viewControllers.first as? DashboardViewController {
            return dashboard
        }
        return nil
    }
    
    func dismissExistingViewController() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func presentPurchaseForTrial() {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.pages = .purchase
        preset.allowsCancel = true
        preset.shouldRecoverPendingSignup = false
        preset.isEphemeral = true
        preset.openFromDashboard = true

        let vc = GetStartedViewController.withPurchase(preset: preset, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func unauthorized() {
        self.isUnauthorized = true
    }
    
    @objc private func checkVPNConnectingStatus(notification: Notification) {
        if let attempt = notification.object as? Int {
            connectingStatus = DashboardVPNConnectingStatus(rawValue: attempt) ?? .stillLoading
            updateCurrentStatus()
        }
    }
    
    @objc private func openMenu(_ sender: Any?) {
        Theme.current.applySideMenu()
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true)
    }
    
    @objc private func closeTileEditingMode(_ sender: Any?) {
        self.tileModeStatus = .normal
    }
    
    @objc private func updateEditTileStatus(_ sender: Any?) {
        switch self.tileModeStatus { //change the status
        case .normal:
            self.tileModeStatus = .edit
        case .edit:
            self.tileModeStatus = .normal
        }
    }

    @IBAction func vpnButtonClicked(_ sender: Any?) {
        if canConnectVPN() {
            manuallyConnect()
        } else {
            
            //User clicked the button, the disconnection of the VPN was manual
            Client.configuration.disconnectedManually = true

            disconnectWithOneSecondDelay()

        }
        Macros.postNotification(.PIAVPNUsageUpdate)
    }
    
    private func canConnectVPN() -> Bool {
        return !toggleConnection.isOn &&
        Client.providers.vpnProvider.vpnStatus != .disconnecting &&
        Client.providers.vpnProvider.vpnStatus != .connecting
    }
    
    private func manuallyConnect() {
        let accountInformationVerifier = AccountInformationAvailabilityFactory.makeAccountInformationAvailabilityVerifier()
        let threeHoursInSeconds: TimeInterval = 10800
        
        accountInformationVerifier.verifyAccountInformationAvailabity(after: threeHoursInSeconds, completion: nil)
        
        Client.providers.vpnProvider.connect({ [weak self] error in
            
            //User clicked the button, the connection of the VPN was manual
            Client.configuration.connectedManually = true
            
            guard let weakSelf = self else { return }
            if let _ = error {
                RatingManager.shared.handleConnectionError()
            }
            
            let preferences = Client.preferences.editable()
            preferences.lastConnectedRegion = Client.providers.serverProvider.targetServer
            preferences.commit()
            
            if Client.providers.vpnProvider.vpnStatus == .disconnected {
                weakSelf.handleDisconnectedAndTrustedNetwork()
                if TrustedNetworkUtils.isTrustedNetwork {
                    //Show additionally a message indicating the VPN is enabled but disconnected given the current NMT settings
                    weakSelf.showAutomationAlert() {
                        weakSelf.manuallyConnect()
                    }
                }
            }
            weakSelf.reloadUsageTileAfter(seconds: UsageTileReloadSeconds.afterConnect) //Show usage statistics after connecting

        })
        
        Macros.postNotification(.PIAServerHasBeenUpdated)
    }
    
    func showAutomationAlert(onNMTDisableAction: (() -> ())? = nil) {
        let alert = Macros.alert(nil, L10n.Localizable.Network.Management.Tool.alert)
        alert.addCancelAction(L10n.Localizable.Global.close)
        alert.addActionWithTitle(L10n.Localizable.Network.Management.Tool.disable) {
            let preferences = Client.preferences.editable()
            preferences.nmtRulesEnabled = !Client.preferences.nmtRulesEnabled
            preferences.commit()
            NotificationCenter.default.post(name: .PIAQuickSettingsHaveChanged,
                                            object: self,
                                            userInfo: nil)
            onNMTDisableAction?()
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func disconnectWithOneSecondDelay() {
        Client.providers.vpnProvider.disconnect({ [weak self] _ in
            self?.updateCurrentStatus()
            self?.reloadUsageTileAfter(seconds: UsageTileReloadSeconds.afterDisconnect) //Reset the usage statistics after stop the VPN
        })
    }
    
    private func reloadUsageTileAfter(seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            Macros.postNotification(.PIAVPNUsageUpdate)
        }
    }
    
    @IBAction private func selectRegion(_ sender: Any?) {
        selectRegion(animated: true)
    }
    
    func selectRegion(animated: Bool) {
        let segue = (animated ? StoryboardSegue.Main.selectRegionAnimatedSegueIdentifier : StoryboardSegue.Main.selectRegionSegueIdentifier)
        perform(segue: segue)
    }

    @objc func openSettings() {
        perform(segue: StoryboardSegue.Main.settingsSegueIdentifier)
    }
    
    @objc func openSettingsAndWireGuard() {
        perform(segue: StoryboardSegue.Main.settingsAndWireGuardSegueIdentifier)
    }
    
    func openAccount() {
        perform(segue: StoryboardSegue.Main.accountSegueIdentifier)
    }

    func openDedicatedIp() {
        perform(segue: StoryboardSegue.Main.dedicatedIpSegueIdentifier)
    }

    func openAbout() {
        perform(segue: StoryboardSegue.Main.aboutSegueIdentifier)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.setEmptyBackButton()

        if let sideMenu = segue.destination as? SideMenuNavigationController {
            setMenuDelegate(menuNavigationController: sideMenu)
        } else if let nmt = segue.destination as? TrustedNetworksViewController {
            nmt.shouldReconnectAutomatically = true
            nmt.persistentConnectionValue = Client.preferences.isPersistentConnection
        } else if let vc = segue.destination as? AddEmailToAccountViewController {
            vc.modalPresentationStyle = .fullScreen
        } else if let vc = segue.destination as? RegionsViewController {
            vc.serverSelectionDelegate = self
        } else if let identifier = segue.identifier,
            identifier == StoryboardSegue.Main.settingsAndWireGuardSegueIdentifier.rawValue,
            let vc = segue.destination as? SettingsViewController {
            vc.shouldSetWireGuardSettings = true
        }
    }
    
    // MARK: Unwind segues
    
    @IBAction private func unwoundWalkthroughViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction private func unwoundRegionsViewController(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: Notifications

    @objc private func vpnDidInstall(notification: Notification) {
        log.debug("Installed VPN profile!")
    }
    
    @objc private func applicationDidBecomeActive(notification: Notification) {
        perform(#selector(updateCurrentStatus))
        if Client.providers.accountProvider.isLoggedIn {
            Client.providers.accountProvider.refreshAccountInfo(nil)
        }
    }
    
    @objc private func viewHasRotated() {
        if Client.providers.accountProvider.isLoggedIn {
            if tileModeStatus == .edit,
                let tileLayout = collectionView.collectionViewLayout as? TileFlowLayout {
                tileLayout.removeDraggingViewFromSuperView()
            }
            updateCurrentStatus()
            updateTileLayout()
        }
    }

    @objc private func accountDidLogout(notification: Notification) {
        AppPreferences.shared.todayWidgetVpnStatus = nil
        AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Today.Widget.login
        if #available(iOS 16.2, *) {
            stopConnectionLiveActivity()
        }
        presentLogin()
    }
    
    @objc private func closeSession() {
        log.debug("Account: Logging out...")
        AppPreferences.shared.reset()
        if let window = self.view.window,
            let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: false, completion: nil)
        }
        Client.providers.accountProvider.logout(nil)
    }
    
    // MARK: Notifications (Connection)
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        performSelector(onMainThread: #selector(updateCurrentStatusWithUserInfo(_:)), with: notification.userInfo, waitUntilDone: false)
    }
    
    @objc private func presentKillSwitchAlert() {
        let alert = Macros.alert(nil, L10n.Localizable.Settings.Nmt.Killswitch.disabled)
        alert.addCancelAction(L10n.Localizable.Global.close)
        alert.addActionWithTitle(L10n.Localizable.Global.enable) {
            let preferences = Client.preferences.editable()
            preferences.isPersistentConnection = true
            preferences.commit()
            NotificationCenter.default.post(name: .PIAQuickSettingsHaveChanged,
                                            object: self,
                                            userInfo: nil)
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func vpnShouldReconnect() {
        if Client.providers.vpnProvider.vpnStatus != .disconnected {
            let alert = Macros.alert(
                title,
                L10n.Localizable.Settings.Commit.Messages.shouldReconnect
            )
            
            // reconnect -> reconnect VPN and close
            alert.addActionWithTitle(L10n.Localizable.Settings.Commit.Buttons.reconnect) {
                Client.providers.vpnProvider.reconnect(after: nil, forceDisconnect: true, { error in
                })
            }
            
            // later -> close
            alert.addCancelActionWithTitle(L10n.Localizable.Settings.Commit.Buttons.later) {
            }
            
            present(alert, animated: true, completion: nil)
        } else {
            Client.providers.vpnProvider.install(force: false, { _ in
                self.updateCurrentStatus()
            })
        }
    }
    
    @objc func connectionVPNStatusDidChange(_ notification: Notification? = nil) {
        guard let connection = notification?.object as? NEVPNConnection else { return }
        
        switch connection.status {
        case .connected:
            if !Client.providers.vpnProvider.isVPNConnected {
                handleNonCompliantWifiConnection()
            }
        case .disconnected:
           
            let state = UIApplication.shared.applicationState
            
            // Only remove the notification if the app is on the foreground
            if state == .active {
                removeNonCompliantWifiLocalNotification()
            }
            
            if shouldReconnect {
                Client.providers.vpnProvider.connect { _ in }
                shouldReconnect = false
            }
        default:
            break
        }
    }
    
    @objc func checkConnectToRFC1918VulnerableWifi(_ notification: Notification? = nil) {
        guard Client.providers.vpnProvider.isVPNConnected else { return }
        
        handleNonCompliantWifiConnection()
    }
    
    @objc func handleDidConnectToRFC1918CompliantWifi(_ notification: Notification) {
        // Remove non compliant wifi notification if it was present in notification center
        removeNonCompliantWifiLocalNotification()
        
        // Remove leak protection alert when connecting to a compliant Wi-Fi
        removeLeakProtectionAlert()
    }
    
    private func handleNonCompliantWifiConnection() {
        guard WifiNetworkMonitor().isConnected() else { return }
        
        guard Client.preferences.currentRFC1918VulnerableWifi != nil
                || WifiNetworkMonitor().checkForRFC1918Vulnerability() else { return }
        
        guard AppPreferences.shared.showLeakProtectionNotifications else { return }
        
        let currentRFC1918VulnerableWifiName = Client.preferences.currentRFC1918VulnerableWifi ?? ""
      
        let selectedProtocol = Client.preferences.vpnType.vpnProtocol
        let isWireguardSelected = selectedProtocol == PIAWGTunnelProfile.vpnType.vpnProtocol
        let isOpenVPNSelected = selectedProtocol == PIATunnelProfile.vpnType.vpnProtocol
      
        guard !isWireguardSelected,
              !isOpenVPNSelected else {
            DispatchQueue.main.async {
                self.presentNonCompliantWireguardWifiAlert()
                self.showNonCompliantWifiLocalNotification(currentRFC1918VulnerableWifiName: currentRFC1918VulnerableWifiName)
            }
            
            return
        }
        
        guard Client.preferences.allowLocalDeviceAccess
                && Client.preferences.leakProtection else { return }
      
        DispatchQueue.main.async {
            self.presentNonCompliantWifiAlert()
            self.showNonCompliantWifiLocalNotification(currentRFC1918VulnerableWifiName: currentRFC1918VulnerableWifiName)
        }
    }
    
    //MARK: Non compliant Wifi alert
    
    private struct WifiAlertAction {
        let title: String
        let style: UIAlertAction.Style
        let action: ((UIAlertAction) -> Void)?
    }
    
    private func showNonCompliantWifiAlert(title: String, message: String, actions: [WifiAlertAction]) {
        guard
            let window = UIApplication.shared.delegate?.window,
            let presentedViewController = window?.rootViewController?.presentedViewController ?? window?.rootViewController
        else { return }
        
        if let alertController = presentedViewController as? UIAlertController, alertController.title == title { return }
        
        let sheet = Macros.alertController(title, message)
        
        for action in actions {
            let alertAction = UIAlertAction(title: action.title,
                                       style: action.style,
                                       handler: action.action)
            sheet.addAction(alertAction)
        }
        
        presentedViewController.present(sheet, animated: true, completion: nil)
    }
    
    private func presentNonCompliantWifiAlert() {
        let title = L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.title
        let message = L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.message
        
        var alertActions = [WifiAlertAction]()
        let reconnectAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.cta1,
            style: .default,
            action: handleDisconnectAndReconnectAction)
        alertActions.append(reconnectAction)
        
        let learnMoreAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.cta2,
            style: .default,
            action: handleLearnMoreAction)
        alertActions.append(learnMoreAction)
        
        let cancelAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.cta3,
            style: .cancel,
            action: nil)
        alertActions.append(cancelAction)
        
        showNonCompliantWifiAlert(title: title, message: message, actions: alertActions)
    }
    
    private func presentNonCompliantWireguardWifiAlert() {
        let title = L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.title
        let message = L10n.Localizable.Dashboard.Vpn.Leakprotection.Ikev2.Alert.message
        
        var alertActions = [WifiAlertAction]()
        let reconnectAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Ikev2.Alert.cta1,
            
            style: .default,
            action: handleSwitchProtocolAction)
        alertActions.append(reconnectAction)
        
        let learnMoreAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.cta2,
            style: .default,
            action: handleLearnMoreAction)
        alertActions.append(learnMoreAction)
        
        let cancelAction = WifiAlertAction(
            title: L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.cta3,
            style: .cancel,
            action: nil)
        alertActions.append(cancelAction)
        
        showNonCompliantWifiAlert(title: title, message: message, actions: alertActions)
    }
    
    private func handleDisconnectAndReconnectAction(_ action: UIAlertAction) {
        Client.preferences.allowLocalDeviceAccess = false
        Client.providers.vpnProvider.disconnect { _ in
            self.shouldReconnect = true
        }
    }
    
    private func handleLearnMoreAction(_ action: UIAlertAction) {
        let application = UIApplication.shared
        let learnMoreURL = AppConstants.Web.leakProtectionURL
        
        if application.canOpenURL(learnMoreURL) {
            application.open(learnMoreURL)
        }
    }
    
    private func handleSwitchProtocolAction(_ action: UIAlertAction) {
        let editable = Client.preferences.editable()
        editable.vpnType = IKEv2Profile.vpnType
        let action = editable.requiredVPNAction()
        editable.commit()
        
        Client.preferences.leakProtection = true
        Client.preferences.allowLocalDeviceAccess = false
        
        action?.execute { _ in
            self.shouldReconnect = true
        }
    }
    
    func showNonCompliantWifiLocalNotification(currentRFC1918VulnerableWifiName: String) {
        // 1. Remove previous non-compliant wifi notification
        removeNonCompliantWifiLocalNotification()
        
        // 2. Show the local notification for the current non-compliant wifi
        Macros.showLocalNotificationIfNotAlreadyPresent(NotificationCategory.nonCompliantWifi, type: NotificationCategory.nonCompliantWifi, body: L10n.Localizable.LocalNotification.NonCompliantWifi.text, title: L10n.Localizable.LocalNotification.NonCompliantWifi.title(currentRFC1918VulnerableWifiName), delay: 0)
    }
    
    private func removeNonCompliantWifiLocalNotification() {
        // Remove non compliant wifi notification if it was present in notification center
        Macros.removeLocalNotification(NotificationCategory.nonCompliantWifi)
    }
  
    private func removeLeakProtectionAlert() {
        guard let presentedLeakProtectionAlert = UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController as? UIAlertController,
              presentedLeakProtectionAlert.title == L10n.Localizable.Dashboard.Vpn.Leakprotection.Alert.title else { return }
        
        presentedLeakProtectionAlert.dismiss(animated: true)
    }
  
    
    // MARK: Helpers
    @objc private func vpnDidFail() {
        if !isDisconnecting {
            isDisconnecting = true
            Client.providers.vpnProvider.disconnect { _ in
                RatingManager.shared.handleConnectionError()
                self.isDisconnecting = false
                self.connectingStatus = .none
            }
        }
    }
    
    @objc private func checkAccountEmail() {

        if let currentUser = Client.providers.accountProvider.currentUser,
            let info = currentUser.info {
            if info.email == nil || info.email == "" {
                //No email, we need to show the account email view
                if Client.providers.accountProvider.isLoggedIn {
                    self.perform(segue: StoryboardSegue.Main.showAddEmailSegue)
                }
            }
        }
    }

    @objc private func updateCurrentStatus() {
        updateCurrentStatusWithUserInfo(nil)
    }
    
    @objc private func updateTiles() {
        collectionView.reloadData()
    }
    
    @objc private func updateFixedTileWithAnimation() {
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(0...0))
        }, completion: nil)
    }
    
    @objc private func reloadTheme() {
        AppPreferences.shared.reloadTheme()
    }

    @objc private func updateCurrentStatusWithUserInfo(_ userInfo: [AnyHashable: Any]?) {
        
        guard Client.providers.accountProvider.isLoggedIn else {
            return
        }
        
        if #available(iOS 16.2, *) {
            startConnectionLiveActivityIfNeeded()
        }

        currentStatus = Client.providers.vpnProvider.vpnStatus

        Macros.postNotification(.PIAServerHasBeenUpdated)
        Macros.postNotification(.PIAVPNUsageUpdate)

        switch currentStatus {
        case .connected:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = false
            toggleConnection.isWarning = false
            toggleConnection.stopButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .connected
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.adjustsFontSizeToFitWidth = true
            titleLabelView.style(style: TextStyle.textStyle6)
            
            let effectiveServer = Client.preferences.displayedServer
            let vpn = Client.providers.vpnProvider

            titleLabelView.text = L10n.Localizable.Dashboard.Vpn.connected+": "+effectiveServer.name(forStatus: vpn.vpnStatus)
            setNavBarTheme(.green, with: titleLabelView)
            AppPreferences.shared.todayWidgetVpnStatus = VPNStatus.connected.rawValue
            AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Shortcuts.disconnect
            Macros.removeStickyNote()
            connectingStatus = .none
            
        case .disconnected:
            
            toggleConnection.isOn = false
            AppPreferences.shared.lastVPNConnectionStatus = .disconnected

            handleDisconnectedAndTrustedNetwork()
            toggleConnection.stopButtonAnimation()
            
        case .connecting:
            Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
            toggleConnection.isOn = false
            toggleConnection.isWarning = false
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .connecting
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: Theme.current.palette.appearance == .dark ?
                TextStyle.textStyle6 :
                TextStyle.textStyle7)
            switch connectingStatus {
            case .pleaseWait:
                titleLabelView.text = L10n.Localizable.Server.Reconnection.Please.wait.uppercased()
            case .takingTime, .stillLoading:
                titleLabelView.text = L10n.Localizable.Server.Reconnection.Still.connection.uppercased()
            default:
                titleLabelView.text = L10n.Localizable.Dashboard.Vpn.connecting.uppercased()
            }
            setNavBarTheme(.normal, with: titleLabelView)

        case .disconnecting:
            toggleConnection.isOn = true
            toggleConnection.isWarning = false
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .disconnecting
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: Theme.current.palette.appearance == .dark ?
                TextStyle.textStyle6 :
                TextStyle.textStyle7)
            titleLabelView.text = L10n.Localizable.Dashboard.Vpn.disconnecting.uppercased()
            setNavBarTheme(.normal, with: titleLabelView)

        case .unknown:
            break
//        case .changingServer:
//            powerConnection.powerState = .pending
//            labelStatus.text = L10n.Dashboard.Vpn.changingRegion
        }

        AppPreferences.shared.todayWidgetVpnProtocol = Client.preferences.vpnType.vpnProtocol
        AppPreferences.shared.todayWidgetVpnSocket = Client.preferences.vpnType.port
        AppPreferences.shared.todayWidgetVpnPort = Client.preferences.vpnType.socket
        reloadWidget()
        
    }
    
    private func setNavBarTheme(_ theme: NavBarTheme, with titleView: UIView) {
        DispatchQueue.main.async {
            var tintColor: UIColor?
            var barTintColors: [UIColor]?
            switch theme {
            case .green:
                tintColor = .white
                barTintColors = [UIColor.piaGreen, UIColor.piaGreenDark20]
            case .orange:
                tintColor = .white
                barTintColors = [UIColor.piaOrange, UIColor.piaOrange]
            default:
                break
            }
            Theme.current.applyCustomNavigationBar(self.navigationController!.navigationBar,
                                                   withTintColor: tintColor,
                                                   andBarTintColors: barTintColors)
            self.setNavBarTitleView(titleView: titleView)
        }
    }
    
    private func setNavBarTitleView(titleView: UIView) {
        self.navigationItem.titleView = titleView
        self.setNeedsStatusBarAppearanceUpdate()
    }

    private func reloadWidget() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "PIAWidget")
        }
    }
    
    private func handleDisconnectedAndTrustedNetwork() {
        if TrustedNetworkUtils.isTrustedNetwork {
            toggleConnection.isIndeterminate = false
            toggleConnection.isWarning = true
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.text = L10n.Localizable.Dashboard.Vpn.disconnected+": "+L10n.Localizable.Tiles.Nmt.Accessibility.trusted
            titleLabelView.adjustsFontSizeToFitWidth = true
            titleLabelView.style(style: TextStyle.textStyle6)
            toggleConnection.tintColor = UIColor.piaOrange
            setNavBarTheme(.orange, with: titleLabelView)

        } else {
            toggleConnection.isIndeterminate = false
            toggleConnection.isWarning = false
            resetNavigationBar()
            AppPreferences.shared.todayWidgetVpnStatus = VPNStatus.disconnected.rawValue
            AppPreferences.shared.todayWidgetButtonTitle = L10n.Localizable.Shortcuts.connect
        }
    }
    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewContainer!)
        Theme.current.applyPrincipalBackground(viewContent)
        Theme.current.applyPrincipalBackground(viewRows)

        Theme.current.applyLightNavigationBar(navigationController!.navigationBar)
        
        Theme.current.applyPrincipalBackground(collectionView)

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    private func resetNavigationBar() {
        //First reset the green background
        self.setNavBarTheme(.normal, with: NavigationLogoView())
        DispatchQueue.main.async {
            //Show the PIA logo
            if let navController = self.navigationController {
                //Apply the theme background color
                Theme.current.applyLightNavigationBar(navController.navigationBar)
            }
        }
    }
}

extension DashboardViewController: PIAWelcomeViewControllerDelegate {
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController) {
        showVPNModal(target: topViewController)
    }
    
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController) {

        // trial account did purchase, replace current user
        if welcomeController.isEphemeral {
            Client.providers.accountProvider.currentUser = user
        }

        showVPNModal(target: topViewController)
    }
    
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController) {
        dismiss(animated: true)
    }

    private func showVPNModal(target: UIViewController) {
        let vc = StoryboardScene.Main.vpnPermissionViewController.instantiate()
        vc.dismissingViewController = self
        target.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DashboardViewController: MenuViewControllerDelegate {
    func menu(_ menu: MenuViewController, didSelect item: MenuViewController.Item) {
        switch item {
        case .selectRegion:
            selectRegion(animated: true)
        case .settings:
            openSettings()
        case .dedicatedIp:
            openDedicatedIp()
        case .account:
            openAccount()
        case .about:
            openAbout()
        case .logout:
            resetNavigationBar()
            presentLogin()
        case .version:
            break
        default:
            fatalError("Unhandled item '\(item)'")
        }
    }
    
    func menu(didDetectTrialUpgrade: MenuViewController) {
        presentPurchaseForTrial()
    }
}

// MARK: CollectionView

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == DashboardSections.tiles.rawValue {
            let tileIndex = tileModeStatus == .normal ?
                Client.providers.tileProvider.visibleTiles[indexPath.row].rawValue :
                Client.providers.tileProvider.orderedTiles[indexPath.row].rawValue

            var tileHeight = TileSize.standard.rawValue
            if tileIndex < Cells.countCases() && Cells.objectIdentifyBy(index: tileIndex).identifier == Cells.connectionTile.identifier {
                tileHeight = TileSize.big.rawValue
            }
            
            return CGSize(width: collectionView.frame.width,
                          height: tileHeight)
        } else {
            return CGSize(width: collectionView.frame.width,
                          height: TileSize.standard.rawValue)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var tileIndex = 0
        var identifier = FixedCells.objectIdentifyBy(index: tileIndex).identifier
        
        if indexPath.section == DashboardSections.tiles.rawValue {
            tileIndex = tileModeStatus == .normal ?
                Client.providers.tileProvider.visibleTiles[indexPath.row].rawValue :
                Client.providers.tileProvider.orderedTiles[indexPath.row].rawValue
            identifier = Cells.objectIdentifyBy(index: tileIndex).identifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath)
        if let cell = cell as? EditableTileCell {
            cell.setupCellForStatus(self.tileModeStatus)
        }
        if let cell = cell as? ServerSelectingCell {
            cell.delegate = self
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !Client.providers.accountProvider.isLoggedIn {
            return 0
        }
        if section == DashboardSections.fixedTiles.rawValue {
            return tileModeStatus == .normal && MessagesManager.shared.availableMessage() != nil ?
                Client.providers.tileProvider.fixedTiles.count :
                0
        } else {
            return tileModeStatus == .normal ?
                Client.providers.tileProvider.visibleTiles.count :
                Client.providers.tileProvider.orderedTiles.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tileModeStatus == .normal {
            let cell = collectionView.cellForItem(at: indexPath)
            if let detailedCell = cell as? DetailedTileCell,
                detailedCell.hasDetailView(),
                let segueIdentifier = detailedCell.segueIdentifier() {
                performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if tileModeStatus == .normal,
            let cell = collectionView.cellForItem(at: indexPath) as? DetailedTileCell,
            cell.hasDetailView() {
            UIView.animate(withDuration: 0.1, animations: {
                cell.highlightCell()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if tileModeStatus == .normal,
            let cell = collectionView.cellForItem(at: indexPath) as? DetailedTileCell,
            cell.hasDetailView() {
            UIView.animate(withDuration: 0.1, animations: {
                cell.unhighlightCell()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section == DashboardSections.tiles.rawValue {
            return self.tileModeStatus == .edit
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == DashboardSections.tiles.rawValue, destinationIndexPath.section == DashboardSections.tiles.rawValue {
            var orderedTiles = Client.providers.tileProvider.orderedTiles
            let tile = orderedTiles.remove(at: sourceIndexPath.row)
            orderedTiles.insert(tile, at: destinationIndexPath.row)
            Client.providers.tileProvider.orderedTiles = orderedTiles
            collectionView.reloadData()
        }
    }
}


// MARK: Live Activities

extension DashboardViewController {
    @available(iOS 16.2, *)
    private func makeLiveActivityStateForCurrentConnection() -> PIAConnectionAttributes.ContentState {
        let vpnProvider = Client.providers.vpnProvider
        let currentServer = Client.preferences.displayedServer

        let vpnProtocol = vpnProvider.currentVPNType.vpnProtocol
        
        let state = PIAConnectionAttributes.ContentState(connected: vpnProvider.isVPNConnected, regionName: currentServer.name, regionFlag: "flag-\(currentServer.country.lowercased())", vpnProtocol: vpnProtocol)
        return state
    }

    
    @available(iOS 16.2, *)
    private func startConnectionLiveActivityIfNeeded() {
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let liveActivityManager = appDelegate.liveActivityManager else { return }
        let connState = makeLiveActivityStateForCurrentConnection()
        liveActivityManager.startLiveActivity(with: connState)
    }

    @available(iOS 16.2, *)
    private func stopConnectionLiveActivity() {
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let liveActivityManager = appDelegate.liveActivityManager else { return }
        liveActivityManager.endLiveActivities()
    }
}
