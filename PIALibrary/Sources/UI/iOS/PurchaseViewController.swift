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

class PurchaseViewController: AutolayoutViewController, WelcomeChild {
    private struct Cells {
        static let plan = "PlanCell"
    }

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var textEmail: BorderedTextField!
    
    @IBOutlet private weak var collectionPlans: UICollectionView!
    
    @IBOutlet private weak var buttonPurchase: ActivityButton!
    
    @IBOutlet private weak var viewFooter: UIView!
    
    @IBOutlet private weak var viewLogin: UIView!
    
    @IBOutlet private weak var labelLogin1: UILabel!
    
    @IBOutlet private weak var labelLogin2: UILabel!
    
    var preset: PIAWelcomeViewController.Preset?
    
    var omitsSiblingLink = false
    
    weak var completionDelegate: WelcomeCompletionDelegate?

    private var allPlans: [PurchasePlan] = [.dummy, .dummy]

    private var selectedPlanIndex: Int?

    private var signupEmail: String?

    private var signupTransaction: InAppTransaction?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }

        collectionPlans.isUserInteractionEnabled = false
        viewFooter.isHidden = omitsSiblingLink

        labelTitle.text = L10n.Welcome.Purchase.title
        textEmail.placeholder = L10n.Welcome.Purchase.Email.placeholder
        buttonPurchase.title = L10n.Welcome.Purchase.submit
        labelLogin1.text = L10n.Welcome.Purchase.Login.footer
        labelLogin2.text = L10n.Welcome.Purchase.Login.button

        viewLogin.accessibilityLabel = "\(labelLogin1.text!) \(labelLogin2.text!)"
        textEmail.text = preset.purchaseEmail
        
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

    override func didRefreshOrientationConstraints() {
        scrollView.isScrollEnabled = (traitCollection.verticalSizeClass == .compact)
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
    
    @IBAction private func signUp(_ sender: Any?) {
        guard !buttonPurchase.isRunningActivity else {
            return
        }
    
        guard let planIndex = selectedPlanIndex else {
            return
        }
        let errorTitle = L10n.Welcome.Purchase.Error.title
        let errorMessage = L10n.Welcome.Purchase.Error.validation
        guard let email = textEmail.text, Validator.validate(email: email) else {
            signupEmail = nil
            let alert = Macros.alert(errorTitle, errorMessage)
            alert.addCancelAction(L10n.Ui.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }

        let plan = allPlans[planIndex]
        guard !plan.isDummy else {
            let alert = Macros.alert(
                L10n.Welcome.Iap.Error.title,
                L10n.Welcome.Iap.Error.Message.unavailable
            )
            alert.addCancelAction(L10n.Ui.Global.close)
            present(alert, animated: true, completion: nil)
            return
        }
        
        log.debug("Will purchase plan: \(plan.product)")

        disableInteractions(fully: true)
        
        preset?.accountProvider.purchase(plan: plan.plan) { (transaction, error) in
            self.enableInteractions()

            guard let transaction = transaction else {
                if let error = error {
                    log.error("Purchase failed (error: \(error))")

                    let alert = Macros.alert(
                        L10n.Welcome.Iap.Error.title,
                        error.localizedDescription
                    )
                    alert.addCancelAction(L10n.Ui.Global.close)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    log.warning("Cancelled purchase")
                }
                return
            }

            log.debug("Purchased with transaction: \(transaction)")

            self.signupEmail = email
            self.signupTransaction = transaction
            self.perform(segue: StoryboardSegue.Welcome.signupViaPurchaseSegue)
        }
    }
    
    @IBAction private func logIn(_ sender: Any?) {
        guard let pageController = parent as? WelcomePageViewController else {
            fatalError("Not running in WelcomePageViewController")
        }
        pageController.show(page: .login)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == StoryboardSegue.Welcome.signupViaPurchaseSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController
            
            guard let email = signupEmail else {
                fatalError("Signing up and signupEmail is not set")
            }
            var metadata = SignupMetadata(email: email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.metadata = metadata
            vc.signupRequest = SignupRequest(email: email, transaction: signupTransaction)
            vc.preset = preset
            vc.completionDelegate = completionDelegate
        }
    }
    
    private func disableInteractions(fully: Bool) {
        collectionPlans.isUserInteractionEnabled = false
        if fully {
            parent?.view.isUserInteractionEnabled = false
        }
        buttonPurchase.startActivity()
    }
    
    private func enableInteractions() {
        collectionPlans.isUserInteractionEnabled = true
        parent?.view.isUserInteractionEnabled = true
        buttonPurchase.stopActivity()
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

        Theme.current.applySolidLightBackground(collectionPlans)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyInput(textEmail)
        Theme.current.applyActionButton(buttonPurchase)
        Theme.current.applyBody1(labelLogin1, appearance: .dark)
        Theme.current.applyTextButton(labelLogin2)
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
        let itemWidth = (collectionView.bounds.size.width - 10.0) / 2.0

        return CGSize(width: itemWidth, height: collectionView.bounds.size.height)
    }
}

extension PurchaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textEmail) {
            signUp(nil)
        }
        return true
    }
}
