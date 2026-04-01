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

import PIADesignSystem
import PIALibrary
import PIALocalizations
import PIAUIKit
import UIKit

import class account.AccountRequestError

private let log = PIALogger.logger(for: LoginViewController.self)

final class LoginViewController: AutolayoutViewController, PIAWelcomeViewControllerDelegate {

    private enum LoginOption {
        case credentials
        case receipt
        case magicLink
    }

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var formContainerView: UIView!
    private weak var contentLeadingConstraint: NSLayoutConstraint?
    private weak var contentTrailingConstraint: NSLayoutConstraint?

    @IBOutlet private weak var labelTitle: UILabel!

    @IBOutlet private weak var textUsername: BorderedTextField!

    @IBOutlet private weak var textPassword: BorderedTextField!

    @IBOutlet private weak var buttonLogin: PIAButton!

    @IBOutlet private weak var couldNotGetPlanButton: UIButton!

    @IBOutlet private weak var loginWithReceipt: UIButton!

    @IBOutlet private weak var loginWithLink: UIButton!

    private var config: Config!

    private weak var delegate: PIAWelcomeViewControllerDelegate?

    private var isLogging = false

    private var timeToRetryCredentials: TimeInterval? = nil
    private var timeToRetryReceipt: TimeInterval? = nil
    private var timeToRetryMagicLink: TimeInterval? = nil

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func with(config: Config) -> LoginViewController {
        let vc = StoryboardScene.Welcome.loginViewController.instantiate()
        vc.config = config
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(config != nil, "Config not propagated to LoginViewController")

        NotificationCenter.default.addObserver(self, selector: #selector(finishLoginWithMagicLink(notification:)), name: .PIAFinishLoginWithMagicLink, object: nil)

        labelTitle.text = L10n.Welcome.Login.title
        textUsername.placeholder = L10n.Welcome.Login.Username.placeholder
        textPassword.placeholder = L10n.Welcome.Login.Password.placeholder

        textUsername.accessibilityIdentifier = Accessibility.Id.Login.username
        textPassword.accessibilityIdentifier = Accessibility.Id.Login.password

        textUsername.text = config.loginUsername
        textPassword.text = config.loginPassword

        styleButtons()
        setupReadableWidthConstraints()
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
        var preset = Preset()
        preset.loginUsername = config.loginUsername
        preset.loginPassword = config.loginPassword

        switch segue.identifier {
        case StoryboardSegue.Welcome.restoreLoginPurchaseSegue.rawValue:
            preset.pages = .restore
        case StoryboardSegue.Welcome.expiredAccountPurchaseSegue.rawValue:
            preset.isExpired = true
            preset.pages = .purchase
        default:
            break
        }
        vc.preset = preset
    }

    private func setupReadableWidthConstraints() {
        guard contentLeadingConstraint == nil && contentTrailingConstraint == nil else { return }
        guard let parentView = formContainerView.superview else { return }
        let readableGuide = parentView.readableContentGuide
        let leading = formContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: readableGuide.leadingAnchor)
        let trailing = formContainerView.trailingAnchor.constraint(lessThanOrEqualTo: readableGuide.trailingAnchor)
        NSLayoutConstraint.activate([leading, trailing])
        contentLeadingConstraint = leading
        contentTrailingConstraint = trailing
    }

