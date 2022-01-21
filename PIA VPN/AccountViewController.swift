//
//  AccountViewController.swift
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

class AccountViewController: AutolayoutViewController {
    private enum Secion: Int {
        case uncredited

        case info
    }

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var viewSafe: UIView!
    
    @IBOutlet private weak var labelUsername: UILabel!
    
    @IBOutlet private weak var textUsername: UITextField!
    
    @IBOutlet weak var labelExpiryInformation: UILabel!
        
    @IBOutlet private weak var imageViewTrash: UIImageView!
    
    @IBOutlet private weak var labelDeleteAccount: UILabel!
    
    @IBOutlet private weak var viewAccountInfo: UIView!
    
    @IBOutlet private weak var viewUncredited: UIView!
    
    @IBOutlet private weak var labelRestoreTitle: UILabel!
    
    @IBOutlet private weak var labelRestoreInfo: UILabel!
    
    @IBOutlet private weak var buttonRestore: UIButton!
    
    @IBOutlet private weak var labelSubscriptions: UILabel!

    @IBOutlet weak var labelSubscriptionTopConstraint: NSLayoutConstraint!
    
    private var currentUser: UserAccount?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Menu.Item.account
        labelUsername.text = L10n.Account.Username.caption
        labelRestoreTitle.text = L10n.Account.Restore.title
        labelRestoreInfo.text = L10n.Account.Restore.description
        imageViewTrash.image = Theme.current.trashIconImage()
        buttonRestore.setTitle(L10n.Account.Restore.button.uppercased(), for: .normal)
        labelSubscriptions.attributedText = Theme.current.textWithColoredLink(
            withMessage: L10n.Account.Subscriptions.message,
            link: L10n.Account.Subscriptions.linkMessage)
        labelSubscriptions.isUserInteractionEnabled = true

