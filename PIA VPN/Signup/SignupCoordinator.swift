//
//  SignupCoordinator.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import Combine
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import PIAPaywall
import UIKit

private let log = PIALogger.logger(for: SignupCoordinator.self)

/// Runs the logged-out signup flow: the paywall, and everything reachable from it.
///
/// The paywall itself knows nothing about navigation — it reports what happened through
/// `PaywallOutput` and this coordinator decides what that means. The downstream screens are still
/// the existing UIKit ones; they report back through `WelcomeCompletionDelegate`, which (unlike
/// `PIAWelcomeViewControllerDelegate`) takes a plain `UIViewController` and so can be satisfied by a
/// SwiftUI-hosted flow.
@MainActor
final class SignupCoordinator: NSObject, Coordinator {

    enum Output {
        /// The customer signed up or signed in. `isSignup` distinguishes the two, because an
        /// ephemeral signup has to have its user written back to the account provider.
        case didAuthenticate(user: UserAccount, isSignup: Bool, topViewController: UIViewController)
        /// A modally presented paywall was dismissed without authenticating.
        case didCancel
    }

    private let navigationController: UINavigationController
    private let accountProvider: AccountProvider
    private let isDismissable: Bool

    private let subject = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var store: PaywallStore?

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    /// What the host installs as its root or presents modally. A navigation controller, because the
    /// login and restore screens are pushed onto it.
    var rootViewController: UIViewController { navigationController }

    init(
        accountProvider: AccountProvider,
        isDismissable: Bool,
        navigationController: UINavigationController = UINavigationController()
    ) {
        self.accountProvider = accountProvider
        self.isDismissable = isDismissable
        self.navigationController = navigationController
        super.init()
    }

    // MARK: Coordinator

    func start() {
        let store = PaywallStore(
            initialState: PaywallState(isDismissable: isDismissable),
            dependencies: .live(accountProvider: accountProvider, store: Client.store)
        )
        self.store = store

        store.output
            .sink { [weak self] output in self?.handle(output) }
            .store(in: &cancellables)

        let host = SignupPaywallHostingController(
            rootView: SignupPaywallView(store: store, legal: legalLinks)
        )
        host.paywallDelegate = self

        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([host], animated: false)
    }

    /// Jumps straight to the login screen. Used by the magic-link deep link, which previously
    /// reached into `GetStartedViewController` by name.
    func handleMagicLink() {
        showLogin()
    }

    // MARK: Paywall output

    private func handle(_ output: PaywallOutput) {
        switch output {
        case .requestLogin:
            showLogin()

        case .didPurchase(let transaction):
            showSignupInProgress(with: transaction)

        case .didAuthenticate(let user):
            finish(user: user, isSignup: false)

        case .didCancel:
            subject.send(.didCancel)

        case .showWarning(let message):
            // SwiftEntryKit lives in the app target, so the banner is raised here rather than
            // inside the feature package.
            Macros.displayImageNote(withImage: Asset.Piax.Global.iconWarning.image, message: message)
        }
    }

    private func finish(user: UserAccount, isSignup: Bool) {
        subject.send(
            .didAuthenticate(
                user: user,
                isSignup: isSignup,
                topViewController: navigationController.topViewController ?? navigationController
            )
        )
    }

    // MARK: Destinations

    /// Replaces `LoginAccountSegue`.
    private func showLogin() {
        guard !(navigationController.topViewController is LoginViewController) else { return }

        let controller = LoginViewController.with(
            config: .init(
                loginUsername: nil,
                loginPassword: nil,
                accountProvider: accountProvider,
                completionDelegate: self
            )
        )
        // These screens configure their own back button in `viewWillAppear`, so the bar has to come
        // back before they are pushed.
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.pushViewController(controller, animated: true)
    }

    /// Replaces `signupViaPurchaseSegue`.
    ///
    /// The account's email is deliberately empty: it is collected afterwards, on
    /// `ConfirmVPNPlanViewController`. That is the contract `SignupInProgressViewController` and the
    /// backend already expect.
    private func showSignupInProgress(with transaction: any InAppTransaction) {
        let navigation = StoryboardScene.Signup.initialScene.instantiate()
        guard let controller = navigation.topViewController as? SignupInProgressViewController else {
            log.error("Signup storyboard did not produce a SignupInProgressViewController")
            return
        }

        var metadata = SignupMetadata(email: "")
        metadata.title = L10n.Signup.InProgress.title
        metadata.bodySubtitle = L10n.Signup.InProgress.message

        controller.config = .init(
            metadata: metadata,
            accountProvider: accountProvider,
            signupRequest: SignupRequest(email: "", transaction: transaction),
            completionDelegate: self
        )

        navigation.modalPresentationStyle = .fullScreen
        navigationController.present(navigation, animated: true)
    }

    /// `Client.configuration` stores these as strings. They are compile-time constants in practice,
    /// but a bad value must not take the screen down, so an unparseable one falls back to the
    /// public site rather than force-unwrapping.
    private var legalLinks: PaywallLegalLinks {
        PaywallLegalLinks(
            termsURL: url(from: Client.configuration.tosUrl),
            privacyURL: url(from: Client.configuration.privacyUrl)
        )
    }

    private func url(from string: String) -> URL {
        guard let url = URL(string: string) else {
            log.error("Malformed legal URL: \(string)")
            return AppConstants.Web.homeURL
        }
        return url
    }
}

// MARK: - WelcomeCompletionDelegate

/// How every legacy signup screen reports back.
extension SignupCoordinator: WelcomeCompletionDelegate {
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController) {
        subject.send(.didAuthenticate(user: user, isSignup: false, topViewController: topViewController))
    }

    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController) {
        subject.send(.didAuthenticate(user: user, isSignup: true, topViewController: topViewController))
    }
}

// MARK: - SignupPaywallHostingDelegate

extension SignupCoordinator: SignupPaywallHostingDelegate {
    func signupPaywallHostDidRequestLogin(_ host: SignupPaywallHosting) {
        showLogin()
    }
}
