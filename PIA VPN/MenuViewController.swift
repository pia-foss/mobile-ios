//
//  MenuViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

protocol MenuViewControllerDelegate: class {
    func menu(_ menu: MenuViewController, didSelect item: MenuViewController.Item)

    func menu(didDetectTrialUpgrade: MenuViewController)
}

class MenuViewController: AutolayoutViewController {
    enum Item: Int {
        case selectRegion

        case account
        
        case settings
        
        case logout
        
        case homepage
        
        case support
        
        case about
        
        case privacy
    }

    private struct Cells {
        static let expiration = "ExpirationCell"

        static let item = "ItemCell"
    }
    
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var viewHeader: UIView!
    
    @IBOutlet private weak var labelUsername: UILabel!

    @IBOutlet private weak var imvAvatar: UIImageView!
    
    @IBOutlet private weak var labelVersion: UILabel!
    
    weak var delegate: MenuViewControllerDelegate?

    private var currentUser: UserAccount?
    
    private lazy var allItems: [[Item]] = [
        [
            .selectRegion,
            .account,
            .settings,
            .logout
        ], [
            .about,
            .privacy,
            .homepage,
            .support
        ]
    ]

    private lazy var stringForItem: [Item: String] = [
        .selectRegion: L10n.Menu.Item.region,
        .account: L10n.Menu.Item.account,
        .settings: L10n.Menu.Item.settings,
        .logout: L10n.Menu.Item.logout,
        .about: L10n.Menu.Item.about,
        .privacy: L10n.Menu.Item.Web.privacy,
        .homepage: L10n.Menu.Item.Web.home,
        .support: L10n.Menu.Item.Web.support
    ]

    private lazy var iconForItem: [Item: ImageAsset] = [
        .selectRegion: Asset.iconRegion,
        .account: Asset.iconAccount,
        .settings: Asset.iconSettings,
        .logout: Asset.iconLogout,
        .about: Asset.iconAbout,
        .privacy: Asset.iconPrivacy,
        .homepage: Asset.iconHomepage,
        .support: Asset.iconContact
    ]
    
    private lazy var segueForItem: [Item: StoryboardSegue.Main] = [
        .account: .accountSegueIdentifier,
        .settings: .settingsSegueIdentifier,
        .about: .aboutSegueIdentifier
    ]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true

        imvAvatar.image = Asset.imageRobot.image
        labelVersion.text = Macros.localizedVersionFullString()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(accountDidRefresh(notification:)), name: .PIAAccountDidRefresh, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        assert(Client.providers.accountProvider.isLoggedIn, "Menu visible while not logged in")

