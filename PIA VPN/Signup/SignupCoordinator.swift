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
/// `Paywall.Output` and this coordinator decides what that means. The downstream screens are still
/// the existing UIKit ones; they report back through `WelcomeCompletionDelegate`, which (unlike
/// `PIAWelcomeViewControllerDelegate`) takes a plain `UIViewController` and so can be satisfied by a
/// SwiftUI-hosted flow.
@MainActor
final class SignupCoordinator: NSObject, Coordinator {

    enum Output {
        /// The customer signed up or signed in. `isSignup` distinguishes the two, because an
        /// ephemeral signup has to have its user written back to the account provider.
        case didAuthenticate(user: UserAccount, isSignup: Bool, topViewController: UIViewController)
    }

    private let navigationController: UINavigationController
    private let accountProvider: AccountProvider

    private let subject = PassthroughSubject<Output, Never>()

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    /// What the host installs as its root or presents modally. A navigation controller, because the
    /// login and restore screens are pushed onto it.
    var rootViewController: UIViewController { navigationController }

    init(
        accountProvider: AccountProvider,
        navigationController: UINavigationController = UINavigationController()
    ) {
        self.accountProvider = accountProvider
        self.navigationController = navigationController
        super.init()
    }

    // MARK: Coordinator

    func start() {
        let host = SignupPaywallHostingController(
            rootView: SignupPaywallView(
                initialState: Paywall.State(),
                dependencies: .live(
                    accountProvider: accountProvider,
                    store: Client.store,
                    emit: { [weak self] output in
                        self?.handle(output)
                    }
                ),
                legal: legalLinks
            )
        )
        host.paywallDelegate = self

        // The delegate below owns the bar across pushes and pops, so no push site has to; the paywall
        // asserts its own on top of that, because on iOS 15 none of these calls survives layout.
        navigationController.delegate = self
        navigationController.setViewControllers([host], animated: false)

        // Loading the view first is what makes the next line stick: on iOS 15 a bar hidden before this
        // controller's view exists is shown again when that view loads.
        navigationController.loadViewIfNeeded()
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    /// Signs in from a magic-link deep link.
    ///
    /// Replaces the old `AppDelegate` path, which cast the root to `GetStartedViewController` by
    /// name and then slept for a fixed 1000ms hoping the login screen had finished appearing. Here
    /// the push reports when it is actually done, so the sign-in starts at the right moment on any
    /// device speed — and `LoginViewController`, which observes the completion notification, is
    /// guaranteed to be on screen to receive it.
    func handleMagicLink(token: String) {
        showLogin { controller in
            controller.showLoadingAnimation()
            Client.providers.accountProvider.login(with: token) { _, error in
                controller.hideLoadingAnimation()
                var userInfo: [NotificationKey: Any]?
                if let error {
                    userInfo = [.error: error]
                }
                Macros.postNotification(.PIAFinishLoginWithMagicLink, userInfo)
            }
        }
    }

    // MARK: Paywall output

    private func handle(_ output: Paywall.Output) {
        switch output {
        case .requestLogin:
            showLogin()

        case .didPurchase(let transaction):
            showSignupInProgress(with: transaction)

        case .didAuthenticate(let user):
            finish(user: user, isSignup: false)

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
    ///
    /// Pushes `PIAWelcomeViewController` rather than `LoginViewController` directly. `LoginViewController`
    /// styles no navigation bar of its own — it has no `BrandableNavigationBar` conformance and its
    /// `viewShouldRestyle` never touches the bar — so pushing it bare leaves the app's default green
    /// bar and no logo. Its container is what supplies both:
    ///
    /// ```swift
    /// navigationItem.titleView = NavigationLogoView(logo: Theme.current.palette.logo)
    /// Theme.current.applyNavigationBarStyle(to: self)
    /// ```
    ///
    /// Going through the container keeps the login screen pixel-identical to the one this flow
    /// replaced, which is what the ticket scoped.
    ///
    /// - Parameter onPresented: Called once the push has finished, with the screen that is now on
    ///   top. Already-presented is treated as presented.
    private func showLogin(onPresented: ((PIAWelcomeViewController) -> Void)? = nil) {
        if let existing = navigationController.topViewController as? PIAWelcomeViewController {
            onPresented?(existing)
            return
        }

        var preset = Preset()
        preset.pages = .login
        // The pending-signup recovery path is dead — both hosts hard-code it off — and leaving it on
        // would fire a storyboard segue out from under this flow.
        preset.shouldRecoverPendingSignup = false

        let controller = StoryboardScene.Welcome.piaWelcomeViewController.instantiate()
        controller.preset = preset
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)

        guard let onPresented else { return }
        // The transition coordinator reports when the push has actually landed; without it the
        // caller would be guessing with a sleep.
        if let transition = navigationController.transitionCoordinator {
            transition.animate(alongsideTransition: nil) { _ in onPresented(controller) }
        } else {
            onPresented(controller)
        }
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

// MARK: - PIAWelcomeViewControllerDelegate

/// How the pushed login container reports back.
extension SignupCoordinator: PIAWelcomeViewControllerDelegate {
    func welcomeController(
        _ welcomeController: PIAWelcomeViewController,
        didLoginWith user: UserAccount,
        topViewController: UIViewController
    ) {
        subject.send(.didAuthenticate(user: user, isSignup: false, topViewController: topViewController))
    }

    func welcomeController(
        _ welcomeController: PIAWelcomeViewController,
        didSignupWith user: UserAccount,
        topViewController: UIViewController
    ) {
        subject.send(.didAuthenticate(user: user, isSignup: true, topViewController: topViewController))
    }
}

// MARK: - UINavigationControllerDelegate

/// Owns navigation bar visibility for the whole flow.
///
/// The paywall is designed without a bar; everything pushed on top of it needs one. Deciding this
/// per screen — rather than calling `setNavigationBarHidden` at each push site — is what keeps the
/// bar from being left behind on the paywall after a pop, and is the only way to get an interactive
/// swipe-back that the user *cancels* right, since that ends with a different screen on top than the
/// transition announced.
extension SignupCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        applyNavigationBarVisibility(for: viewController, in: navigationController, animated: animated)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Re-asserted once the transition has actually settled, which is what covers a cancelled
        // interactive pop.
        applyNavigationBarVisibility(for: viewController, in: navigationController, animated: false)
    }

    private func applyNavigationBarVisibility(
        for viewController: UIViewController,
        in navigationController: UINavigationController,
        animated: Bool
    ) {
        // Applied even when the flag already agrees: on iOS 15 it reads `true` while the bar is still
        // laid out, so a short-circuit here would skip the call that corrects it.
        let shouldHide = viewController is SignupPaywallHosting
        navigationController.setNavigationBarHidden(shouldHide, animated: animated)
    }
}
