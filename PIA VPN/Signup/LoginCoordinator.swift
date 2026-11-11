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
import PIALogin
import UIKit

private let log = PIALogger.logger(for: LoginCoordinator.self)

/// Pushes the login screen and reports once the customer is signed in.
///
/// The expired-account and restore screens reachable from it are still the UIKit welcome flow;
/// they report back through `PIAWelcomeViewControllerDelegate`.
final class LoginCoordinator: @MainActor FlowCoordinator {

    enum Output {
        case didAuthenticate(user: UserAccount, isSignup: Bool, topViewController: UIViewController)
    }

    private weak var navigationController: UINavigationController?
    private weak var host: LoginHostingController?
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
        let host = LoginHostingController(rootView: view)
        host.onFinish = { [subject] in subject.send(completion: .finished) }
        self.host = host
        navigationController.pushViewController(host, animated: true)
    }

    /// Signs in with the token from a magic-link deep link.
    @MainActor
    func handleMagicLink(token: String) {
        if let magicLinkContinuation {
            magicLinkContinuation.yield(token)
        } else {
            pendingMagicLinkToken = token
        }
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
            showWelcome(pages: .purchase, isExpired: true)

        case .restorePurchaseRequested:
            showWelcome(pages: .restore, isExpired: false)

        case .showError(let message, let duration):
            Macros.displayImageNote(
                withImage: Asset.iconWarning.image,
                message: message,
                andDuration: duration,
                accessbilityIdentifier: Accessibility.Id.Login.Error.banner
            )

        case .showMessage(let message):
            Macros.displaySuccessImageNote(withImage: Asset.iconWarning.image, message: message)
        }
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

    /// The legacy purchase (expired account) and restore screens.
    @MainActor
    private func showWelcome(pages: Pages, isExpired: Bool) {
        var preset = AppConfiguration.Welcome.defaultPreset()
        preset.pages = pages
        preset.isExpired = isExpired
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
