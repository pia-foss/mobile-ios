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
    private struct Cells {
        static let info = "InfoCell"
    }
    
    @IBOutlet private weak var viewContent: UIView!
    
    @IBOutlet private weak var viewConnectionArea: UIView!
    
    @IBOutlet private weak var viewConnection: UIView!

    @IBOutlet private weak var toggleConnection: PIASwitch!
    
    @IBOutlet private weak var labelStatusCaption: UILabel!

    @IBOutlet private weak var labelStatus: UILabel!
    
    @IBOutlet private weak var viewFooterSeparator: UIView!

    @IBOutlet private weak var viewRows: UIView!
    
    @IBOutlet private weak var tableRows: UITableView!
    
    // iPad only

    @IBOutlet private weak var viewPublicIP: UIView!
    
    @IBOutlet private weak var labelPublicIPCaption: UILabel!
    
    @IBOutlet private weak var labelPublicIP: UILabel!
    
    @IBOutlet private weak var activityPublicIP: UIActivityIndicatorView!
    
    @IBOutlet private weak var viewCurrentRegion: UIView!
    
    @IBOutlet private weak var labelRegionCaption: UILabel!
    
    @IBOutlet private weak var labelRegion: UILabel!
    
    @IBOutlet private weak var imvRegion: UIImageView!
    
    @IBOutlet private weak var buttonChangeRegion: UIButton!
    
    @IBOutlet private weak var constraintFooterSeparatorHeight: NSLayoutConstraint!
    
    private var currentPageIndex = 0
    
    private var currentStatus: VPNStatus = .disconnected

    private var currentIP: String?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewContent.isHidden = true
        viewRows.isHidden = true
        
        labelStatusCaption.text = L10n.Dashboard.status
        labelRegionCaption.text = L10n.Dashboard.Connection.Region.caption
        buttonChangeRegion.setTitle(L10n.Dashboard.Connection.Region.change, for: .normal)
        labelPublicIPCaption.text = L10n.Dashboard.Connection.Ip.caption

        currentPageIndex = 0

        toggleConnection.addTarget(self, action: #selector(toggleMoved(_:)), for: .valueChanged)
        buttonChangeRegion.accessibilityIdentifier = "uitests.main.pick_region";

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(accountDidLogout(notification:)), name: .PIAAccountDidLogout, object: nil)
        nc.addObserver(self, selector: #selector(vpnDidInstall(notification:)), name: .PIAVPNDidInstall, object: nil)
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: .PIADaemonsDidUpdateVPNStatus, object: nil)
        nc.addObserver(self, selector: #selector(updateCurrentIP), name: .PIADaemonsDidUpdateConnectivity, object: nil)

#if !TARGET_IPHONE_SIMULATOR
        let types: UIUserNotificationType = [.alert, .badge, .sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
#endif

        if Client.providers.accountProvider.isLoggedIn {
            Client.providers.accountProvider.refreshAndLogoutUnauthorized()
        }
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.itemMenu.image,
            style: .plain,
            target: self,
            action: #selector(openMenu(_:))
        )
        navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Menu.Accessibility.item

        updateCurrentStatus()
        updateCurrentIP()
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
    
    private func showWalkthrough() {
        perform(segue: StoryboardSegue.Main.walkthroughSegueIdentifier)
    }
    
    private func presentLogin() {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.shouldRecoverPendingSignup = false//!TransientState.didRetryPendingSignup
        if !TransientState.didRetryPendingSignup {
            TransientState.didRetryPendingSignup = true
        }

        let vc = PIAWelcomeViewController.with(preset: preset, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    private func presentPurchaseForTrial() {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.pages = .purchase
        preset.allowsCancel = true
        preset.shouldRecoverPendingSignup = false
        preset.isEphemeral = true

        let vc = PIAWelcomeViewController.with(preset: preset, delegate: self)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func openMenu(_ sender: Any?) {
        perform(segue: StoryboardSegue.Main.menuSegueIdentifier)
    }
    
    @objc private func toggleMoved(_ sender: Any?) {
        if toggleConnection.isOn {
            Client.providers.vpnProvider.connect(nil)
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

        Theme.current.applyVPNStatus(labelStatus, forStatus: currentStatus)

        switch currentStatus {
        case .connected:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = false
            labelStatus.text = L10n.Dashboard.Vpn.connected

        case .disconnected:
            toggleConnection.isOn = false
            toggleConnection.isIndeterminate = false
            labelStatus.text = L10n.Dashboard.Vpn.disconnected

        case .connecting:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = true
            labelStatus.text = L10n.Dashboard.Vpn.connecting

        case .disconnecting:
            toggleConnection.isOn = true
            toggleConnection.isIndeterminate = true
            labelStatus.text = L10n.Dashboard.Vpn.disconnecting

//        case .changingServer:
//            powerConnection.powerState = .pending
//            labelStatus.text = L10n.Dashboard.Vpn.changingRegion
        }

        let server = Client.preferences.displayedServer
        labelRegion.text = server.name(forStatus: currentStatus)
        imvRegion.setImage(fromServer: server.flagServer(forStatus: currentStatus))

        // XXX hack to suppress "ellipsis"
        viewConnectionArea.accessibilityLabel = labelStatus.text
        viewConnectionArea.accessibilityLabel = viewConnectionArea.accessibilityLabel?.replacingOccurrences(of: "...", with: "")
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, viewConnectionArea)

        // iPad accessibility wrappers
        if Macros.isDevicePad {
            viewCurrentRegion.accessibilityLabel = "\(labelRegionCaption.text ?? ""), \(labelRegion.text ?? "")"
        }

        // non-iPad bottom table
        tableRows.reloadData()
    }

    @objc private func updateCurrentIP() {
        let vpn = Client.providers.vpnProvider
        if (vpn.vpnStatus == .connected) {
            currentIP = Client.daemons.vpnIP
        } else if (!Client.daemons.isInternetReachable && (vpn.vpnStatus == .disconnected)) {
            currentIP = L10n.Dashboard.Connection.Ip.unreachable
        } else {
            currentIP = Client.daemons.publicIP
        }
        
        // iPad custom bottom view
        self.labelPublicIP.text = self.currentIP;
        if let _ = currentIP {
            activityPublicIP.stopAnimating()
        } else {
            activityPublicIP.startAnimating()
        }

        // iPad accessibility wrappers
        if Macros.isDevicePad {
            viewPublicIP.accessibilityLabel = "\(labelPublicIPCaption.text ?? ""), \(labelPublicIP.text ?? "")"
        }

        // non-iPad bottom table
        tableRows.reloadData()
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyLightNavigationBar(navigationController!.navigationBar)
        Theme.current.applyTitle(labelStatusCaption, appearance: .dark)
        Theme.current.applyCaption(labelPublicIPCaption, appearance: .dark)
        Theme.current.applyTitle(labelPublicIP, appearance: .dark)
        Theme.current.applyCaption(labelRegionCaption, appearance: .dark)
        Theme.current.applyTitle(labelRegion, appearance: .dark)
        Theme.current.applyCaption(buttonChangeRegion, appearance: .emphasis)
        Theme.current.applyTextButton(buttonChangeRegion)
        Theme.current.applyToggle(toggleConnection)

        // XXX: emulate native UITableView separator
        Theme.current.applyDividerToSeparator(tableRows)
        viewFooterSeparator.backgroundColor = tableRows.separatorColor
        constraintFooterSeparatorHeight.constant = 1.0 / UIScreen.main.scale
        tableRows.reloadData()
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
            
        case .logout:
            presentLogin()
            
        default:
            fatalError("Unhandled item '\(item)'")
        }
    }
    
    func menu(didDetectTrialUpgrade: MenuViewController) {
        presentPurchaseForTrial()
    }
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.info, for: indexPath) as! ConnectionInfoCell
        switch indexPath.row {
        case 0:
            let server = Client.preferences.displayedServer
            cell.fill(
                withTitle: L10n.Dashboard.Connection.Region.caption,
                server: server,
                status: currentStatus
            )
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .gray
            cell.accessibilityIdentifier = "uitests.main.pick_region"

        case 1:
            cell.fill(
                withTitle: L10n.Dashboard.Connection.Ip.caption,
                description: currentIP
            )
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
        default:
            fatalError("Unexpected cell row")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        switch (indexPath.row) {
        case 0:
            selectRegion(animated: true)
            
        default:
            break
        }
    }
}

private class NavigationLogoView: UIView {
    private let imvLogo: UIImageView
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override init(frame: CGRect) {
        imvLogo = UIImageView(image: Theme.current.palette.logo)
        super.init(frame: .zero)

        addSubview(imvLogo)

//        backgroundColor = .orange
//        imvLogo.backgroundColor = .green
        imvLogo.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let navBar = navigationBar()
        let imageLogo = imvLogo.image!
        var imageSize = imageLogo.size
//        if !Macros.isDevicePad {
            let logoRatio: CGFloat = imageLogo.size.width / imageLogo.size.height
            imageSize.width = min(imageLogo.size.width, 200.0)
            imageSize.height = imageSize.width / logoRatio
//        }
        
        var logoFrame: CGRect = .zero
        logoFrame.origin.x = -imageSize.width / 2.0
        logoFrame.origin.y = -imageSize.height / 2.0
        logoFrame.size = imageSize
        imvLogo.frame = logoFrame.integral
    }

    private func navigationBar() -> UINavigationBar {
        var parent = superview
        while (parent != nil) {
            if let navBar = parent as? UINavigationBar {
                return navBar
            }
            parent = parent?.superview
        }
        fatalError("Not subview of a UINavigationBar")
    }
}
