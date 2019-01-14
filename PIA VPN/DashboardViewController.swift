//
//  DashboardViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import SideMenu
import SwiftyBeaver

private let log = SwiftyBeaver.self

class DashboardViewController: AutolayoutViewController {
    
    private enum Cells: Int, EnumsBuilder {
        
        case region = 0
        case quickConnect
        case ipTile
        case subscription

        var identifier: String {
            switch self {
            case .ipTile: return "IPTileCell"
            case .quickConnect: return "QuickConnectTileCell"
            case .region: return "RegionTileCell"
            case .subscription: return "SubscriptionTileCell"
            }
        }
        
        var className: String {
            switch self {
            case .ipTile: return "IPTileCollectionViewCell"
            case .quickConnect: return "QuickConnectTileCollectionViewCell"
            case .region: return "RegionTileCollectionViewCell"
            case .subscription: return "SubscriptionTileCollectionViewCell"
            }
        }
    }
    
    private var viewContentHeight: CGFloat = 0
    @IBOutlet weak var viewContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewContentLandscapeHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var viewContent: UIView!
    @IBOutlet private weak var toggleConnection: PIAConnectionButton!
    
    @IBOutlet private weak var viewRows: UIView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var currentPageIndex = 0
    
    private var currentStatus: VPNStatus = .disconnected

    private var tileModeStatus: TileStatus = .normal {
        didSet {
            collectionView.reloadData()
            self.updateTileLayout()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.itemMenu.image,
            style: .plain,
            target: self,
            action: #selector(openMenu(_:))
        )
        navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Menu.Accessibility.item

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Piax.Global.iconEditTile.image,
            style: .plain,
            target: self,
            action: #selector(updateEditTileStatus(_:))
        )
        navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Menu.Accessibility.Edit.tile

        viewContent.isHidden = true
        viewRows.isHidden = true
        
        currentPageIndex = 0

