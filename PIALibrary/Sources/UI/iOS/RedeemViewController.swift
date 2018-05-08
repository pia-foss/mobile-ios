//
//  RedeemViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 5/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

class RedeemViewController: AutolayoutViewController, WelcomeChild {
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    @IBOutlet private weak var textEmail: BorderedTextField!
    
    @IBOutlet private weak var textCode: BorderedTextField!
    
    @IBOutlet private weak var buttonRedeem: ActivityButton!
    
    @IBOutlet private weak var viewFooter: UIView!
    
//    @IBOutlet private weak var viewPurchase: UIView!
//
//    @IBOutlet private weak var labelPurchase1: UILabel!
//
//    @IBOutlet private weak var labelPurchase2: UILabel!
//
//    @IBOutlet private weak var buttonRestorePurchase: UIButton!

    var preset: PIAWelcomeViewController.Preset?
    
    var omitsSiblingLink: Bool = false
    
    var completionDelegate: WelcomeCompletionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }
        
        viewFooter.isHidden = omitsSiblingLink
        
        labelTitle.text = L10n.Welcome.Redeem.title
        labelSubtitle.text = L10n.Welcome.Redeem.subtitle
        textEmail.placeholder = L10n.Welcome.Redeem.Email.placeholder
        textCode.placeholder = L10n.Welcome.Redeem.Code.placeholder
        buttonRedeem.title = L10n.Welcome.Redeem.submit
//        labelPurchase1.text = L10n.Welcome.Login.Purchase.footer
//        labelPurchase2.text = L10n.Welcome.Login.Purchase.button
//        buttonRestorePurchase.setTitle(L10n.Welcome.Login.Restore.button, for: .normal)
//        buttonRestorePurchase.titleLabel?.textAlignment = .center
//        buttonRestorePurchase.titleLabel?.numberOfLines = 0
        
        viewFooter.isHidden = true
//        buttonLogin.accessibilityIdentifier = "uitests.redeem.submit"
//        viewPurchase.accessibilityLabel = "\(labelPurchase1.text!) \(labelPurchase2.text!)"
        textEmail.text = preset.redeemEmail
        textCode.text = preset.redeemCode
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableInteractions(true)
    }
    
    override func didRefreshOrientationConstraints() {
        scrollView.isScrollEnabled = (traitCollection.verticalSizeClass == .compact)
    }
    
    // MARK: Actions

    @IBAction private func redeem(_ sender: Any?) {
        //
    }
    
    private func enableInteractions(_ enable: Bool) {
        parent?.view.isUserInteractionEnabled = enable
        if enable {
            buttonRedeem.stopActivity()
        } else {
            buttonRedeem.startActivity()
        }
    }

    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelSubtitle, appearance: .dark)
        Theme.current.applyInput(textEmail)
        Theme.current.applyInput(textCode)
        Theme.current.applyActionButton(buttonRedeem)
//        Theme.current.applyBody1(labelPurchase1, appearance: .dark)
//        Theme.current.applyTextButton(labelPurchase2)
//        Theme.current.applyTextButton(buttonRestorePurchase)
    }
}

extension RedeemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textEmail) {
            textCode.becomeFirstResponder()
        } else if (textField == textCode) {
            redeem(nil)
        }
        return true
    }
}