        viewSafe.layoutMargins = .zero
        textUsername.isUserInteractionEnabled = false

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(redisplayAccount), name: .PIAAccountDidRefresh, object: nil)
        nc.addObserver(self, selector: #selector(viewHasRotated), name: UIDevice.orientationDidChangeNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(openManageSubscription))
        labelSubscriptions.addGestureRecognizer(tap)

        Client.providers.accountProvider.retrieveAccount()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // update local state immediately
        styleNavigationBarWithTitle(L10n.Menu.Item.account)
        redisplayAccount()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        establishUncreditedVisibility()
    }

    @objc private func viewHasRotated() {
        styleNavigationBarWithTitle(L10n.Menu.Item.settings)
    }
    
    // MARK: Actions

    @IBAction private func renewSubscriptionWithUncreditedPurchase(_ sender: Any?) {
        Client.providers.accountProvider.restorePurchases { (error) in
            if let error = error {
                self.handleReceiptFailureWithError(error)
                return
            }
            self.handleReceiptRefresh()
        }
    }
    
    @IBAction private func deleteUserAccount(_ sender: Any?) {
        let sheet = Macros.alert(
            L10n.Account.Delete.Alert.title,
            L10n.Account.Delete.Alert.message
        )
        sheet.addCancelAction(L10n.Global.no)
        sheet.addDestructiveActionWithTitle(L10n.Global.yes) {
            self.dismiss(animated: true) {
                
                var topViewController = UIViewController()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                    let rootNavVC = appDelegate.window?.rootViewController as? UINavigationController,
                    let dashboard = rootNavVC.viewControllers.first as? DashboardViewController {
                    topViewController = dashboard
                }
                
                if let dashboard = topViewController as? DashboardViewController {
                    dashboard.showLoadingAnimation()
                }
                Client.providers.accountProvider.deleteAccount({ error in
                    if error == nil {
                        log.debug("Account: Deleted from Server DB and now Logging out...")
                        Client.providers.accountProvider.logout({ error in
                            guard let _ = error else {
                                AppPreferences.shared.clean()
                                if let dashboard = topViewController as? DashboardViewController {
                                    dashboard.hideLoadingAnimation()
                                }
                                return
                            }
                            log.debug("Account: Error logging out the user")
                        })
                    }
                    log.debug("Account: Logging out and Deleting failed...")
                })
            }
        }
        present(sheet, animated: true, completion: nil)
    }
    
    private func handleReceiptRefresh() {
        log.debug("IAP: Restored payment receipt, redeeming...")

        Client.providers.accountProvider.renew(with: RenewRequest(transaction: nil)) { (user, error) in
            if let clientError = error as? ClientError, (clientError == .badReceipt) {
                self.handleBadReceipt()
                return
            }
            self.handleReceiptSubmissionWithError(error)
        }
    }
        
    private func handleReceiptFailureWithError(_ error: Error?) {
        log.error("IAP: Failed to restore payment receipt (error: \(error?.localizedDescription ?? ""))")

        let alert = Macros.alert(L10n.Global.error, error?.localizedDescription)
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }
    
    private func handleReceiptSubmissionWithError(_ error: Error?) {
        if let error = error {
            let alert = Macros.alert(L10n.Global.error, error.localizedDescription)
            alert.addDefaultAction(L10n.Global.close)
            present(alert, animated: true, completion: nil)
            return
        }

        log.debug("Account: Renewal successfully completed")
        
        let alert = Macros.alert(
            L10n.Renewal.Success.title,
            L10n.Renewal.Success.message
        )
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)

        redisplayAccount()
    }
    
    private func handleBadReceipt() {
        let alert = Macros.alert(
            L10n.Account.Restore.Failure.title,
            L10n.Account.Restore.Failure.message
        )
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    // MARK: Notifications
    @objc private func openManageSubscription() {
        if let url = URL(string: AppConstants.AppleUrls.subscriptions) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

    }
    
    @objc private func redisplayAccount() {
        currentUser = Client.providers.accountProvider.currentUser

        textUsername.text =  Client.providers.accountProvider.publicUsername ?? ""
        
        if let userInfo = currentUser?.info {
            if userInfo.isExpired {
                labelExpiryInformation.text = L10n.Account.ExpiryDate.expired
            } else {
                labelExpiryInformation.text = L10n.Account.ExpiryDate.information(userInfo.humanReadableExpirationDate())
            }
            styleExpirationDate()
            
            if userInfo.plan == .monthly || userInfo.plan == .yearly || userInfo.plan == .trial {
                labelSubscriptions.isHidden = false
                labelSubscriptionTopConstraint.constant = 20
            } else {
                labelSubscriptions.isHidden = true
                labelSubscriptionTopConstraint.constant = 0
            }
        }
        
        establishUncreditedVisibility()
    }
    
    private func establishUncreditedVisibility() {
        if let info = currentUser?.info, info.isRenewable {
            viewUncredited.isHidden = false
        } else {
            viewUncredited.isHidden = true
        }
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        styleNavigationBarWithTitle(L10n.Menu.Item.account)

        if let viewContainer = viewContainer {
            Theme.current.applyPrincipalBackground(view)
            Theme.current.applyPrincipalBackground(viewContainer)
        }
        
        Theme.current.applySecondaryBackground(viewAccountInfo)
        Theme.current.applySubtitle(labelUsername)
        
        Theme.current.applyClearTextfield(textUsername)

        for label in [labelExpiryInformation!] {
            Theme.current.applySubtitle(label)
        }
        Theme.current.applyUnderline(labelDeleteAccount, with: L10n.Account.delete)
        Theme.current.applyTitle(labelRestoreTitle, appearance: .dark)
        Theme.current.applySubtitle(labelRestoreInfo)
        buttonRestore.style(style: TextStyle.textStyle9)

        buttonRestore.style(style: TextStyle.textStyle9)

        styleExpirationDate()
        
    }
    
    private func styleExpirationDate() {
        if let userInfo = currentUser?.info {
            Theme.current.makeSmallLabelToStandOut(labelExpiryInformation,
                                                   withTextToStandOut: userInfo.humanReadableExpirationDate())
        }
    }
}

