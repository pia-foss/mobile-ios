//
//  AddEmailToAccountViewController.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 26/03/2020.
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
import AuthenticationServices
import PIADesignSystem
import PIAUIKit

private let log = PIALogger.logger(for: AddEmailToAccountViewController.self)

class AddEmailToAccountViewController: AutolayoutViewController, BrandableNavigationBar {

    //Update email
    @IBOutlet private weak var buttonConfirm: PIAButton!
    @IBOutlet private weak var textEmail: BorderedTextField!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    var termsAndConditionsAgreed = false
    
    //Show credentials
    @IBOutlet private weak var imvPicture: UIImageView!
    @IBOutlet private weak var labelMessage: UILabel!
    @IBOutlet private weak var labelUsernameCaption: UILabel!
    @IBOutlet private weak var labelUsername: UILabel!
    @IBOutlet private weak var labelPasswordCaption: UILabel!
    @IBOutlet private weak var labelPassword: UILabel!
    @IBOutlet private weak var buttonSubmit: PIAButton!
    @IBOutlet private weak var usernameContainer: UIView!
    @IBOutlet private weak var passwordContainer: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var addEmailContainer: UIView!

    private var labelOr = UILabel()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        labelTitle.text = L10n.Localizable.Set.Email.Form.email
        labelSubtitle.text = L10n.Localizable.Set.Email.why
       
        textEmail.placeholder = L10n.Localizable.Account.Email.placeholder
        
        if let currentUser = Client.providers.accountProvider.currentUser,
            let info = currentUser.info {
            textEmail.text = info.email
        }

        self.styleConfirmButton()
        self.styleLogoutButton()
        
        scrollView.alpha = 0

        labelUsernameCaption.text = L10n.Localizable.Account.Username.caption
        labelUsername.text = Client.providers.accountProvider.publicUsername ?? ""
        labelPasswordCaption.text = L10n.Localizable.Set.Email.Password.caption

        self.styleDismissButton()
        self.styleContainers()