        currentUser = Client.providers.accountProvider.currentUser
        labelUsername.text = currentUser?.credentials.username
        labelUsername.accessibilityLabel = L10n.Menu.Accessibility.loggedAs(currentUser?.credentials.username ?? "")
    }
    
    override func didRefreshOrientationConstraints() {
        tableView.reloadData()
    }

    // MARK: Actions
    
    private func renewSubscription() {
        log.debug("Account: Fetching renewable products...")
        
        let hud = HUD()
        
        Client.providers.accountProvider.listRenewablePlans { (plans, error) in
            hud.hide()
            
            guard let plans = plans else {
                if let clientError = error as? ClientError {
                    switch clientError {
                    case .renewingTrial:
                        self.handleRenewingTrial()
                        return
                        
                    case .renewingNonRenewable:
                        self.handleRenewingNonRenewable()
                        return

                    default:
                        break
                    }
                }
                self.handlePlansListingError(error)
                return
            }
            self.handleRenewablePlans(plans)
        }
    }
    
    private func handleRenewablePlans(_ plans: [Plan]) {
        log.debug("Account: Renewable plans are: \(plans)")

        // TODO: allow users to upgrade from monthly to yearly (plans.count == 2)
        guard let uniquePlan = plans.first else {
            fatalError("At least a renewable plan must be available")
        }
        purchaseProductWithPlan(uniquePlan)
    }

    private func handlePlansListingError(_ error: Error?) {
        let errorMessage = error?.localizedDescription ?? L10n.Menu.Renewal.Message.unavailable
        let alert = Macros.alert(
            L10n.Global.error,
            errorMessage
        )
        alert.addCancelAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func handleRenewingTrial() {
        log.error("Account: Cannot renew trial account")

        let alert = Macros.alert(
            L10n.Menu.Renewal.title,
            L10n.Menu.Renewal.Message.trial
        )
        alert.addCancelAction(L10n.Global.cancel)
        alert.addDefaultAction(L10n.Menu.Renewal.purchase) {
            self.dismiss(animated: true) {
                self.delegate?.menu(didDetectTrialUpgrade: self)
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func handleRenewingNonRenewable() {
        log.error("Account: Account is not renewable")

        // should never happen as the "Renew" button *should* only appear when the account is trial or renewable
        let alert = Macros.alert(
            L10n.Menu.Renewal.title,
            L10n.Menu.Renewal.Message.website
        )
        alert.addCancelAction(L10n.Global.cancel)
        alert.addDefaultAction(L10n.Menu.Renewal.renew) {
            UIApplication.shared.openURL(AppConstants.Web.homeURL)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func purchaseProductWithPlan(_ plan: Plan) {
        let purchaseHud = HUD()
        
        Client.providers.accountProvider.purchase(plan: plan) { (transaction, error) in
            purchaseHud.hide()
            
            guard let transaction = transaction else {
                self.handlePurchaseFailureWithError(error)
                return
            }
            
            log.debug("Account: Submitting new payment receipt...")
            
            let request = RenewRequest(transaction: transaction)
            let renewHud = HUD()
            
            Client.providers.accountProvider.renew(with: request) { (user, error) in
                renewHud.hide()
                
                guard let _ = user else {
                    self.handleRenewalFailureWithError(error)
                    return
                }
                self.handleRenewalSuccess()
            }
        }
    }
    
    private func handlePurchaseFailureWithError(_ error: Error?) {
        guard let error = error else {
            log.warning("IAP: Purchase cancelled")
            return
        }

        log.error("IAP: Purchase failed (error: \(error)")

        let alert = Macros.alert(L10n.Global.error, error.localizedDescription)
        alert.addCancelAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func handleRenewalSuccess() {
        log.debug("Account: Renewal successfully completed")

        let alert = Macros.alert(
            L10n.Renewal.Success.title,
            L10n.Renewal.Success.message
        )
        alert.addCancelAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func handleRenewalFailureWithError(_ error: Error?) {
        if let error = error {
            log.error("Account: Failed to submit renewal receipt (error: \(error.localizedDescription))")
        } else {
            log.error("Account: Failed to submit renewal receipt")
        }

        let alert = Macros.alert(
            L10n.Global.error,
            L10n.Renewal.Failure.message
        )
        alert.addCancelAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }
    
    private func logOut() {
        let sheet = Macros.alert(
            L10n.Menu.Logout.title,
            L10n.Menu.Logout.message
        )
        sheet.addCancelAction(L10n.Global.cancel)
        sheet.addDestructiveAction(L10n.Menu.Logout.confirm) {
            self.dismiss(animated: true) {
                log.debug("Account: Logging out...")
                
                Client.providers.accountProvider.logout(nil)
            }
        }
        present(sheet, animated: true, completion: nil)
    }

    // MARK: Notifications

    @objc private func accountDidRefresh(notification: Notification) {
        currentUser = Client.providers.accountProvider.currentUser
        tableView.reloadData()
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        Theme.current.applyBrandBackground(view)
        Theme.current.applyBrandBackground(viewHeader)
        Theme.current.applySolidLightBackground(tableView)
        Theme.current.applyTitle(labelUsername, appearance: .light)
        Theme.current.applyCaption(labelVersion, appearance: .light)
        tableView.reloadData()
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + allItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return ((currentUser?.info?.shouldPresentExpirationAlert ?? false) ? 1 : 0)
        } else {
            let sectionItems = allItems[section - 1]
            return sectionItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let timeLeft = currentUser?.info?.dateComponentsBeforeExpiration ?? DateComponents()
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.expiration, for: indexPath) as! ExpirationCell
            cell.fill(withTimeLeft: timeLeft)
            return cell
        }
        else {
            let sectionItems = allItems[indexPath.section - 1]
            let item = sectionItems[indexPath.row]
    
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.item, for: indexPath) as! MenuItemCell
            guard let title = stringForItem[item] else {
                fatalError("Item '\(item)' has no mapped string in stringForItem")
            }
            guard let iconAsset = iconForItem[item] else {
                fatalError("Item '\(item)' has no mapped icon in iconForItem")
            }
            cell.fill(withTitle: title, icon: iconAsset.image)
            switch item {
            case .account:
                cell.accessibilityIdentifier = "uitests.menu.account"

            case .logout:
                cell.accessibilityIdentifier = "uitests.menu.logout"

            default:
                break
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.0
        } else {
            return 0.5
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let backgroundView = (view as? UITableViewHeaderFooterView)?.backgroundView else {
            return
        }
        Theme.current.applyDivider(backgroundView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            renewSubscription()
        } else {
            let sectionItems = allItems[indexPath.section - 1]
            let item = sectionItems[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            guard (item != .logout) else {
                logOut()
                return
            }

            if let segue = segueForItem[item] {
                perform(segue: segue)
                return
            }
            
            let application = UIApplication.shared
            switch item {
            case .homepage:
                application.openURL(AppConstants.Web.homeURL)
                return

            case .support:
                application.openURL(AppConstants.Web.supportURL)
                return

            case .privacy:
                application.openURL(AppConstants.Web.privacyURL)
                return

            default:
                break
            }

            dismiss(animated: true) {
                self.delegate?.menu(self, didSelect: item)
            }
        }
    }
}
