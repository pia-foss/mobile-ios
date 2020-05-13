//
//  MenuViewController.swift
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
        
        case version
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
            .support,
            .version
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
        .support: L10n.Menu.Item.Web.support,
        .version: Macros.localizedVersionFullString() ?? ""
    ]

    private lazy var iconForItem: [Item: ImageAsset] = [
        .selectRegion: Asset.iconRegion,
        .account: Asset.iconAccount,
        .settings: Asset.iconSettings,
        .logout: Asset.iconLogout,
        .about: Asset.iconAbout,
        .privacy: Asset.iconPrivacy,
        .homepage: Asset.iconHomepage,
        .support: Asset.iconContact,
        .version: Asset.iconAccount
    ]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Theme.current.applySideMenu()

        modalPresentationCapturesStatusBarAppearance = true

        imvAvatar.image = Asset.imageRobot.image

        var planDescription = ""
        if let currentUser = Client.providers.accountProvider.currentUser,
            let info = currentUser.info {
            
            if info.plan == .monthly || info.plan == .yearly || info.plan == .trial {
                
                switch info.plan {
                    case .yearly:
                        planDescription = L10n.Account.Subscriptions.yearly
                    case .monthly:
                        planDescription = L10n.Account.Subscriptions.monthly
                    default:
                        planDescription = L10n.Account.Subscriptions.trial
                }
                
                labelVersion.numberOfLines = 0
                labelVersion.attributedText = Theme.current.smallTextWithColoredLink(
                    withMessage: planDescription + "\n" + L10n.Account.Subscriptions.Short.message,
                    link: L10n.Account.Subscriptions.Short.linkMessage)
                labelVersion.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(openManageSubscription))
                labelVersion.addGestureRecognizer(tap)

            } else {
                labelVersion.text = Macros.localizedVersionFullString()
                allItems[1].removeLast()
            }
        }
        

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(accountDidRefresh(notification:)), name: .PIAAccountDidRefresh, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = Client.providers.accountProvider.currentUser
        labelUsername.text = Client.providers.accountProvider.publicUsername ?? ""
        labelUsername.accessibilityLabel = L10n.Menu.Accessibility.loggedAs(Client.providers.accountProvider.publicUsername ?? "")
    }
    
    override func didRefreshOrientationConstraints() {
        tableView.reloadData()
    }

    // MARK: Actions
    @objc private func openManageSubscription() {
        if let url = URL(string: AppConstants.AppleUrls.subscriptions) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

    }

    private func renewSubscription() {
        log.debug("Account: Fetching renewable products...")
        
        self.showLoadingAnimation()
        
        Client.providers.accountProvider.listRenewablePlans { (plans, error) in
            self.hideLoadingAnimation()
            
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

        guard var uniquePlan = plans.first else {
            fatalError("At least a renewable plan must be available")
        }

        //Now we need to filter if legacy plan or not
        if let currentUser = currentUser,
            let info = currentUser.info,
            let productId = info.productId {
            
            switch productId {
            case AppConstants.InApp.monthlyProductIdentifier,
                 AppConstants.LegacyInApp.monthlySubscriptionProductIdentifier,
                 AppConstants.LegacyInApp.monthlyProductIdentifier,
                 AppConstants.LegacyInApp.oldMonthlyProductIdentifier:
                uniquePlan = .monthly
            case AppConstants.InApp.yearlyProductIdentifier,
                 AppConstants.LegacyInApp.yearlySubscriptionProductIdentifier,
                 AppConstants.LegacyInApp.yearlyProductIdentifier,
                 AppConstants.LegacyInApp.oldYearlyProductIdentifier:
                uniquePlan = .yearly
            default:
                break
            }
            
        }
        
        // TODO: allow users to upgrade from monthly to yearly (plans.count == 2)
        purchaseProductWithPlan(uniquePlan)
    }

    private func handlePlansListingError(_ error: Error?) {
        let errorMessage = error?.localizedDescription ?? L10n.Menu.Renewal.Message.unavailable
        let alert = Macros.alert(
            L10n.Global.error,
            errorMessage
        )
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func handleRenewingTrial() {
        log.error("Account: Cannot renew trial account")

        let alert = Macros.alert(
            L10n.Menu.Renewal.title,
            L10n.Menu.Renewal.Message.trial
        )
        alert.addCancelAction(L10n.Global.cancel)
        alert.addActionWithTitle(L10n.Menu.Renewal.purchase) {
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
        alert.addActionWithTitle(L10n.Menu.Renewal.renew) {
            guard UIApplication.shared.canOpenURL(AppConstants.Web.homeURL) else { return }
            UIApplication.shared.open(AppConstants.Web.homeURL, options: [:], completionHandler: nil)
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func purchaseProductWithPlan(_ plan: Plan) {

        self.showLoadingAnimation()
        Client.providers.accountProvider.purchase(plan: plan) { (transaction, error) in
            self.hideLoadingAnimation()
            
            guard let transaction = transaction else {
                self.handlePurchaseFailureWithError(error)
                return
            }
            
            log.debug("Account: Submitting new payment receipt...")
            
            let request = RenewRequest(transaction: transaction)
            self.showLoadingAnimation()
            
            Client.providers.accountProvider.renew(with: request) { (user, error) in
                self.hideLoadingAnimation()
                
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
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func handleRenewalSuccess() {
        log.debug("Account: Renewal successfully completed")

        let alert = Macros.alert(
            L10n.Renewal.Success.title,
            L10n.Renewal.Success.message
        )
        alert.addDefaultAction(L10n.Global.close)
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
        
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }
    
    private func logOut() {
        let sheet = Macros.alert(
            L10n.Menu.Logout.title,
            L10n.Menu.Logout.message
        )
        sheet.addCancelAction(L10n.Global.cancel)
        sheet.addDestructiveActionWithTitle(L10n.Menu.Logout.confirm) {
            self.dismiss(animated: true) {
                        
                log.debug("Account: Logging out...")

                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let rootNavVC = appDelegate.window?.rootViewController as? UINavigationController,
                    let dashboard = rootNavVC.viewControllers.first as? DashboardViewController {

                    dashboard.showLoadingAnimation()
                    Client.providers.accountProvider.logout({ error in
                        guard let _ = error else {
                            AppPreferences.shared.clean()
                            dashboard.hideLoadingAnimation()
                            return
                        }
                        log.debug("Account: Error logging out the user")
                    })

                } else {
                    
                    Client.providers.accountProvider.logout({ error in
                        guard let _ = error else {
                            AppPreferences.shared.clean()
                            return
                        }
                        log.debug("Account: Error logging out the user")
                    })

                }
                
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

        Theme.current.applyMenuBackground(view)
        Theme.current.applyMenuBackground(viewHeader)
        Theme.current.applyMenuBackground(tableView)
        Theme.current.applyTitle(labelUsername, appearance: .light)
        Theme.current.applyMenuSubtitle(labelVersion)
        tableView.reloadData()
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + allItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if let currentUser = currentUser,
                let info = currentUser.info {
                return info.shouldPresentExpirationAlert ? 1 : 0
            }
            return 0
        } else {
            let sectionItems = allItems[section - 1]
            return sectionItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if let currentUser = currentUser,
                let info = currentUser.info {
                let timeLeft = info.dateComponentsBeforeExpiration
                let cell = tableView.dequeueReusableCell(withIdentifier: Cells.expiration, for: indexPath) as! ExpirationCell
                cell.fill(withTimeLeft: timeLeft)
                return cell
            }
            return UITableViewCell()
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
            if item == .version {
                cell.fillVersion(withTitle: title)
            } else {
                cell.fill(withTitle: title, icon: iconAsset.image)
            }
            switch item {
            case .account:
                cell.accessibilityIdentifier = "uitests.menu.account"

            case .logout:
                cell.accessibilityIdentifier = "uitests.menu.logout"

            default:
                break
            }
            
            let backgroundView = UIView()
            Theme.current.applySecondaryBackground(backgroundView)
            cell.selectedBackgroundView = backgroundView

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
            
            let application = UIApplication.shared
            switch item {
            case .homepage:
                guard application.canOpenURL(AppConstants.Web.homeURL) else { return }
                application.open(AppConstants.Web.homeURL, options: [:], completionHandler: nil)
                return

            case .support:
                guard application.canOpenURL(AppConstants.Web.supportURL) else { return }
                application.open(AppConstants.Web.supportURL, options: [:], completionHandler: nil)
                return

            case .privacy:
                guard application.canOpenURL(AppConstants.Web.privacyURL) else { return }
                application.open(AppConstants.Web.privacyURL, options: [:], completionHandler: nil)
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
