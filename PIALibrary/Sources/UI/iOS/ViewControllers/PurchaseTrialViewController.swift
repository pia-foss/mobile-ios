//
//  PurchaseTrialViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 06/08/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit

class PurchaseTrialViewController: AutolayoutViewController, BrandableNavigationBar, WelcomeChild {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var textAgreement: UITextView!
    @IBOutlet private weak var buttonPurchase: PIAButton!
    @IBOutlet private weak var buttonMorePlans: PIAButton!

    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var smallTitleLabel: UILabel!

    @IBOutlet private weak var protectionImageView: UIImageView!
    @IBOutlet private weak var protectionTitleLabel: UILabel!
    @IBOutlet private weak var protectionSubtitleLabel: UILabel!

    @IBOutlet private weak var devicesImageView: UIImageView!
    @IBOutlet private weak var devicesTitleLabel: UILabel!
    @IBOutlet private weak var devicesSubtitleLabel: UILabel!

    @IBOutlet private weak var serversImageView: UIImageView!
    @IBOutlet private weak var serversTitleLabel: UILabel!
    @IBOutlet private weak var serversSubtitleLabel: UILabel!

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
        
        guard let _ = self.preset else {
            fatalError("Preset not propagated")
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(back(_:))
        )
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back

        headerTitleLabel.text = "Try free for 7 days!"
        subtitleLabel.text = "Only $ per year after"
        smallTitleLabel.text = "7 day money back guarantee"
        
        protectionTitleLabel.text = "1 year of privacy and identity protection"
        protectionSubtitleLabel.text = "Browse anonymously and hide your ip."
        protectionImageView.image = Asset.shieldIcon.image.withRenderingMode(.alwaysTemplate)
        
        devicesTitleLabel.text = "Support 10 devices at once"
        devicesSubtitleLabel.text = "Protect yourself on up to 10 devices at a time."
        devicesImageView.image = Asset.computerIcon.image.withRenderingMode(.alwaysTemplate)
        
        serversTitleLabel.text = "Connect to any region easily"
        serversSubtitleLabel.text = "More than 33 servers in 32 countries"
        serversImageView.image = Asset.globeIcon.image.withRenderingMode(.alwaysTemplate)
        
        textAgreement.attributedText = Theme.current.agreementText(
            withMessage: L10n.Welcome.Agreement.message,
            tos: L10n.Welcome.Agreement.Message.tos,
            tosUrl: Client.configuration.tosUrl,
            privacy: L10n.Welcome.Agreement.Message.privacy,
            privacyUrl: Client.configuration.privacyUrl
        )
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(productsDidFetch(notification:)), name: .__InAppDidFetchProducts, object: nil)
        
        styleButtons()
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
    
    @objc private func back(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
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
        } else if (segue.identifier == StoryboardSegue.Welcome.viewMoreVPNPlansSegue.rawValue) {
            if let vc = segue.destination as? PurchaseViewController {
                vc.preset = preset
                vc.completionDelegate = completionDelegate
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
            let price = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            subtitleLabel.text = "Only \(price) after"
            Theme.current.makeSmallLabelToStandOut(subtitleLabel,
                                                   withTextToStandOut: price)
            allPlans[0] = purchase
            selectedPlanIndex = 0
        }
    }
    
    private func disableInteractions(fully: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showLoadingAnimation()
        }
        if fully {
            parent?.view.isUserInteractionEnabled = false
        }
    }
    
    private func enableInteractions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideLoadingAnimation()
        }
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
        Theme.current.applyLinkAttributes(textAgreement)
        Theme.current.applyBigTitle(headerTitleLabel, appearance: .dark)
        Theme.current.applySmallSubtitle(smallTitleLabel)
        Theme.current.applySubtitle(subtitleLabel)

        if Theme.current.palette.appearance == .light {
            protectionImageView.tintColor = Theme.current.palette.lineColor
            devicesImageView.tintColor = Theme.current.palette.lineColor
            serversImageView.tintColor = Theme.current.palette.lineColor
        } else {
            protectionImageView.tintColor = .white
            devicesImageView.tintColor = .white
            serversImageView.tintColor = .white
        }
        
        Theme.current.applySettingsCellTitle(protectionTitleLabel, appearance: .dark)
        Theme.current.applySmallSubtitle(protectionSubtitleLabel)
        
        Theme.current.applySettingsCellTitle(devicesTitleLabel, appearance: .dark)
        Theme.current.applySmallSubtitle(devicesSubtitleLabel)

        Theme.current.applySettingsCellTitle(serversTitleLabel, appearance: .dark)
        Theme.current.applySmallSubtitle(serversSubtitleLabel)

    }
    
    private func styleButtons() {
        buttonPurchase.setRounded()
        buttonMorePlans.setRounded()
        buttonPurchase.style(style: TextStyle.Buttons.piaGreenButton)
        buttonMorePlans.style(style: TextStyle.Buttons.piaPlainTextButton)
        buttonPurchase.setTitle("Start subscription".uppercased(),
                                for: [])
        buttonMorePlans.setTitle("See all available plans",
                                for: [])
        Theme.current.applyTransparentButton(buttonMorePlans,
                                             withSize: 1.0)
    }
    
}