        SideMenuManager.default.menuLeftNavigationController = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(accountDidLogout(notification:)), name: .PIAAccountDidLogout, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidInstall(notification:)), name: .PIAVPNDidInstall, object: nil)
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        nc.addObserver(self, selector: #selector(viewHasRotated), name: .UIDeviceOrientationDidChange, object: nil)
        nc.addObserver(self, selector: #selector(updateCurrentStatus), name: .PIAThemeDidChange, object: nil)

#if !TARGET_IPHONE_SIMULATOR
        let types: UIUserNotificationType = [.alert, .badge, .sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
#endif

        if Client.providers.accountProvider.isLoggedIn {
            Client.providers.accountProvider.refreshAndLogoutUnauthorized()
        }
        
        self.viewContentHeight = self.viewContentHeightConstraint.constant
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        guard AppPreferences.shared.wasLaunched && !Flags.shared.alwaysShowsWalkthrough else {
            AppPreferences.shared.wasLaunched = true
            showWalkthrough()
            return
        }
        guard Client.providers.accountProvider.isLoggedIn else {
            presentLogin()
            return
        }

        viewContent.isHidden = false
        viewRows.isHidden = false

        // XXX: scale menu item manually
//        UIButton *buttonMenu = [UIButton buttonWithType:UIButtonTypeCustom];
//        const CGFloat itemRatio = 22.0 / 15.0;
//        const CGFloat itemWidth = 17.0;
//        buttonMenu.frame = CGRectMake(0, 0, itemWidth, itemWidth / itemRatio);
//        [buttonMenu setImage:[UIImage imageNamed:@"item-menu"] forState:UIControlStateNormal];
//        [buttonMenu addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonMenu];

        updateCurrentStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        guard Client.providers.accountProvider.isLoggedIn else {
            return
        }
        if Flags.shared.enablesContentBlockerSetting {
            guard AppPreferences.shared.didSeeContentBlocker else {
                AppPreferences.shared.didSeeContentBlocker = true
                let alert = Macros.alert(
                    L10n.Settings.ContentBlocker.title,
                    L10n.Dashboard.ContentBlocker.Intro.message
                )
                alert.addCancelAction(L10n.Global.ok)
                present(alert, animated: true, completion: nil)
                return
            }
        }
    
        if TransientState.shouldDisplayRegionPicker {
            TransientState.shouldDisplayRegionPicker = false
            selectRegion(animated: false)
        }

        // give up pending signup if logged in
        TransientState.didRetryPendingSignup = true
    }
    
    // MARK: Actions
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: Cells.ipTile.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.ipTile.identifier)
        collectionView.register(UINib(nibName: Cells.quickConnect.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.quickConnect.identifier)
        collectionView.register(UINib(nibName: Cells.region.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.region.identifier)
        collectionView.register(UINib(nibName: Cells.subscription.className,
                                      bundle: nil),
                                forCellWithReuseIdentifier: Cells.subscription.identifier)
        collectionView.backgroundColor = .clear
    }
    
    private func updateTileLayout() {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: {
            self.toggleConnection.alpha = self.tileModeStatus == .normal ? 1 : 0
            self.viewContentHeightConstraint.constant = self.tileModeStatus == .normal ? self.viewContentHeight : 0
            self.viewContentLandscapeHeightConstraint.constant = self.tileModeStatus == .normal ? self.viewContentHeight : 0
            self.view.layoutIfNeeded()
        })
        collectionView.reloadData()
    }
    
    private func showWalkthrough() {
        perform(segue: StoryboardSegue.Main.walkthroughSegueIdentifier)
    }
    
    private func presentLogin() {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.shouldRecoverPendingSignup = false//!TransientState.didRetryPendingSignup
        if !TransientState.didRetryPendingSignup {
            TransientState.didRetryPendingSignup = true
        }

        let vc = GetStartedViewController.with(preset: preset, delegate: self)
        present(vc, animated: false, completion: nil)
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
    
    @objc private func openMenu(_ sender: Any?) {
        perform(segue: StoryboardSegue.Main.menuSegueIdentifier)
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
        if !toggleConnection.isOn {
            Client.providers.vpnProvider.connect(nil)
            NotificationCenter.default.post(name: .PIAServerHasBeenUpdated,
                                            object: self,
                                            userInfo: nil)
        } else {
            Client.providers.vpnProvider.disconnect(nil)
        }
    }
    
    @IBAction private func selectRegion(_ sender: Any?) {
        selectRegion(animated: true)
    }
    
    func selectRegion(animated: Bool) {
        let segue = (animated ? StoryboardSegue.Main.selectRegionAnimatedSegueIdentifier : StoryboardSegue.Main.selectRegionSegueIdentifier)
        perform(segue: segue)
    }

    func openSettings() {
        perform(segue: StoryboardSegue.Main.settingsSegueIdentifier)
    }
    
    func openAccount() {
        perform(segue: StoryboardSegue.Main.accountSegueIdentifier)
    }

    func openAbout() {
        perform(segue: StoryboardSegue.Main.aboutSegueIdentifier)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.setEmptyBackButton()

        if let sideMenu = segue.destination as? UISideMenuNavigationController {
            guard let menu = sideMenu.topViewController as? MenuViewController else {
                return
            }
            menu.delegate = self
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
            Client.providers.accountProvider.refreshAndLogoutUnauthorized()
        }
    }
    
    @objc private func viewHasRotated() {
        updateCurrentStatus()
        updateTileLayout()
    }

    @objc private func accountDidLogout(notification: Notification) {
        presentLogin()
    }
    
    // MARK: Notifications (Connection)
    
    @objc private func vpnStatusDidChange(notification: Notification) {
        performSelector(onMainThread: #selector(updateCurrentStatusWithUserInfo(_:)), with: notification.userInfo, waitUntilDone: false)
    }
    
    // MARK: Helpers

    @objc private func updateCurrentStatus() {
        updateCurrentStatusWithUserInfo(nil)
    }
    
    @objc private func updateCurrentStatusWithUserInfo(_ userInfo: [AnyHashable: Any]?) {
        currentStatus = Client.providers.vpnProvider.vpnStatus

        //Theme.current.applyVPNStatus(labelStatus, forStatus: currentStatus)

        switch currentStatus {
        case .connected:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = false
            toggleConnection.stopButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .connected
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle6)
            titleLabelView.text = L10n.Dashboard.Vpn.on.uppercased()
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: .white,
                                                   andBarTintColors: [UIColor.piaGreen,
                                                                      UIColor.piaGreenDark20])
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()

        case .disconnected:
            toggleConnection.isOn = false
            toggleConnection.isIndeterminate = false
            toggleConnection.stopButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .disconnected
            resetNavigationBar()

        case .connecting:
            Macros.postNotification(.PIADaemonsDidUpdateConnectivity)
            toggleConnection.isOn = false
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .connecting
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle7)
            titleLabelView.text = L10n.Dashboard.Vpn.connecting.uppercased()
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()

        case .disconnecting:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = true
            toggleConnection.startButtonAnimation()
            AppPreferences.shared.lastVPNConnectionStatus = .disconnecting
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle7)
            titleLabelView.text = L10n.Dashboard.Vpn.disconnecting.uppercased()

            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()

//        case .changingServer:
//            powerConnection.powerState = .pending
//            labelStatus.text = L10n.Dashboard.Vpn.changingRegion
        }

    }


    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        navigationItem.titleView = NavigationLogoView()
        Theme.current.applySolidLightBackground(view)
        Theme.current.applySolidLightBackground(viewContainer!)
        Theme.current.applySolidLightBackground(viewContent)
        Theme.current.applySolidLightBackground(viewRows)

        Theme.current.applyLightNavigationBar(navigationController!.navigationBar)
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    private func resetNavigationBar() {
        //First reset the green background
        DispatchQueue.main.async {
            Theme.current.applyCustomNavigationBar(self.navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            //Show the PIA logo
            self.navigationItem.titleView = NavigationLogoView()
            if let navController = self.navigationController {
                //Apply the theme background color
                Theme.current.applyLightNavigationBar(navController.navigationBar)
            }
            self.setNeedsStatusBarAppearanceUpdate()
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
        case .account:
            openAccount()
        case .about:
            openAbout()
        case .logout:
            resetNavigationBar()
            presentLogin()
        default:
            fatalError("Unhandled item '\(item)'")
        }
    }
    
    func menu(didDetectTrialUpgrade: MenuViewController) {
        presentPurchaseForTrial()
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 89)
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
        
        let tileIndex = tileModeStatus == .normal ?
            Client.providers.tileProvider.visibleTiles[indexPath.row].rawValue :
            AvailableTiles.allTiles()[indexPath.row].rawValue
        
        let identifier = Cells.objectIdentifyBy(index: tileIndex).identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath)
        if let cell = cell as? EditableTileCell {
            cell.setupCellForStatus(self.tileModeStatus)
        }
        Theme.current.applySolidLightBackground(cell)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tileModeStatus == .normal ?
            Client.providers.tileProvider.visibleTiles.count :
            AvailableTiles.allTiles().count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let detailedCell = cell as? DetailedTileCell,
            detailedCell.hasDetailView(),
            let segueIdentifier = detailedCell.segueIdentifier() {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DetailedTileCell,
            cell.hasDetailView() {
            UIView.animate(withDuration: 0.1, animations: {
                cell.highlightCell()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? DetailedTileCell,
            cell.hasDetailView() {
            UIView.animate(withDuration: 0.1, animations: {
                cell.unhighlightCell()
            })
        }
    }
}
