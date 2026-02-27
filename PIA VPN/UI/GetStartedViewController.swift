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

import UIKit
import PIALibrary
import PIADesignSystem
import PIAUIKit

private let log = PIALogger.logger(for: GetStartedViewController.self)

public class GetStartedViewController: PIAWelcomeViewController {

    private struct Cells {
        static let plan = "PlanCell"
    }
    
    private static let smallDeviceMaxViewHeight: CGFloat = 520
    private static let maxViewHeight: CGFloat = 500
    private static let extraViewButtonsHeight: CGFloat = 48
    private static let defaultViewHeight: CGFloat = 276
        
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    @IBOutlet private weak var loginButton: PIAButton!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var subscribeNowButton: PIAButton!
    @IBOutlet private weak var subscribeNowTitle: UILabel!
    @IBOutlet private weak var subscribeNowDescription: UILabel!

    @IBOutlet private weak var scrollContent: UIScrollView!
    @IBOutlet private weak var scrollBackground: UIImageView!
    @IBOutlet private weak var viewContent: UIView!
    @IBOutlet private weak var pageControl: PIAPageControl!
    @IBOutlet weak var hiddenButtonsView: UIView!
    
    @IBOutlet private weak var textAgreement: UITextView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    private var isFetchingProducts = true
    private var isFetchingFF = true
    
    private var signupEmail: String?
    private var signupTransaction: InAppTransaction?
    private var isPurchasing = false
    private var isNewFlow = false

    weak var completionDelegate: WelcomeCompletionDelegate?

    @IBOutlet private weak var buttonViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet private weak var hiddenButtonsConstraintHeight: NSLayoutConstraint!

    //New flow
    var allNewPlans: [PurchasePlan] = [.dummy, .dummy]

    @IBOutlet private weak var containerNewFlow: UIView!
    @IBOutlet private weak var walkthroughImage: UIImageView!
    @IBOutlet private weak var walkthroughTitle: UILabel!
    @IBOutlet private weak var walkthroughDescription: UILabel!
    
    @IBOutlet private weak var collectionPlans: UICollectionView!
    @IBOutlet private weak var newSubscribeNowButton: PIAButton!
    @IBOutlet private weak var newLoginButton: PIAButton!
    @IBOutlet private weak var restorePurchaseButton: UIButton!
    @IBOutlet private weak var newTextAgreement: UITextView!

    private var buttonViewIsExpanded = false {
        didSet {
            self.updateButtonView()
        }
    }
    
