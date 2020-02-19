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

public class GetStartedViewController: AutolayoutViewController, ConfigurationAccess {

    private static let smallDeviceMaxViewHeight: CGFloat = 520
    private static let maxViewHeight: CGFloat = 500
    private static let extraViewButtonsHeight: CGFloat = 48
    private static let defaultViewHeight: CGFloat = 276
        
    @IBOutlet private weak var spinner: UIActivityIndicatorView!

    @IBOutlet private weak var imvLogo: UIImageView!
    
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
    
    private var allPlans: [PurchasePlan] = [.dummy, .dummy]
    private var selectedPlanIndex: Int?

    var preset = Preset()
    private weak var delegate: PIAWelcomeViewControllerDelegate?

    @IBOutlet private weak var buttonViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet private weak var hiddenButtonsConstraintHeight: NSLayoutConstraint!

    private var buttonViewIsExpanded = false {
        didSet {
            self.updateButtonView()
        }
    }
    
    private lazy var allData: [WalkthroughPageView.PageData] = [
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._1.title,
            detail: L10n.Signup.Walkthrough.Page._1.description,
            image: Asset.imageWalkthrough1.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._2.title,
            detail: L10n.Signup.Walkthrough.Page._2.description,
            image: Asset.imageWalkthrough2.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Signup.Walkthrough.Page._3.title,
            detail: L10n.Signup.Walkthrough.Page._3.description,
            image: Asset.imageWalkthrough3.image
        )
    ]

    private var currentPageIndex = 0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override public func viewDidLoad() {
        
        subscribeNowTitle.text = L10n.Signup.Purchase.Trials.intro
        subscribeNowDescription.text = L10n.Signup.Purchase.Trials.Price.after("")

        view.backgroundColor = UIColor.piaGrey1

        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: L10n.Welcome.Agreement.message(""),
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(recoverAccount), name: .PIARecoverAccount, object: nil)
        nc.addObserver(self, selector: #selector(productsDidFetch(notification:)), name: .__InAppDidFetchProducts, object: nil)

        self.styleButtons()
        
        addPages()
        pageControl.numberOfPages = allData.count
        
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = 15
        visualEffectView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)

        super.viewDidLoad()

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
    
    @IBAction private func scrollPage(_ sender: UIPageControl) {
        scrollToPage(sender.currentPage, animated: true)
    }
    
    /**
     Creates a wrapped `GetStartedViewController` ready for presentation.
     
     - Parameter preset: The optional `Preset` to configure this controller with
     - Parameter delegate: The `PIAWelcomeViewControllerDelegate` to handle raised events
     */
    public static func with(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()
        let vc = nav.topViewController as! GetStartedViewController
        if let customPreset = preset {
            vc.preset = customPreset
        }
        vc.delegate = delegate
        return nav
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
        
        guard let vc = segue.destination as? PIAWelcomeViewController else {
            return
        }
        
        vc.delegate = self.delegate
        vc.preset = self.preset

        switch segue.identifier  {
        case StoryboardSegue.Welcome.purchaseVPNPlanSegue.rawValue:
            vc.preset.pages = .purchase
        case StoryboardSegue.Welcome.subscribeNowVPNPlanSegue.rawValue:
            vc.preset.pages = .directPurchase
            vc.allPlans = allPlans
            vc.selectedPlanIndex = 0
        case StoryboardSegue.Welcome.loginAccountSegue.rawValue:
            vc.preset.pages = .login
        case StoryboardSegue.Welcome.restorePurchaseSegue.rawValue:
            vc.preset.pages = .restore
        default:
            break
        }
        
    }
    
    // MARK: Orientation
    @objc func onlyPortrait() -> Void {}
    
    // MARK: Notifications
    
    @objc private func productsDidFetch(notification: Notification) {
        let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
        DispatchQueue.main.async {
            self.refreshPlans(products)
            self.enableInteractions()
        }
    }

    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        if let products = preset.accountProvider.planProducts {
            refreshPlans(products)
        } else {
            disableInteractions(fully: false)
        }
    }
    
    private func styleButtons() {
        loginButton.setRounded()
        subscribeNowButton.setRounded()

        subscribeNowButton.style(style: TextStyle.Buttons.piaGreenButton)
        loginButton.style(style: TextStyle.Buttons.piaPlainTextButton)

        loginButton.setTitle(L10n.Welcome.Login.submit.uppercased(),
                             for: [])
        buyButton.setTitle(L10n.Signup.Purchase.Trials.All.plans,
                           for: [])
        subscribeNowButton.setTitle(L10n.Signup.Purchase.Subscribe.now.uppercased(),
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
        self.spinner.startAnimating()
    }

    private func enableInteractions() {
        self.subscribeNowButton.isEnabled = true
        self.spinner.stopAnimating()
    }
    

    // MARK: Onboarding walkthrough

    private func addPages() {
        let parent = viewContent!
        var constraints: [NSLayoutConstraint] = []
        var previousPage: UIView?
        
        for (i, data) in allData.enumerated() {
            let page = WalkthroughPageView(data: data)
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
        Theme.current.applySubtitle(subscribeNowDescription)
        Theme.current.applyTitle(subscribeNowTitle, appearance: .light)

        Theme.current.applyTransparentButton(loginButton,
                                             withSize: 1.0)
        Theme.current.applyButtonLabelMediumStyle(buyButton)
        Theme.current.applyScrollableMap(scrollBackground)
        Theme.current.applyPageControl(pageControl)
        Theme.current.applyLinkAttributes(textAgreement)
        Theme.current.applyActivityIndicator(spinner)
        imvLogo.image = Theme.current.palette.logo

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

            DispatchQueue.main.async { [weak self] in
                if let label = self?.subscribeNowDescription {
                    label.text = L10n.Signup.Purchase.Trials.Price.after(price)
                    Theme.current.makeSmallLabelToStandOut(label,
                                                           withTextToStandOut: price)
                }
                if let label = self?.textAgreement {
                    label.attributedText = Theme.current.agreementText(
                        withMessage: L10n.Welcome.Agreement.message(price),
                        tos: L10n.Welcome.Agreement.Message.tos,
                        tosUrl: Client.configuration.tosUrl,
                        privacy: L10n.Welcome.Agreement.Message.privacy,
                        privacyUrl: Client.configuration.privacyUrl
                    )
                }

            }
            allPlans[0] = purchase
            selectedPlanIndex = 0
        }
    }

}

extension GetStartedViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageControl.currentPage = currentPageIndex
        updateButtonsToCurrentPage()
    }
}
