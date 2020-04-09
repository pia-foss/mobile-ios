//
//  ConfirmVPNPlanViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 14/11/2018.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class ConfirmVPNPlanViewController: AutolayoutViewController, BrandableNavigationBar, WelcomeChild {

    @IBOutlet private weak var buttonConfirm: PIAButton!
    @IBOutlet private weak var textEmail: BorderedTextField!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!

    private var signupEmail: String?
    private var signupTransaction: InAppTransaction?
    var metadata: SignupMetadata!
    weak var completionDelegate: WelcomeCompletionDelegate?
    var omitsSiblingLink = false
    var termsAndConditionsAgreed = false

    var preset: Preset?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }

        navigationItem.hidesBackButton = true

        labelTitle.text = L10n.Welcome.Purchase.Confirm.Form.email
        labelSubtitle.text = L10n.Welcome.Purchase.Email.why
       
        textEmail.placeholder = L10n.Welcome.Purchase.Email.placeholder
        textEmail.text = preset.purchaseEmail
        self.styleConfirmButton()
        
    }

    @IBAction private func signUp(_ sender: Any?) {

        guard let email = textEmail.text?.trimmed(), Validator.validate(email: email) else {
            signupEmail = nil
            Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                    message: L10n.Welcome.Purchase.Error.validation)
            self.status = .error(element: textEmail)
            return
        }
        
        guard termsAndConditionsAgreed else {
            //present term and conditions
            self.performSegue(withIdentifier: StoryboardSegue.Signup.presentGDPRTermsSegue.rawValue,
                              sender: nil)
            return
        }

        self.status = .restore(element: textEmail)
        
        self.showLoadingAnimation()
        self.disableInteractions()
        
        log.debug("Account: Modifying account email...")
        
        metadata.title = L10n.Signup.InProgress.title
        metadata.bodyImage = Asset.imagePurchaseSuccess.image
        metadata.bodyTitle = L10n.Signup.Success.title
        metadata.bodySubtitle = L10n.Signup.Success.messageFormat(email)

        let request = UpdateAccountRequest(email: email)

        var password = ""
        if let currentPassword = metadata.user?.credentials.password {
            password = currentPassword
        }
        
        Client.providers.accountProvider.update(with: request,
                                                resetPassword: false,
                                                andPassword: password) { [weak self] (info, error) in
                                                    self?.hideLoadingAnimation()
                                                    self?.enableInteractions()
                                                    
                                                    guard let _ = info else {
                                                        if let error = error {
                                                            log.error("Account: Failed to modify account email (error: \(error))")
                                                        } else {
                                                            log.error("Account: Failed to modify account email")
                                                        }
                                                        
                                                        self?.textEmail.text = ""
                                                        
                                                        let alert = Macros.alert(L10n.Signup.Unreachable.vcTitle, L10n.Welcome.Update.Account.Email.error)
                                                        alert.addDefaultAction(L10n.Ui.Global.close)
                                                        self?.present(alert, animated: true, completion: nil)

                                                        return
                                                    }
                                                    
                                                    log.debug("Account: Email successfully modified")
                                                    self?.textEmail.endEditing(true)
                                                    self?.perform(segue: StoryboardSegue.Signup.successShowCredentialsSegueIdentifier)
        }

    }

    private func disableInteractions() {
        parent?.view.isUserInteractionEnabled = false
    }
    
    private func enableInteractions() {
        parent?.view.isUserInteractionEnabled = true
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let segueType = StoryboardSegue.Signup(rawValue: identifier) else {
            return
        }
        switch segueType {
        case .successShowCredentialsSegueIdentifier:
            let vc = segue.destination as! SignupSuccessViewController
            vc.metadata = metadata
            vc.completionDelegate = completionDelegate
            break
        case .presentGDPRTermsSegue:
            let gdprViewController = segue.destination as! GDPRViewController
            gdprViewController.delegate = self
            break
        default:
            break
        }

    }
    
    // MARK: Restylable
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyInput(textEmail)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelSubtitle)
    }
    
    private func styleConfirmButton() {
        buttonConfirm.setRounded()
        buttonConfirm.style(style: TextStyle.Buttons.piaGreenButton)
        buttonConfirm.setTitle(L10n.Welcome.Purchase.submit.uppercased(),
                               for: [])
    }

}

extension ConfirmVPNPlanViewController: GDPRDelegate {
    
    public func gdprViewWasAccepted() {
        self.termsAndConditionsAgreed = true
        self.signUp(nil)
    }
    
    public func gdprViewWasRejected() {
        self.termsAndConditionsAgreed = false
    }
    
}
