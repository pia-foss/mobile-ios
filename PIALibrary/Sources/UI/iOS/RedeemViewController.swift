//
//  RedeemViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 5/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class RedeemViewController: AutolayoutViewController, WelcomeChild {
    private static let nonDigitsSet = CharacterSet.decimalDigits.inverted
    
    private static let rxCodeGrouping: NSRegularExpression = try! NSRegularExpression(pattern: "\\d{4}(?=\\d)", options: [])
    
    private static let maxCodeLength = 16

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

    private var redeemEmail: String?
    
    private var redeemCode: String? {
        didSet {
            guard let code = redeemCode else {
                textCode.text = nil
                return
            }
            textCode.text = RedeemViewController.rxCodeGrouping.stringByReplacingMatches(
                in: code,
                options: [],
                range: NSMakeRange(0, code.count),
                withTemplate: "$0-"
            )
        }
    }

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
        redeemCode = preset.redeemCode // will set textCode
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
        guard !buttonRedeem.isRunningActivity else {
            return
        }
        
        guard let email = textEmail.text, Validator.validate(email: email) else {
            let alert = Macros.alert(
                L10n.Welcome.Redeem.Error.title,
                L10n.Welcome.Purchase.Error.validation
            )
            alert.addCancelAction(L10n.Ui.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }
        guard let code = redeemCode, Validator.validate(giftCode: code) else {
            let alert = Macros.alert(
                L10n.Welcome.Redeem.Error.title,
                L10n.Welcome.Redeem.Error.code
            )
            alert.addCancelAction(L10n.Ui.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        log.debug("Redeeming...")
        
        redeemEmail = email
        redeemCode = code
        perform(segue: StoryboardSegue.Welcome.signupViaRedeemSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == StoryboardSegue.Welcome.signupViaRedeemSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController
            
            guard let email = redeemEmail else {
                fatalError("Redeeming and redeemEmail is not set")
            }
            guard let code = redeemCode else {
                fatalError("Redeeming and redeemCode is not set")
            }
            var metadata = SignupMetadata(email: email)
            metadata.title = L10n.Welcome.Redeem.title
            metadata.bodySubtitle = L10n.Signup.InProgress.Redeem.message
            vc.metadata = metadata
            vc.redeemRequest = RedeemRequest(email: email, code: code)
            vc.preset = preset
            vc.completionDelegate = completionDelegate
        }
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == textCode else {
            return true
        }
        
        guard string.rangeOfCharacter(from: RedeemViewController.nonDigitsSet) == nil else {
            return false
        }
        guard let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            redeemCode = nil
            return true
        }

        let cursorLocation = textField.position(from: textField.beginningOfDocument, offset: range.location + string.count)
        let newCode = newText.replacingOccurrences(of: "-", with: "")
        guard newCode.count <= RedeemViewController.maxCodeLength else {
            return false
        }
        redeemCode = newCode
        if let previousLocation = cursorLocation {
            textField.selectedTextRange = textField.textRange(from: previousLocation, to: previousLocation)
        }

        return false
    }
}
