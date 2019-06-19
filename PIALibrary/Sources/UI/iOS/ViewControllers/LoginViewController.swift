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
    
    @IBOutlet private weak var buttonLogin: PIAButton!
    
    var preset: Preset?
    
    var omitsSiblingLink = false
    
    weak var completionDelegate: WelcomeCompletionDelegate?

    private var signupEmail: String?
    
    private var isLogging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let preset = self.preset else {
            fatalError("Preset not propagated")
        }

        labelTitle.text = L10n.Welcome.Login.title
        textUsername.placeholder = L10n.Welcome.Login.Username.placeholder
        textPassword.placeholder = L10n.Welcome.Login.Password.placeholder

        textUsername.text = preset.loginUsername
        textPassword.text = preset.loginPassword
        
        styleLoginButton()
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
    
        guard !isLogging else {
            return
        }

        let errorMessage = L10n.Welcome.Login.Error.validation
        guard let username = textUsername.text?.trimmed(), !username.isEmpty else {
            
            Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                    message: errorMessage)
            self.status = .error(element: textUsername)
            
            if textPassword.text == nil || textPassword.text!.isEmpty {
                self.status = .error(element: textPassword)
            }

            return
        }
        
        self.status = .restore(element: textUsername)
        
        guard let password = textPassword.text?.trimmed(), !password.isEmpty else {
            Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                    message: errorMessage)
            self.status = .error(element: textPassword)
            return
        }

        self.status = .restore(element: textPassword)
        self.status = .initial

        view.endEditing(false)

        let credentials = Credentials(username: username, password: password)
        let request = LoginRequest(credentials: credentials)

        textUsername.text = username
        textPassword.text = password
        log.debug("Logging in...")

        enableInteractions(false)

        self.showLoadingAnimation()
        
        preset?.accountProvider.login(with: request) { (user, error) in
            self.enableInteractions(true)

            self.hideLoadingAnimation()

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

                Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                        message: errorMessage ?? L10n.Welcome.Login.Error.title)
                return
            }
            
            log.debug("Login succeeded!")
            
            self.completionDelegate?.welcomeDidLogin(withUser: user, topViewController: self)
        }
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
    }
    
    private func styleLoginButton() {
        buttonLogin.setRounded()
        buttonLogin.style(style: TextStyle.Buttons.piaGreenButton)
        buttonLogin.setTitle(L10n.Welcome.Login.submit.uppercased(),
                               for: [])
        buttonLogin.accessibilityIdentifier = "uitests.login.submit"
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
