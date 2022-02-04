//
//  LoginViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
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

class LoginViewController: AutolayoutViewController, WelcomeChild, PIAWelcomeViewControllerDelegate {
    
    private enum LoginOption {
        case credentials
        case receipt
        case magicLink
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var textUsername: BorderedTextField!

    @IBOutlet private weak var textPassword: BorderedTextField!
    
    @IBOutlet private weak var buttonLogin: PIAButton!
    
    @IBOutlet private weak var couldNotGetPlanButton: UIButton!

    @IBOutlet private weak var loginWithReceipt: UIButton!

    @IBOutlet private weak var loginWithLink: UIButton!

    var preset: Preset?
    private weak var delegate: PIAWelcomeViewControllerDelegate?

    var omitsSiblingLink = false
    
    weak var completionDelegate: WelcomeCompletionDelegate?

    private var signupEmail: String?
    
    private var isLogging = false
    
    private var timeToRetryCredentials: TimeInterval? = nil
    private var timeToRetryReceipt: TimeInterval? = nil
    private var timeToRetryMagicLink: TimeInterval? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(finishLoginWithMagicLink(notification:)), name: .PIAFinishLoginWithMagicLink, object: nil)

        labelTitle.text = L10n.Welcome.Login.title
        textUsername.placeholder = L10n.Welcome.Login.Username.placeholder
        textPassword.placeholder = L10n.Welcome.Login.Password.placeholder

        textUsername.text = preset.loginUsername
        textPassword.text = preset.loginPassword
        
        styleButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableInteractions(true)
    }
    
    override func didRefreshOrientationConstraints() {
        scrollView.isScrollEnabled = (traitCollection.verticalSizeClass == .compact)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        guard let vc = segue.destination as? PIAWelcomeViewController else {
            return
        }
        
        vc.delegate = delegate ?? self
        if let preset = preset {
            vc.preset = preset
        }
        
        switch segue.identifier  {
        case StoryboardSegue.Welcome.restoreLoginPurchaseSegue.rawValue:
            vc.preset.pages = .restore
        case StoryboardSegue.Welcome.expiredAccountPurchaseSegue.rawValue:
            vc.preset.isExpired = true
            vc.preset.pages = .purchase
        default:
            break
        }
        
    }
    // MARK: Actions
    @IBAction private func logInWithLink(_ sender: Any?) {
        if let timeUntilNextTry = timeToRetryMagicLink?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Welcome.Login.Error.throttled("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }
        
        let bundle = Bundle(for: LoginViewController.self)
        let storyboard = UIStoryboard(name: "Welcome", bundle: bundle)
        if let magicLinkLoginViewController = storyboard.instantiateViewController(withIdentifier: "MagicLinkLoginViewController") as? MagicLinkLoginViewController {
            let alert = Macros.alert(magicLinkLoginViewController)
            alert.addCancelAction(L10n.Signup.Purchase.Uncredited.Alert.Button.cancel)
            alert.addActionWithTitle(L10n.Welcome.Login.Magic.Link.send.uppercased(), handler: {
                
                let email = magicLinkLoginViewController.email()
                guard Validator.validate(email: email) else {
                    Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                            message: L10n.Welcome.Login.Magic.Link.Invalid.email)
                    return
                }
                
                guard !self.isLogging else {
                    return
                }
                
                self.showLoadingAnimation()
                self.preset?.accountProvider.loginUsingMagicLink(withEmail: email, { (error) in
                    
                    self.hideLoadingAnimation()
                    guard error == nil else {
                        self.handleLoginFailed(error, loginOption: .magicLink)
                        return
                    }
                    
                    Macros.displaySuccessImageNote(withImage: Asset.iconWarning.image,
                                                   message: L10n.Welcome.Login.Magic.Link.response)
                })
                
            })
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc private func finishLoginWithMagicLink(notification: Notification) {
        
        if let userInfo = notification.userInfo, let error = userInfo[NotificationKey.error] as? Error {
            displayErrorMessage(errorMessage: L10n.Welcome.Purchase.Error.Connectivity.title)
            return
        }
        
        self.completionDelegate?.welcomeDidLogin(withUser:
            UserAccount(credentials: Credentials(username: "",
                                                 password: ""),
                        info: nil),
                                                 topViewController: self)
    }
    
    @IBAction private func logInWithReceipt(_ sender: Any?) {
        if let timeUntilNextTry = timeToRetryReceipt?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Welcome.Login.Error.throttled("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }
        
        guard !isLogging else {
            return
        }
        
        guard let receipt = Client.store.paymentReceipt else {
            return
        }

        let request = LoginReceiptRequest(receipt: receipt)
        
        prepareLogin()
        preset?.accountProvider.login(with: request, { userAccount, error in
            self.handleLoginResult(user: userAccount, error: error, loginOption: .receipt)
        })
    }

    @IBAction private func logIn(_ sender: Any?) {
        if let timeUntilNextTry = timeToRetryCredentials?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Welcome.Login.Error.throttled("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }
        
        guard !isLogging else {
            return
        }

        guard let credentials = getValidCredentials() else {
            return
        }
        
        let request = LoginRequest(credentials: credentials)
        
        prepareLogin()
        preset?.accountProvider.login(with: request, { userAccount, error in
            self.handleLoginResult(user: userAccount, error: error, loginOption: .credentials)
        })
    }
    
    private func getValidCredentials() -> Credentials? {
        guard let username = getValidTextFrom(textField: textUsername) else {
            handleUsernameFieldInvalid()
            return nil
        }
        
        self.status = .restore(element: textUsername)
        
        guard let password = getValidTextFrom(textField: textPassword) else {
            handleLoginFieldInvalid(textField: textPassword)
            return nil
        }

        self.status = .restore(element: textPassword)
        self.status = .initial

        view.endEditing(false)

        return Credentials(username: username, password: password)
    }
    
    private func getValidTextFrom(textField: UITextField) -> String? {
        guard let text = textField.text?.trimmed(), !text.isEmpty else {
            return nil
        }
        return text
    }
    
    private func handleUsernameFieldInvalid() {
        handleLoginFieldInvalid(textField: textUsername)
        if textPassword.text == nil || textPassword.text!.isEmpty {
            self.status = .error(element: textPassword)
        }
    }
    
    private func handleLoginFieldInvalid(textField: UITextField) {
        let errorMessage = L10n.Welcome.Login.Error.validation
        Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                message: errorMessage)
        self.status = .error(element: textField)
    }
    
    
    private func prepareLogin() {
        log.debug("Logging in...")
        enableInteractions(false)
        showLoadingAnimation()
    }
    
    private func handleLoginResult(user: UserAccount?, error: Error?, loginOption: LoginOption) {
        enableInteractions(true)

        hideLoadingAnimation()

        guard let user = user else {
            handleLoginFailed(error, loginOption: loginOption)
            return
        }
        
        log.debug("Login succeeded!")
        
        self.completionDelegate?.welcomeDidLogin(withUser: user, topViewController: self)
    }
    
    private func updateTimeToRetry(loginOption: LoginOption, retryAfterSeconds: Double) {
        let retryAfterTimeStamp = Date().timeIntervalSince1970 + retryAfterSeconds
        switch loginOption {
        case .credentials:
            timeToRetryCredentials = retryAfterTimeStamp
        case .receipt:
            timeToRetryReceipt = retryAfterTimeStamp
        case .magicLink:
            timeToRetryMagicLink = retryAfterTimeStamp
        }
    }
    
    private func handleLoginFailed(_ error: Error?, loginOption: LoginOption) {
        var displayDuration: Double?
        var errorMessage: String?
        if let error = error {
            if let clientError = error as? ClientError {
                switch clientError {
                case .unauthorized:
                    errorMessage = L10n.Welcome.Login.Error.unauthorized

                case .throttled(retryAfter: let retryAfter):
                    let localisedThrottlingString = L10n.Welcome.Login.Error.throttled("\(retryAfter)")
                    errorMessage = NSLocalizedString(localisedThrottlingString, comment: localisedThrottlingString)
                    
                    let retryAfterSeconds = Double(retryAfter)
                    displayDuration = retryAfterSeconds
                    
                    updateTimeToRetry(loginOption: loginOption, retryAfterSeconds: retryAfterSeconds)
                    
                case .expired:
                    handleExpiredAccount()
                    return
                default:
                    break
                }
            }
            if (errorMessage == nil) {
                errorMessage = error.localizedDescription
            }
            log.error("Failed to log in (error: \(error))")
        } else {
            log.error("Failed to log in")
        }
        displayErrorMessage(errorMessage: errorMessage, displayDuration: displayDuration)
    }
    
    private func displayErrorMessage(errorMessage: String?, displayDuration: Double? = nil) {
        
        Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                message: errorMessage ?? L10n.Welcome.Login.Error.title, andDuration: displayDuration)
    }
    
    private func handleExpiredAccount() {
        perform(segue: StoryboardSegue.Welcome.expiredAccountPurchaseSegue, sender: self)
    }
    
    private func enableInteractions(_ enable: Bool) {
        parent?.view.isUserInteractionEnabled = enable
        isLogging = !enable
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyInput(textUsername)
        Theme.current.applyInput(textPassword)
        Theme.current.applyButtonLabelMediumStyle(loginWithReceipt)
        Theme.current.applyButtonLabelMediumStyle(loginWithLink)
        Theme.current.applyButtonLabelMediumStyle(couldNotGetPlanButton)
    }
    
    private func styleButtons() {
        buttonLogin.setRounded()
        buttonLogin.style(style: TextStyle.Buttons.piaGreenButton)
        buttonLogin.setTitle(L10n.Welcome.Login.submit.uppercased(),
                               for: [])
        buttonLogin.accessibilityIdentifier = "uitests.login.submit"
        
        couldNotGetPlanButton.setTitle(L10n.Welcome.Login.Restore.button,
                                       for: [])
        couldNotGetPlanButton.titleLabel?.numberOfLines = 0
        couldNotGetPlanButton.titleLabel?.textAlignment = .center

        loginWithReceipt.setTitle(L10n.Welcome.Login.Receipt.button,
                                  for: [])
        loginWithReceipt.titleLabel?.numberOfLines = 0
        loginWithReceipt.titleLabel?.textAlignment = .center
        
        loginWithLink.setTitle(L10n.Welcome.Login.Magic.Link.title,
                               for: [])
        loginWithLink.titleLabel?.numberOfLines = 0
        loginWithLink.titleLabel?.textAlignment = .center
    }
    
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController) {
        completionDelegate?.welcomeDidSignup(withUser: user, topViewController: topViewController)
    }
    
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController) {
        completionDelegate?.welcomeDidLogin(withUser: user, topViewController: topViewController)
        
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textUsername) {
            textPassword.becomeFirstResponder()
        } else if (textField == textPassword) {
            logIn(nil)
        }
        return true
    }
}