    // MARK: Actions
    @IBAction private func logInWithLink(_ sender: Any?) {
        if let timeUntilNextTry = timeToRetryMagicLink?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Welcome.Login.Error.throttled("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }

        let storyboard = UIStoryboard(name: "Welcome", bundle: Bundle.main)
        if let magicLinkLoginViewController = storyboard.instantiateViewController(withIdentifier: "MagicLinkLoginViewController") as? MagicLinkLoginViewController {
            let alert = Macros.alert(magicLinkLoginViewController)
            alert.addCancelAction(L10n.Signup.Purchase.Uncredited.Alert.Button.cancel)
            alert.addActionWithTitle(
                L10n.Welcome.Login.Magic.Link.send.uppercased(),
                handler: {
                    let email = magicLinkLoginViewController.email().trimmed()
                    self.loginUsingMagicLink(email: email)
                })
            present(alert, animated: true, completion: nil)
        }

    }

    private func loginUsingMagicLink(email: String) {
        do {
            try Validator.validate(email: email)
        } catch {
            Macros.displayImageNote(
                withImage: Asset.Images.iconWarning.image,
                message: error.errorMessage
            )
            return
        }

        guard !self.isLogging else {
            return
        }

        self.showLoadingAnimation()
        self.config.accountProvider.loginUsingMagicLink(
            withEmail: email,
            { error in

                self.hideLoadingAnimation()
                guard error == nil else {
                    self.handleLoginFailed(error, loginOption: .magicLink)
                    return
                }

                Macros.displaySuccessImageNote(
                    withImage: Asset.Images.iconWarning.image,
                    message: L10n.Welcome.Login.Magic.Link.response
                )
            })
    }

    @objc private func finishLoginWithMagicLink(notification: Notification) {

        if let userInfo = notification.userInfo, let _ = userInfo[NotificationKey.error] as? Error {
            displayErrorMessage(errorMessage: L10n.Welcome.Purchase.Error.Connectivity.title)
            return
        }

        config.completionDelegate?.welcomeDidLogin(
            withUser: UserAccount(
                credentials: Credentials(username: "", password: ""),
                info: nil
            ),
            topViewController: self
        )
    }

    @IBAction private func logInWithReceipt(_ sender: Any?) {
        if let timeUntilNextTry = timeToRetryReceipt?.timeSinceNow() {
            displayErrorMessage(errorMessage: L10n.Welcome.Login.Error.throttled("\(Int(timeUntilNextTry))"), displayDuration: timeUntilNextTry)
            return
        }

        guard !isLogging else {
            return
        }

        Client.store.refreshPaymentReceipt { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                guard let receipt = Client.store.paymentReceipt else {
                    return
                }

                let request = LoginReceiptRequest(receipt: receipt)

                self.prepareLogin()
                self.config.accountProvider.login(with: request) { userAccount, error in
                    self.handleLoginResult(user: userAccount, error: error, loginOption: .receipt)
                }
            }
        }
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
        config.accountProvider.login(with: request) { [weak self] userAccount, error in
            self?.handleLoginResult(user: userAccount, error: error, loginOption: .credentials)
        }
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
        Macros.displayImageNote(
            withImage: Asset.Images.iconWarning.image,
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

        config.completionDelegate?.welcomeDidLogin(withUser: user, topViewController: self)
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
        if let error {
            log.error("Failed to log in: \(error)")
            switch error as? ClientError {
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

            case .badReceipt:
                handleBadReceipt()
                return

            case .internetUnreachable:
                errorMessage = L10n.Global.unreachable

            case let .libraryError(message):
                let message = message ?? error.localizedDescription
                log.error("Account library error: \(message)")
                // we shouldn't show this message to the user since this is an internal error
                errorMessage = L10n.Signup.Failure.internal(Int(AccountRequestError.internalErrorCode))

            case let .unknown(code, message):
                let message = message ?? error.localizedDescription
                errorMessage = L10n.Signup.Failure.unknown(message, code)

            default:
                errorMessage = error.localizedDescription
            }
        }
        displayErrorMessage(errorMessage: errorMessage, displayDuration: displayDuration)
    }

    private func displayErrorMessage(errorMessage: String?, displayDuration: Double? = nil) {

        Macros.displayImageNote(
            withImage: Asset.Images.iconWarning.image,
            message: errorMessage ?? L10n.Welcome.Login.Error.title, andDuration: displayDuration,
            accessbilityIdentifier: Accessibility.Id.Login.Error.banner)
    }

    private func handleExpiredAccount() {
        perform(segue: StoryboardSegue.Welcome.expiredAccountPurchaseSegue, sender: self)
    }

    private func handleBadReceipt() {
        let alert = Macros.alert(
            L10n.Account.Restore.Failure.title,
            L10n.Account.Restore.Failure.message
        )
        alert.addDefaultAction(L10n.Global.close)
        present(alert, animated: true, completion: nil)
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
        buttonLogin.setTitle(
            L10n.Welcome.Login.submit.uppercased(),
            for: [])
        buttonLogin.accessibilityIdentifier = Accessibility.Id.Login.submit

        couldNotGetPlanButton.setTitle(
            L10n.Welcome.Login.Restore.button,
            for: [])
        couldNotGetPlanButton.titleLabel?.numberOfLines = 0
        couldNotGetPlanButton.titleLabel?.textAlignment = .center

        loginWithReceipt.setTitle(
            L10n.Welcome.Login.Receipt.button,
            for: [])
        loginWithReceipt.titleLabel?.numberOfLines = 0
        loginWithReceipt.titleLabel?.textAlignment = .center

        loginWithLink.setTitle(
            L10n.Welcome.Login.Magic.Link.title,
            for: [])
        loginWithLink.titleLabel?.numberOfLines = 0
        loginWithLink.titleLabel?.textAlignment = .center
    }

    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController) {
        config.completionDelegate?.welcomeDidSignup(withUser: user, topViewController: topViewController)
    }

    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController) {
        config.completionDelegate?.welcomeDidLogin(withUser: user, topViewController: topViewController)
    }

    override func showLoadingAnimation() {
        // Don't call parent class
        buttonLogin.isLoading = true
    }

    override func hideLoadingAnimation() {
        // Don't call parent class
        buttonLogin.isLoading = false
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

extension LoginViewController {
    struct Config {
        let loginUsername: String?
        let loginPassword: String?
        let accountProvider: AccountProvider
        weak var completionDelegate: WelcomeCompletionDelegate?
    }
}
