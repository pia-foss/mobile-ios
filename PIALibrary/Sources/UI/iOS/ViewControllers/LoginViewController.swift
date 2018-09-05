//
//  LoginViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class LoginViewController: AutolayoutViewController, WelcomeChild {
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var textUsername: BorderedTextField!

    @IBOutlet private weak var textPassword: BorderedTextField!
    
    @IBOutlet private weak var buttonLogin: ActivityButton!
    
    @IBOutlet private weak var viewFooter: UIView!
    
    @IBOutlet private weak var viewPurchase: UIView!
    
    @IBOutlet private weak var labelPurchase1: UILabel!
    
    @IBOutlet private weak var labelPurchase2: UILabel!

    @IBOutlet private weak var viewRedeem: UIView!
    
    @IBOutlet private weak var labelRedeem1: UILabel!
    
    @IBOutlet private weak var labelRedeem2: UILabel!
    
    @IBOutlet private weak var buttonRestorePurchase: UIButton!

    var preset: PIAWelcomeViewController.Preset?
    
    var omitsSiblingLink = false
    
    weak var completionDelegate: WelcomeCompletionDelegate?

    private var signupEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }

        viewFooter.isHidden = omitsSiblingLink

        labelTitle.text = L10n.Welcome.Login.title
        textUsername.placeholder = L10n.Welcome.Login.Username.placeholder
        textPassword.placeholder = L10n.Welcome.Login.Password.placeholder
        buttonLogin.title = L10n.Welcome.Login.submit
        labelPurchase1.text = L10n.Welcome.Login.Purchase.footer
        labelPurchase2.text = L10n.Welcome.Login.Purchase.button
        labelRedeem1.text = L10n.Welcome.Login.Redeem.footer
        labelRedeem2.text = L10n.Welcome.Login.Redeem.button
        buttonRestorePurchase.setTitle(L10n.Welcome.Login.Restore.button, for: .normal)
        buttonRestorePurchase.titleLabel?.textAlignment = .center
        buttonRestorePurchase.titleLabel?.numberOfLines = 0

        buttonLogin.accessibilityIdentifier = "uitests.login.submit"
        viewPurchase.accessibilityLabel = "\(labelPurchase1.text!) \(labelPurchase2.text!)"
        textUsername.text = preset.loginUsername
        textPassword.text = preset.loginPassword
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableInteractions(true)
    }
    
    override func didRefreshOrientationConstraints() {
        scrollView.isScrollEnabled = (traitCollection.verticalSizeClass == .compact)
    }
    
    // MARK: Actions
    
    @IBAction private func logIn(_ sender: Any?) {
        guard !buttonLogin.isRunningActivity else {
            return
        }
    
        let errorTitle = L10n.Welcome.Login.Error.title
        let errorMessage = L10n.Welcome.Login.Error.validation
        guard let username = textUsername.text?.trimmed(), !username.isEmpty else {
            let alert = Macros.alert(errorTitle, errorMessage)
            alert.addCancelAction(L10n.Ui.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }
        guard let password = textPassword.text?.trimmed(), !password.isEmpty else {
            let alert = Macros.alert(errorTitle, errorMessage)
            alert.addCancelAction(L10n.Ui.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }

        view.endEditing(false)

        let credentials = Credentials(username: username, password: password)
        let request = LoginRequest(credentials: credentials)

        textUsername.text = username
        textPassword.text = password
        log.debug("Logging in...")

        enableInteractions(false)

        preset?.accountProvider.login(with: request) { (user, error) in
            self.enableInteractions(true)

            guard let user = user else {
                var errorMessage: String?
                if let error = error {
                    if let clientError = error as? ClientError {
                        switch clientError {
                        case .unauthorized:
                            errorMessage = L10n.Welcome.Login.Error.unauthorized

                        case .throttled:
                            errorMessage = L10n.Welcome.Login.Error.throttled
                            
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

                let alert = Macros.alert(L10n.Welcome.Login.Error.title, errorMessage ?? "")
                alert.addCancelAction(L10n.Ui.Global.close)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            log.debug("Login succeeded!")
            
            self.completionDelegate?.welcomeDidLogin(withUser: user, topViewController: self)
        }
    }

    @IBAction private func signUp(_ sender: Any?) {
        guard let pageController = parent as? WelcomePageViewController else {
            fatalError("Not running in WelcomePageViewController")
        }
        pageController.show(page: .purchase)
    }
    
    @IBAction private func redeem(_ sender: Any?) {
        guard let pageController = parent as? WelcomePageViewController else {
            fatalError("Not running in WelcomePageViewController")
        }
        pageController.show(page: .redeem)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RestoreSignupViewController {
            vc.preset = preset
            vc.delegate = self
        }
        // signup after receipt restore
        else if (segue.identifier == StoryboardSegue.Welcome.signupViaRestoreSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController

            guard let email = signupEmail else {
                fatalError("Signing up and signupEmail is not set")
            }
            var metadata = SignupMetadata(email: email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.metadata = metadata
            vc.signupRequest = SignupRequest(email: email)
        }
    }

    private func enableInteractions(_ enable: Bool) {
        parent?.view.isUserInteractionEnabled = enable
        if enable {
            buttonLogin.stopActivity()
        } else {
            buttonLogin.startActivity()
        }
    }
    
    // MARK: Restylable
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applyInput(textUsername)
        Theme.current.applyInput(textPassword)
        Theme.current.applyActionButton(buttonLogin)
        Theme.current.applyBody1(labelPurchase1, appearance: .dark)
        Theme.current.applyTextButton(labelPurchase2)
        Theme.current.applyBody1(labelRedeem1, appearance: .dark)
        Theme.current.applyTextButton(labelRedeem2)
        Theme.current.applyTextButton(buttonRestorePurchase)
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

extension LoginViewController: RestoreSignupViewControllerDelegate {
    func restoreController(_ restoreController: RestoreSignupViewController, didRefreshReceiptWith email: String) {
        dismiss(animated: true) {
            self.signupEmail = email
            self.perform(segue: StoryboardSegue.Welcome.signupViaRestoreSegue)
        }
    }
    
    func restoreControllerDidDismiss(_ restoreController: RestoreSignupViewController) {
        dismiss(animated: true, completion: nil)
    }
}
