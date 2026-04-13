//
//  GetStartedViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 26/10/2018.
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

import PIAAssetsMobile
import PIADesignSystem
import PIALibrary
import PIALocalizations
import PIAUIKit
import UIKit

private let log = PIALogger.logger(for: GetStartedViewController.self)

final class GetStartedViewController: PIAWelcomeViewController {

    private struct Cells {
        static let plan = "PlanCell"
    }

    @IBOutlet private weak var scrollBackground: UIImageView!

    private var config: Config!
    private weak var completionDelegate: WelcomeCompletionDelegate?

    private var selectedPlanIndex: Int = 0
    private var plans: [PurchasePlan] = [.dummy, .dummy]

    private var isFetchingProducts = true

    private var signupEmail: String?
    private var signupTransaction: InAppTransaction?
    private var isPurchasing = false

    @IBOutlet private weak var walkthroughTitle: UILabel!
    @IBOutlet private weak var walkthroughDescription: UILabel!

    @IBOutlet private weak var collectionPlans: UICollectionView!
    @IBOutlet private weak var subscribeNowButton: PIAButton!
    @IBOutlet private weak var loginButton: PIAButton!
    @IBOutlet private weak var restorePurchaseButton: UIButton!
    @IBOutlet private weak var textAgreement: UITextView!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavigationBarButtons() {

        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil

    }

    override public func viewDidLoad() {
        assert(config != nil, "Config is not propagated")

        handleInitialStatus()
        setupNavigationBarButtons()
        collectionPlans.isUserInteractionEnabled = false
        collectionPlans.delegate = self
        collectionPlans.dataSource = self

        self.walkthroughTitle.text = L10n.Signup.Walkthrough.Page._2.title
        self.walkthroughDescription.text = L10n.Signup.Walkthrough.Page._2.description + "\n" + L10n.Signup.Purchase.Trials.intro + ". "

        plans = [.dummy, .dummy]

        view.backgroundColor = UIColor.piaGrey1

        let agreement = composeAgreementText(message: L10n.Welcome.Agreement.message(""))

        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: agreement,
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(recoverAccount), name: .PIARecoverAccount, object: nil)
        nc.addObserver(self, selector: #selector(productsDidFetch(notification:)), name: .__InAppDidFetchProducts, object: nil)

        self.styleButtons()

        super.viewDidLoad()

    }

    private func composeAgreementText(message: String) -> String {

        var agreement = message

        if let index = agreement.range(of: "\n\n", options: .backwards)?.upperBound {
            agreement = String(agreement.suffix(from: index))
        }

        return agreement
    }

    // MARK: Actions

    @IBAction func confirmPlan() {
        if selectedPlanIndex < plans.count {
            let plan = plans[selectedPlanIndex]
            self.startPurchaseProcessWithEmail("", andPlan: plan)
        }
    }

    @IBAction private func logInWithReceipt(_ sender: Any?) {
        showLoadingAnimation()

        Client.store.refreshPaymentReceipt { [weak self] error in
            DispatchQueue.main.async {
                guard let receipt = Client.store.paymentReceipt else {
                    self?.hideLoadingAnimation()
                    self?.handleBadReceipt()
                    return
                }

                let request = LoginReceiptRequest(receipt: receipt)
                self?.config.accountProvider.login(with: request) { userAccount, error in
                    self?.hideLoadingAnimation()

                    guard let userAccount else {
                        self?.handleBadReceipt()
                        return
                    }

                    guard let self else { return }
                    self.completionDelegate?.welcomeDidLogin(
                        withUser: userAccount,
                        topViewController: self
                    )
                }
            }
        }
    }

