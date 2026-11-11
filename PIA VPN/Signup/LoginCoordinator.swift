//
//  LoginCoordinator.swift
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
import CoreArchitecture
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import PIALogin
import UIKit

private let log = PIALogger.logger(for: LoginCoordinator.self)

/// Pushes the login screen and the restore screen behind it, and reports once the customer is
/// signed in.
///
/// The expired-account purchase screen and the signup-in-progress screen are still UIKit; they
/// report back through `PIAWelcomeViewControllerDelegate` and `WelcomeCompletionDelegate`.
final class LoginCoordinator: @MainActor FlowCoordinator {

    enum Output {
        case didAuthenticate(user: UserAccount, isSignup: Bool, topViewController: UIViewController)
    }

    private weak var navigationController: UINavigationController?
    private weak var host: BrandedHostingController<LoginView>?
    private let accountProvider: AccountProvider
    private let store: InAppProvider
    private let subject = PassthroughSubject<Output, Never>()

    private var magicLinkContinuation: AsyncStream<String>.Continuation?
    /// A token that arrived before the screen started listening.
    private var pendingMagicLinkToken: String?

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    init(navigationController: UINavigationController, accountProvider: AccountProvider, store: InAppProvider) {
        self.navigationController = navigationController
        self.accountProvider = accountProvider
        self.store = store
    }

    // MARK: Coordinator

    @MainActor
    func start() {
        guard let navigationController else {
            subject.send(completion: .finished)
            return
        }

        let preset = AppConfiguration.Welcome.defaultPreset()
        let store = store
        let view = LoginView(
            initialState: .init(username: preset.loginUsername ?? "", password: preset.loginPassword ?? ""),
            dependencies: .live(
                accountProvider: accountProvider,
                currentReceipt: {
                    if let error = await store.synchronizeEntitlements() {
                        log.warning("Entitlements sync failed, checking cached entitlements: \(error)")
                    }
                    guard let jws = await store.currentSubscriptionReceipt()?.jws else { return nil }
                    return LoginReceiptRequest(receipt: jws)
                },
                magicLinkTokens: { [weak self] in
                    self?.makeMagicLinkTokens() ?? AsyncStream { $0.finish() }
                },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let host = BrandedHostingController(rootView: view)
        host.onFinish = { [subject] in subject.send(completion: .finished) }
        self.host = host
        navigationController.pushViewController(host, animated: true)
    }

    /// Signs in with the token from a magic-link deep link.
    @MainActor
    func handleMagicLink(token: String) {
        // Kept for the next subscription when the screen is between streams.
        if case .enqueued = magicLinkContinuation?.yield(token) { return }
        pendingMagicLinkToken = token
    }

    /// Whether the login screen is still somewhere in the navigation stack.
    @MainActor
    var isInNavigationStack: Bool {
        guard let host, let navigationController else { return false }
        return navigationController.viewControllers.contains(host)
    }

    /// Brings the login screen back to the top, if something was pushed over it.
    @MainActor
    func showLogin() {
        guard isInNavigationStack, let host, let navigationController, navigationController.topViewController !== host
        else { return }
        navigationController.popToViewController(host, animated: true)
    }

    // MARK: Screen output

    @MainActor
    private func handle(_ output: Login.Output) {
        switch output {
        case .didLogin(let user):
            guard let topViewController = host ?? navigationController else { return }
            subject.send(.didAuthenticate(user: user, isSignup: false, topViewController: topViewController))

        case .accountExpired:
            showExpiredPurchase()

        case .restorePurchaseRequested:
            showRestoreSignup()

        case .showError(let message, let duration):
            showError(message, duration: duration)

        case .showMessage(let message):
            Macros.displaySuccessImageNote(withImage: Asset.iconWarning.image, message: message)
        }
    }

    @MainActor
    private func handle(_ output: RestoreSignup.Output) {
        switch output {
        case .didRestore(let email):
            showSignupInProgress(email: email)

        case .showError(let message):
            showError(message, duration: nil)
        }
    }

    @MainActor
    private func showError(_ message: String, duration: TimeInterval?) {
        Macros.displayImageNote(
            withImage: Asset.iconWarning.image,
            message: message,
            andDuration: duration,
            accessbilityIdentifier: Accessibility.Id.Login.Error.banner
        )
    }

    // MARK: Magic link

    /// The screen subscribes again each time it appears, so every call starts a fresh stream.
    @MainActor
    private func makeMagicLinkTokens() -> AsyncStream<String> {
        magicLinkContinuation?.finish()
        let (stream, continuation) = AsyncStream.makeStream(of: String.self, bufferingPolicy: .bufferingNewest(1))
        magicLinkContinuation = continuation
        if let pendingMagicLinkToken {
            continuation.yield(pendingMagicLinkToken)
            self.pendingMagicLinkToken = nil
        }
        return stream
    }

    // MARK: Destinations

    /// "Didn't receive account details?" — re-sends them for a purchase whose signup never finished.
    @MainActor
    private func showRestoreSignup() {
        let accountProvider = accountProvider
        let view = RestoreSignupView(
            initialState: .init(email: AppConfiguration.Welcome.defaultPreset().purchaseEmail ?? ""),
            dependencies: .live(
                restorePurchases: {
                    guard case .failure(let error) = await accountProvider.restorePurchases() else { return nil }
                    return error
                },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        navigationController?.pushViewController(BrandedHostingController(rootView: view), animated: true)
    }

    /// Creates the account for the restored purchase, as the old `SignupViaRestoreSegue` did.
    @MainActor
    private func showSignupInProgress(email: String) {
        let navigation = StoryboardScene.Signup.initialScene.instantiate()
        guard let controller = navigation.topViewController as? SignupInProgressViewController else {
            log.error("Signup storyboard did not produce a SignupInProgressViewController")
            return
        }

        var metadata = SignupMetadata(email: email)
        metadata.title = L10n.Signup.InProgress.title
        metadata.bodySubtitle = L10n.Signup.InProgress.message
        controller.config = .init(
            metadata: metadata,
            accountProvider: accountProvider,
            signupRequest: SignupRequest(email: email),
            completionDelegate: self
        )

        navigation.modalPresentationStyle = .fullScreen
        navigationController?.present(navigation, animated: true)
    }

    /// The legacy purchase screen for an expired account.
    @MainActor
    private func showExpiredPurchase() {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.pages = .purchase
        preset.isExpired = true
        preset.shouldRecoverPendingSignup = false

        let controller = StoryboardScene.Welcome.piaWelcomeViewController.instantiate()
        controller.preset = preset
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - PIAWelcomeViewControllerDelegate

extension LoginCoordinator: PIAWelcomeViewControllerDelegate {
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

// MARK: - WelcomeCompletionDelegate

/// How the signup-in-progress screen reports back after a restore.
extension LoginCoordinator: WelcomeCompletionDelegate {
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController) {
        subject.send(.didAuthenticate(user: user, isSignup: false, topViewController: topViewController))
    }

    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController) {
        subject.send(.didAuthenticate(user: user, isSignup: true, topViewController: topViewController))
    }
}