    private lazy var allData: [WalkthroughPageView.PageData] = [
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._1.title,
            detail: L10n.Signup.Walkthrough.Page._1.description,
            image: Asset.Ui.imageWalkthrough1.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._2.title,
            detail: L10n.Signup.Walkthrough.Page._2.description,
            image: Asset.Ui.imageWalkthrough2.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._3.title,
            detail: L10n.Signup.Walkthrough.Page._3.description,
            image: Asset.Ui.imageWalkthrough3.image
        )
    ]
    
    private var tutorialViews: [WalkthroughPageView] = []

    private var currentPageIndex = 0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBarButtons() {
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil

    }
    
    override public func viewDidLoad() {
        
        handleInitialStatus()
        setupNavigationBarButtons()
        self.containerNewFlow.isHidden = true
        self.visualEffectView.isHidden = true
        self.pageControl.isHidden = true
        collectionPlans.isUserInteractionEnabled = false
        collectionPlans.delegate = self
        collectionPlans.dataSource = self

        self.walkthroughTitle.text = L10n.Signup.Walkthrough.Page._2.title
        self.walkthroughDescription.text = L10n.Signup.Walkthrough.Page._2.description + "\n" + L10n.Signup.Purchase.Trials.intro + ". "

        allNewPlans = [.dummy, .dummy]
        completionDelegate = self

        view.backgroundColor = UIColor.piaGrey1

        let agreement = composeAgreementText(message: L10n.Welcome.Agreement.message(""))
        
        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: agreement,
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )
        newTextAgreement.attributedText = Theme.current.agreementText(
            withMessage: agreement,
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )


        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(recoverAccount), name: .PIARecoverAccount, object: nil)
        nc.addObserver(self, selector: #selector(productsDidFetch(notification:)), name: .__InAppDidFetchProducts, object: nil)
        nc.addObserver(self, selector: #selector(featureFlagsDidFetch(notification:)), name: .__AppDidFetchFeatureFlags, object: nil)

        self.styleButtons()
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = 15
        visualEffectView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        fireTimeoutForFeatureFlags()
        
        super.viewDidLoad()

    }
    
    private func composeAgreementText(message: String) -> String {
        
        var agreement = message
        
        if isNewFlow,
           let index = agreement.range(of: "\n\n", options: .backwards)?.upperBound {
            agreement = String(agreement.suffix(from: index))
        }
        
        return agreement
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.down:
                buttonViewIsExpanded = false
            case UISwipeGestureRecognizer.Direction.up:
                buttonViewIsExpanded = true
            default:
                break
            }
        }

    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.scrollToPage(self.currentPageIndex, animated: false, force: true, width: size.width)
        }, completion: nil)
    }

    // MARK: Actions
    @IBAction func confirmPlan() {
        
        if let index = selectedPlanIndex {
            let plan = allNewPlans[index]
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
                self?.preset.accountProvider.login( with: request, { userAccount, error in
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
                })
            }
        }
    }

    private func handleBadReceipt() {
        let alert = Macros.alert(
            L10n.Localizable.Account.Restore.Failure.title,
            L10n.Localizable.Account.Restore.Failure.message
        )
        alert.addDefaultAction(L10n.Localizable.Global.close)
        present(alert, animated: true, completion: nil)
    }

    private func startPurchaseProcessWithEmail(
        _ email: String,
        andPlan plan: PurchasePlan
    ) {
        isPurchasing = true
        disableInteractions(fully: true)
        self.showLoadingAnimation()
        
        preset.accountProvider.purchase(plan: plan.plan) { (transaction, error) in
            self.isPurchasing = false
            self.enableInteractions()
            self.hideLoadingAnimation()
            
            guard let transaction = transaction else {
                if let error = error {
                    let message = error.localizedDescription
                    Macros.displayImageNote(withImage: Asset.Images.iconWarning.image,
                                            message: message)
                }
                return
            }
            self.signupEmail = email
            self.signupTransaction = transaction
            self.perform(segue: StoryboardSegue.Welcome.signupViaPurchaseSegue)
        }
        
    }

    
    @IBAction private func scrollPage(_ sender: UIPageControl) {
        scrollToPage(sender.currentPage, animated: true)
    }
    
    public static func withPurchase(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        if let vc = StoryboardScene.Welcome.storyboard.instantiateViewController(withIdentifier: "PIAWelcomeViewController") as? PIAWelcomeViewController {
            if let customPreset = preset {
                vc.preset = customPreset
            }
            vc.delegate = delegate
            let navigationController = UINavigationController(rootViewController: vc)
            return navigationController
        }
        return UIViewController()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
            vc.metadata = metadata
            vc.signupRequest = SignupRequest(email: email, transaction: signupTransaction)
            vc.preset = preset
            vc.completionDelegate = completionDelegate
        }
        
        guard let vc = segue.destination as? PIAWelcomeViewController else {
            return
        }
        
        vc.delegate = self.delegate
        vc.preset = self.preset

        switch segue.identifier  {
        case StoryboardSegue.Welcome.purchaseVPNPlanSegue.rawValue:
            vc.preset.pages = .purchase
        case StoryboardSegue.Welcome.loginAccountSegue.rawValue:
            vc.preset.pages = .login
        case StoryboardSegue.Welcome.restorePurchaseSegue.rawValue:
            vc.preset.pages = .restore
        default:
            break
        }
                
    }
    
    public func handleInitialStatus() {
        
        if Client.configuration.featureFlags.contains(Client.FeatureFlags.showNewInitialScreen) {
            isFetchingFF = false
            isNewFlow = true
        }
        
        if let _ = preset.accountProvider.planProducts {
            isFetchingProducts = false
        }
        
        if !isFetchingProducts && !isFetchingProducts {
            self.handleVisibilityOfVIews()
        }

    }
    
    // MARK: Notifications
    
    @objc private func productsDidFetch(notification: Notification) {
        isFetchingProducts = false
        let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
        DispatchQueue.main.async {
            self.handleVisibilityOfVIews()
            self.refreshPlans(products)
            self.enableInteractions()
        }
    }
    
    @objc private func featureFlagsDidFetch(notification: Notification) {
        isFetchingFF = false
        self.isNewFlow = Client.configuration.featureFlags.contains(Client.FeatureFlags.showNewInitialScreen)
        self.handleVisibilityOfVIews()
    }
    
    private func handleVisibilityOfVIews() {
        if !isFetchingFF && !isFetchingProducts {
            if !isPurchasing {
                self.hideLoadingAnimation()
            }
            
            DispatchQueue.main.async {
                
                self.containerNewFlow.isHidden = !self.isNewFlow
                self.scrollContent.isHidden = self.isNewFlow
                
                if self.isNewFlow {
                    if let products = self.preset.accountProvider.planProducts {
                        self.refreshPlans(products)
                    }
                } else {
                    self.visualEffectView.isHidden = false
                    self.pageControl.isHidden = false

                    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
                    swipeDown.direction = UISwipeGestureRecognizer.Direction.down
                    self.view.addGestureRecognizer(swipeDown)

                    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
                    swipeUp.direction = UISwipeGestureRecognizer.Direction.up
                    self.view.addGestureRecognizer(swipeUp)
                    
                    self.subscribeNowTitle.text = L10n.Signup.Purchase.Trials.intro
                }
                self.addPages()
                self.pageControl.numberOfPages = self.allData.count
            }

        }
        
    }

    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarButtons()

        if let products = preset.accountProvider.planProducts {
            refreshPlans(products)
        } else {
            showLoadingAnimation()
            disableInteractions(fully: false)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavigationBarButtons()
    }
    
    private func styleButtons() {
        loginButton.setRounded()
        subscribeNowButton.setRounded()
        newLoginButton.setRounded()
        newSubscribeNowButton.setRounded()

        subscribeNowButton.style(style: TextStyle.Buttons.piaGreenButton)
        loginButton.style(style: TextStyle.Buttons.piaPlainTextButton)
        newSubscribeNowButton.style(style: TextStyle.Buttons.piaGreenButton)
        newLoginButton.style(style: TextStyle.Buttons.piaPlainTextButton)

        restorePurchaseButton.setTitle(L10n.Localizable.Account.Restore.button.capitalized, for: [])
        restorePurchaseButton.titleLabel?.numberOfLines = 0
        restorePurchaseButton.titleLabel?.textAlignment = .center

        loginButton.setTitle(L10n.Welcome.Login.submit.uppercased(),
                             for: [])
        newLoginButton.setTitle(L10n.Welcome.Login.submit.uppercased(),
                             for: [])
        
        loginButton.accessibilityIdentifier = Accessibility.Id.Login.submit
        newLoginButton.accessibilityIdentifier = Accessibility.Id.Login.submitNew
        
        buyButton.setTitle(L10n.Signup.Purchase.Trials.All.plans,
                           for: [])
        subscribeNowButton.setTitle(L10n.Signup.Purchase.Subscribe.now.uppercased(),
                           for: [])
        newSubscribeNowButton.setTitle(L10n.Signup.Purchase.Subscribe.now.uppercased(),
                           for: [])
    }
    
    // MARK: Helpers
    
    private func updateButtonView() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.buttonViewIsExpanded {

                var maxViewHeight: CGFloat = GetStartedViewController.maxViewHeight
                switch UIDevice().type {
                    case .iPhoneSE, .iPhone5, .iPhone5S:
                        maxViewHeight = GetStartedViewController.smallDeviceMaxViewHeight
                    default: break
                }

                self.buttonViewConstraintHeight.constant = maxViewHeight
                self.hiddenButtonsConstraintHeight.constant = GetStartedViewController.extraViewButtonsHeight
                self.hiddenButtonsView.alpha = 1
            } else {
                self.buttonViewConstraintHeight.constant = GetStartedViewController.defaultViewHeight
                self.hiddenButtonsConstraintHeight.constant = 0
                self.hiddenButtonsView.alpha = 0
            }
            self.view.layoutIfNeeded()
            self.visualEffectView.layoutIfNeeded()
        })
    }

    private func disableInteractions(fully: Bool) {
        self.subscribeNowButton.isEnabled = false
        self.buyButton.isEnabled = false
        self.spinner.startAnimating()
    }

    private func enableInteractions() {
        if !isPurchasing { //dont reenable the screen if we are still purchasing
            self.subscribeNowButton.isEnabled = true
            self.buyButton.isEnabled = true
            self.spinner.stopAnimating()
        }
    }
    
    private func fireTimeoutForFeatureFlags() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Cancel the FF request
            if self.isFetchingFF {
                NotificationCenter.default.removeObserver(self, name: .__AppDidFetchFeatureFlags, object: nil)
                self.isFetchingFF = false
                self.isNewFlow = false
                self.handleVisibilityOfVIews()
            }
        }
    }
    public func navigateToLoginView() {
        self.performSegue(withIdentifier: StoryboardSegue.Welcome.loginAccountSegue.rawValue,
                          sender: nil)
    }
    
    // MARK: Onboarding walkthrough

    private func addPages() {
        let parent = viewContent!
        var constraints: [NSLayoutConstraint] = []
        var previousPage: UIView?
        
        for (i, data) in allData.enumerated() {
            let page = WalkthroughPageView(data: data)
            tutorialViews.append(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(page)
            
            // size
            constraints.append(page.widthAnchor.constraint(equalTo: scrollContent.widthAnchor))
            constraints.append(page.centerYAnchor.constraint(equalTo: parent.centerYAnchor))
            constraints.append(page.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor, constant: 20.0))
            constraints.append(page.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor, constant: -20.0))
            
            // left
            if let previousPage = previousPage {
                constraints.append(page.leftAnchor.constraint(equalTo: previousPage.rightAnchor))
            } else {
                constraints.append(page.leftAnchor.constraint(equalTo: parent.leftAnchor))
            }
            
            // right
            if (i == allData.count - 1) {
                constraints.append(page.rightAnchor.constraint(equalTo: parent.rightAnchor))
            }
            
            previousPage = page
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func scrollToPage(_ pageIndex: Int, animated: Bool) {
        scrollToPage(pageIndex, animated: animated, force: false, width: scrollContent.frame.size.width)
    }
    
    private func scrollToPage(_ pageIndex: Int, animated: Bool, force: Bool, width: CGFloat) {
        guard (force || (pageIndex != currentPageIndex)) else {
            return
        }
        currentPageIndex = pageIndex
        scrollContent.setContentOffset(CGPoint(x: CGFloat(pageIndex * Int(width)), y: 0), animated: animated)
        pageControl.currentPage = pageIndex
        updateButtonsToCurrentPage()
    }
    
    private func updateButtonsToCurrentPage() {
        guard (currentPageIndex < allData.count - 1) else {
            return
        }
    }

    
    // MARK: Restylable
    
    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView(logo: Theme.current.palette.logo)
        Theme.current.applyNavigationBarStyle(to: self)

        Theme.current.applyTitle(subscribeNowDescription, appearance: .light)
        Theme.current.applySubtitle(subscribeNowTitle)
        Theme.current.applyTitle(walkthroughTitle, appearance: .light)
        Theme.current.applySubtitle(walkthroughDescription)

        Theme.current.applyTransparentButton(loginButton, withSize: 1.0)
        Theme.current.applyTransparentButton(newLoginButton, withSize: 1.0)
        Theme.current.applyButtonLabelMediumStyle(restorePurchaseButton)
        Theme.current.applyButtonLabelMediumStyle(buyButton)
        Theme.current.applyScrollableMap(scrollBackground)
        Theme.current.applyPageControl(pageControl)
        Theme.current.applyLinkAttributes(textAgreement)
        Theme.current.applyLinkAttributes(newTextAgreement)
        Theme.current.applyActivityIndicator(spinner)
        tutorialViews.forEach({
            $0.applyStyles()
        })

    }

    // MARK: Notification event
    @objc private func recoverAccount() {
        self.performSegue(withIdentifier: StoryboardSegue.Welcome.restorePurchaseSegue.rawValue,
                          sender: nil)
    }
    
    // MARK: InApp refresh plan
    private func refreshPlans(_ plans: [Plan: InAppProduct]) {
        if let yearly = plans[.yearly] {
            let purchase = PurchasePlan(
                plan: .yearly,
                product: yearly,
                monthlyFactor: 12.0
            )
            
            purchase.title = L10n.Welcome.Plan.Yearly.title
            let currencySymbol = purchase.product.priceLocale.currencySymbol ?? ""
            purchase.detail = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            purchase.bestValue = true
            let price = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            allNewPlans[0] = purchase

            DispatchQueue.main.async { [weak self] in
                if let label = self?.subscribeNowDescription {
                    label.text = L10n.Signup.Purchase.Trials.Price.after(price)
                    Theme.current.makeSmallLabelToStandOut(label,
                                                           withTextToStandOut: price)
                }
                if let label = self?.walkthroughDescription {
                    label.text = L10n.Signup.Walkthrough.Page._2.description + "\n" + L10n.Signup.Purchase.Trials.intro + ". " + L10n.Signup.Purchase.Trials.Price.after(price)
                    Theme.current.makeSmallLabelToStandOut(label,
                                                           withTextToStandOut: price)
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
                if let label = self?.newTextAgreement {
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
            let purchase = PurchasePlan(
                plan: .monthly,
                product: monthly,
                monthlyFactor: 1.0
            )
            purchase.title = L10n.Welcome.Plan.Monthly.title
            purchase.bestValue = false

            allNewPlans[1] = purchase
        }
        
        collectionPlans.isUserInteractionEnabled = true
        collectionPlans.reloadData()
        if (selectedPlanIndex == nil) {
            selectedPlanIndex = 0
        }
        collectionPlans.selectItem(at: IndexPath(row: selectedPlanIndex!, section: 0), animated: false, scrollPosition: [])

    }

}

extension GetStartedViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageControl.currentPage = currentPageIndex
        updateButtonsToCurrentPage()
    }
}

extension GetStartedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allNewPlans.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let plan = allNewPlans[indexPath.row]
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