        setupAppleSignInUI()
    }

    @IBAction private func signUp(_ sender: Any?) {
        let email = textEmail.text?.trimmed() ?? ""

        do {
            try Validator.validate(email: email)
        } catch {
            Macros.displayImageNote(
                withImage: Asset.Images.iconWarning.image,
                message: error.errorMessage
            )
            self.status = .error(element: textEmail)
            return
        }

        guard termsAndConditionsAgreed else {
            //present term and conditions
            let alert = Macros.alert(L10n.Localizable.Gdpr.Collect.Data.title, L10n.Localizable.Gdpr.Collect.Data.description)
            alert.addCancelAction(L10n.Localizable.Global.cancel)
            alert.addActionWithTitle(L10n.Localizable.Gdpr.Accept.Button.title) {
                self.termsAndConditionsAgreed = true
                self.signUp(nil)
            }

            self.present(alert, animated: true, completion: nil)
            return
        }

        self.status = .restore(element: textEmail)
        
        self.showLoadingAnimation()
        self.disableInteractions()
        
        log.debug("Account: Modifying account email...")

        let request = UpdateAccountRequest(email: email)

        let password = ""
        Client.providers.accountProvider.update(with: request,
                                                resetPassword: true,
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
                                                        
                                                        let alert = Macros.alert(L10n.Localizable.Global.error, L10n.Localizable.Account.Set.Email.error)
                                                        alert.addDefaultAction(L10n.Localizable.Global.close)
                                                        self?.present(alert, animated: true, completion: nil)
                                                        
                                                        return
                                                    }
                                                    
                                                    log.debug("Account: Email successfully modified")
                                                    self?.textEmail.endEditing(true)

                                                    //TODO SHOW CREDENTIALS
                                                    self?.labelMessage.text = L10n.Localizable.Set.Email.Success.messageFormat(email)
                                                    self?.labelPassword.text = Client.configuration.tempAccountPassword

                                                    UIView.animate(withDuration: 0.3, animations: {
                                                        self?.scrollView.alpha = 1
                                                        self?.view.layoutSubviews()
                                                    })

        }

    }
    
    @IBAction private func close() {
        Client.configuration.tempAccountPassword = "" //Clean pwd memory
        self.dismissModal()
    }

    private func disableInteractions() {
        parent?.view.isUserInteractionEnabled = false
    }
    
    private func enableInteractions() {
        parent?.view.isUserInteractionEnabled = true
    }
    
    private func setupAppleSignInUI() {
        labelOr.text = L10n.Localizable.Global.or.uppercased()
        labelOr.textAlignment = .center
        
        let signInWithAppleButton = ASAuthorizationAppleIDButton(type: .signIn, style: Theme.current.palette.appearance == .dark ? .whiteOutline : .black)
        signInWithAppleButton.addTarget(self, action: #selector(handleAuthorizationAppleID), for: .touchUpInside)
                    
        self.addEmailContainer.addSubview(signInWithAppleButton)
        self.addEmailContainer.addSubview(labelOr)

        labelOr.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelOr.topAnchor.constraint(equalTo: self.buttonConfirm.bottomAnchor, constant: 15),
            labelOr.leftAnchor.constraint(equalTo: self.addEmailContainer.leftAnchor),
            labelOr.rightAnchor.constraint(equalTo: self.addEmailContainer.rightAnchor),
            labelOr.heightAnchor.constraint(equalToConstant: 15),

            signInWithAppleButton.topAnchor.constraint(equalTo: self.labelOr.bottomAnchor, constant: 15),
            signInWithAppleButton.leftAnchor.constraint(equalTo: self.addEmailContainer.leftAnchor),
            signInWithAppleButton.rightAnchor.constraint(equalTo: self.addEmailContainer.rightAnchor),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: Actions
    @IBAction private func handleAuthorizationAppleID() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    @IBAction private func logout() {
        Client.providers.accountProvider.logout({ error in
            guard let _ = error else {
                self.dismiss(animated: true) {
                    AppPreferences.shared.reset()
                }
                return
            }
            log.debug("Account: Error logging out the user")
        })
    }

    // MARK: Restylable
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(scrollView)
        Theme.current.applyInput(textEmail)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelOr)
        Theme.current.applySubtitle(labelSubtitle)
        Theme.current.applySubtitle(labelMessage)

        Theme.current.applySubtitle(labelUsernameCaption)
        Theme.current.applyTitle(labelUsername, appearance: .dark)
        Theme.current.applySubtitle(labelPasswordCaption)
        Theme.current.applyTitle(labelPassword, appearance: .dark)

    }
    
    private func styleConfirmButton() {
        buttonConfirm.setRounded()
        buttonConfirm.style(style: TextStyle.Buttons.piaGreenButton)
        buttonConfirm.setTitle(L10n.Localizable.Global.update.uppercased(),
                               for: [])
    }
    
    private func styleLogoutButton() {
        Theme.current.applyButtonLabelMediumStyle(logoutButton)
        logoutButton.setTitle(L10n.Localizable.Menu.Logout.title.uppercased(),
                               for: [])
    }
    
    private func styleDismissButton() {
        buttonSubmit.setRounded()
        buttonSubmit.style(style: TextStyle.Buttons.piaGreenButton)
        buttonSubmit.setTitle(L10n.Localizable.Global.close.uppercased(),
                              for: [])
    }
    
    private func styleContainers() {
        self.styleContainerView(usernameContainer)
        self.styleContainerView(passwordContainer)
    }
    
    func styleContainerView(_ view: UIView) {
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.piaGrey4.cgColor
    }

}

extension AddEmailToAccountViewController: ASAuthorizationControllerPresentationContextProviding {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        if let email = appleIDCredentials.email {
            textEmail.text = email
            let preferences = Client.preferences.editable()
            preferences.signInWithAppleFakeEmail = email
            preferences.commit()
        } else {
            textEmail.text = Client.preferences.signInWithAppleFakeEmail
        }
        self.signUp(nil)
    }
}

extension AddEmailToAccountViewController: ASAuthorizationControllerDelegate {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
