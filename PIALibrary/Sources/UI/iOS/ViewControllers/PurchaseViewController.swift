//
//  PurchaseViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class PurchaseViewController: AutolayoutViewController, BrandableNavigationBar, WelcomeChild {
    
    private struct Cells {
        static let plan = "PlanCell"
    }

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    @IBOutlet private weak var collectionPlans: UICollectionView!
    
    @IBOutlet private weak var textAgreement: UITextView!
    
    @IBOutlet private weak var buttonPurchase: PIAButton!
    @IBOutlet private weak var buttonTrialTerms: PIAButton!

    var preset: Preset?
    weak var completionDelegate: WelcomeCompletionDelegate?
    var omitsSiblingLink = false

    private var allPlans: [PurchasePlan] = [.dummy, .dummy]

    private var selectedPlanIndex: Int?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        styleButtons()

        guard let _ = self.preset else {
            fatalError("Preset not propagated")
        }

        collectionPlans.isUserInteractionEnabled = false

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(back(_:))
        )
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back

        labelTitle.text = L10n.Welcome.Purchase.title
        labelSubtitle.text = L10n.Welcome.Purchase.subtitle
        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: L10n.Welcome.Agreement.message,
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(productsDidFetch(notification:)), name: .__InAppDidFetchProducts, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let products = preset?.accountProvider.planProducts {
            refreshPlans(products)
        } else {
            disableInteractions(fully: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == StoryboardSegue.Welcome.confirmPurchaseVPNPlanSegue.rawValue) {
            if let vc = segue.destination as? ConfirmVPNPlanViewController,
                let selectedIndex = selectedPlanIndex {
                vc.preset = preset
                vc.completionDelegate = completionDelegate
                vc.populateViewWith(plans: allPlans,
                                    andSelectedPlanIndex: selectedIndex)
            }
        } else if (segue.identifier == StoryboardSegue.Welcome.showTermsAndConditionsSegue.rawValue) {
            if let vc = segue.destination as? TermsAndConditionsViewController {
                vc.termsAndConditionsTitle = L10n.Welcome.Agreement.Trials.title
                vc.termsAndConditions = L10n.Welcome.Agreement.Trials.message
            }
        }
    }
    
    // MARK: Actions
    
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

            allPlans[0] = purchase
        }
        if let monthly = plans[.monthly] {
            let purchase = PurchasePlan(
                plan: .monthly,
                product: monthly,
                monthlyFactor: 1.0
            )
            purchase.title = L10n.Welcome.Plan.Monthly.title
            purchase.bestValue = false

            allPlans[1] = purchase
        }
        
        collectionPlans.isUserInteractionEnabled = true
        collectionPlans.reloadData()
        if (selectedPlanIndex == nil) {
            selectedPlanIndex = 0
        }
        collectionPlans.selectItem(at: IndexPath(row: selectedPlanIndex!, section: 0), animated: false, scrollPosition: [])
    }
    
    private func disableInteractions(fully: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showLoadingAnimation()
        }
        collectionPlans.isUserInteractionEnabled = false
        if fully {
            parent?.view.isUserInteractionEnabled = false
        }
    }
    
    private func enableInteractions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideLoadingAnimation()
        }
        collectionPlans.isUserInteractionEnabled = true
        parent?.view.isUserInteractionEnabled = true
    }

    // MARK: Notifications
    
    @objc private func productsDidFetch(notification: Notification) {
        let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
        refreshPlans(products)
        enableInteractions()
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(scrollView)
        Theme.current.applyPrincipalBackground(collectionPlans)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelSubtitle)
        Theme.current.applyLinkAttributes(textAgreement)
    }
    
    private func styleButtons() {
        buttonPurchase.setRounded()
        buttonPurchase.style(style: TextStyle.Buttons.piaGreenButton)
        buttonPurchase.setTitle(L10n.Welcome.Purchase.continue.uppercased(),
                              for: [])
        buttonTrialTerms.style(style: TextStyle.Buttons.piaSmallPlainTextButton)
        buttonTrialTerms.setTitle(L10n.Welcome.Agreement.Trials.title,
                                  for: [])
        Theme.current.applyTransparentButton(buttonTrialTerms,
                                             withSize: 0.0)

    }

}

extension PurchaseViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPlans.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let plan = allPlans[indexPath.row]
        let cell = collectionPlans.dequeueReusableCell(withReuseIdentifier: Cells.plan, for: indexPath) as! PurchasePlanCell
        cell.fill(plan: plan)
        cell.isSelected = (indexPath.row == selectedPlanIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlanIndex = indexPath.row
    }
}

extension PurchaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.size.width
        let itemHeight = (collectionView.bounds.size.height - 13) / 2.0
        return CGSize(width: itemWidth,
                      height: itemHeight)
    }
}

extension PurchaseViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}

extension PurchaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //if (textField == textEmail) {
        //    signUp(nil)
        //}
        return true
    }
}