    private func handleBadReceipt() {
        let alert = Macros.alert(
            L10n.Account.Restore.Failure.title,
            L10n.Account.Restore.Failure.message
        )
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func startPurchaseProcessWithEmail(
        _ email: String,
        andPlan plan: PurchasePlan
    ) {
        isPurchasing = true
        disableInteractions()
        self.showLoadingAnimation()

        config.accountProvider.purchase(plan: plan.plan) { [weak self] transaction, error in
            guard let self else { return }
            self.isPurchasing = false
            self.enableInteractions()
            self.hideLoadingAnimation()

            guard let transaction = transaction else {
                if let error = error {
                    let message = error.localizedDescription
                    Macros.displayImageNote(
                        withImage: Asset.iconWarning.image,
                        message: message)
                }
                return
            }
            self.signupEmail = email
            self.signupTransaction = transaction
            self.perform(segue: StoryboardSegue.Welcome.signupViaPurchaseSegue)
        }
    }

    static func with(config: Config, delegate: PIAWelcomeViewControllerDelegate) -> UIViewController? {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()
        guard let vc = nav.topViewController as? GetStartedViewController else {
            log.error("Top view controller is not GetStartedViewController")
            return nil
        }
        vc.config = config
        vc.delegate = delegate
        vc.completionDelegate = vc
        return nav
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if (segue.identifier == StoryboardSegue.Welcome.signupViaPurchaseSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController

            guard let email = signupEmail else {
                log.error("signupEmail is not set in GetStartedViewController")
                return
            }
            var metadata = SignupMetadata(email: email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.config = SignupInProgressViewController.Config(
                metadata: metadata,
                accountProvider: config.accountProvider,
                signupRequest: SignupRequest(email: email, transaction: signupTransaction),
                completionDelegate: completionDelegate,
            )
        }

        guard let vc = segue.destination as? PIAWelcomeViewController else {
            return
        }

        if vc is GetStartedViewController {
            log.debug("GetStarted navigating to GetStarted with segue: \(segue.identifier!)")
        }

        vc.delegate = self.delegate
        vc.preset = self.preset

        switch segue.identifier {
        case StoryboardSegue.Welcome.loginAccountSegue.rawValue:
            vc.preset.pages = .login
        case StoryboardSegue.Welcome.restorePurchaseSegue.rawValue:
            vc.preset.pages = .restore
        default:
            break
        }

    }

    public func handleInitialStatus() {
        if config.accountProvider.planProducts != nil {
            isFetchingProducts = false
        }

        if !isFetchingProducts {
            self.handleVisibilityOfVIews()
        }
    }

    // MARK: Notifications

    @objc private func productsDidFetch(notification: Notification) {
        isFetchingProducts = false
        let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
        DispatchQueue.main.async {
            self.handleVisibilityOfVIews()
            Task { [weak self] in
                await self?.refreshPlans(products)
            }
            self.enableInteractions()
        }
    }

    private func handleVisibilityOfVIews() {
        if !isFetchingProducts {
            if !isPurchasing {
                self.hideLoadingAnimation()
            }

            DispatchQueue.main.async {
                if let products = self.config.accountProvider.planProducts {
                    Task { [weak self] in
                        await self?.refreshPlans(products)
                    }
                }
            }
        }
    }

    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarButtons()

        if let products = config.accountProvider.planProducts {
            Task { [weak self] in
                await self?.refreshPlans(products)
            }
        } else {
            showLoadingAnimation()
            disableInteractions()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigationBarButtons()
    }

    private func styleButtons() {
        loginButton.setRounded()
        subscribeNowButton.setRounded()

        subscribeNowButton.style(style: TextStyle.Buttons.piaGreenButton)
        loginButton.style(style: TextStyle.Buttons.piaPlainTextButton)

        restorePurchaseButton.setTitle(L10n.Account.Restore.button.capitalized, for: [])
        restorePurchaseButton.titleLabel?.numberOfLines = 0
        restorePurchaseButton.titleLabel?.textAlignment = .center

        loginButton.setTitle(L10n.Welcome.Login.submit.uppercased(), for: [])
        loginButton.accessibilityIdentifier = Accessibility.Id.Login.submit

        subscribeNowButton.setTitle(L10n.Signup.Purchase.Subscribe.now.uppercased(), for: [])
    }

    // MARK: Helpers

    private func disableInteractions() {
        self.subscribeNowButton.isEnabled = false
    }

    private func enableInteractions() {
        if !isPurchasing {
            self.subscribeNowButton.isEnabled = true
        }
    }

    public func navigateToLoginView() {
        self.performSegue(
            withIdentifier: StoryboardSegue.Welcome.loginAccountSegue.rawValue,
            sender: nil)
    }

    // MARK: Restylable

    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView(logo: Theme.current.palette.logo)
        Theme.current.applyNavigationBarStyle(to: self)

        Theme.current.applyTitle(walkthroughTitle, appearance: .light)
        Theme.current.applySubtitle(walkthroughDescription)

        Theme.current.applyTransparentButton(loginButton, withSize: 1.0)
        Theme.current.applyButtonLabelMediumStyle(restorePurchaseButton)
        Theme.current.applyScrollableMap(scrollBackground)
        Theme.current.applyLinkAttributes(textAgreement)
    }

    // MARK: Notification event
    @objc private func recoverAccount() {
        self.performSegue(
            withIdentifier: StoryboardSegue.Welcome.restorePurchaseSegue.rawValue,
            sender: nil)
    }

    // MARK: InApp refresh plan
    private func refreshPlans(_ plans: [Plan: InAppProduct]) async {
        if let yearly = plans[.yearly] {
            let purchase = await PurchasePlan(
                plan: .yearly,
                product: yearly,
                monthlyFactor: 12.0
            )

            purchase.title = L10n.Welcome.Plan.Yearly.title
            let currencySymbol = purchase.product.priceLocale.currencySymbol ?? ""
            purchase.detail = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            purchase.bestValue = true
            let price = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            self.plans[0] = purchase

            DispatchQueue.main.async { [weak self] in
                if let label = self?.walkthroughDescription {
                    label.text =
                        if purchase.hasIntroOffer {
                            L10n.Signup.Walkthrough.Page._2.description
                                + "\n"
                                + L10n.Signup.Purchase.Trials.intro
                                + ". "
                                + L10n.Signup.Purchase.Trials.Price.after(price)
                        } else {
                            L10n.Signup.Walkthrough.Page._2.description
                        }
                    Theme.current.makeSmallLabelToStandOut(
                        label,
                        withTextToStandOut: price,
                    )
                }
                let agreement = self?.composeAgreementText(message: L10n.Welcome.Agreement.message(price)) ?? L10n.Welcome.Agreement.message(price)
                if let label = self?.textAgreement {
                    label.attributedText = Theme.current.agreementText(
                        withMessage: agreement,
                        tos: L10n.Welcome.Agreement.Message.tos,
                        tosUrl: Client.configuration.tosUrl,
                        privacy: L10n.Welcome.Agreement.Message.privacy,
                        privacyUrl: Client.configuration.privacyUrl
                    )
                }
            }

        }

        if let monthly = plans[.monthly] {
            let purchase = await PurchasePlan(
                plan: .monthly,
                product: monthly,
                monthlyFactor: 1.0
            )
            purchase.title = L10n.Welcome.Plan.Monthly.title
            purchase.bestValue = false

            self.plans[1] = purchase
        }

        collectionPlans.isUserInteractionEnabled = true
        collectionPlans.reloadData()
        collectionPlans.selectItem(at: IndexPath(row: selectedPlanIndex, section: 0), animated: false, scrollPosition: [])

    }

}

extension GetStartedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let plan = plans[indexPath.row]
        let cell = collectionPlans.dequeueReusableCell(withReuseIdentifier: Cells.plan, for: indexPath) as! PurchasePlanCell
        cell.fill(plan: plan)
        cell.isSelected = (indexPath.row == selectedPlanIndex)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlanIndex = indexPath.row
    }
}

extension GetStartedViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width
        var itemHeight = (collectionView.bounds.size.height - 20) / 2.0

        // Avoids a crash when returning negative numbers in itemHeight
        if itemHeight < 0 {
            itemHeight = 0
        }

        return CGSize(
            width: itemWidth,
            height: itemHeight
        )
    }
}

extension GetStartedViewController {
    struct Config {
        let accountProvider: AccountProvider
    }
}
