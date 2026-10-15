//
//  WelcomeBackCoordinator.swift
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
import PIALibrary
import PIAPaywall
import UIKit

/// Runs the welcome-back flow: the screen offered to a returning customer whose App Store account
/// still holds a live subscription. It is pushed over the paywall, and hands the flow on itself —
/// through `showLogin`, `showPaywall`, or, once the receipt has signed the customer in, its output.
final class WelcomeBackCoordinator: FlowCoordinator {

    enum Output {
        case didAuthenticate(user: UserAccount)
    }

    private weak var navigationController: UINavigationController?
    private let accountProvider: AccountProvider
    private let store: InAppProvider
    private let showLogin: @MainActor () -> Void
    private let showPaywall: @MainActor () -> Void

    private let subject = PassthroughSubject<Output, Never>()

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    init(
        navigationController: UINavigationController,
        accountProvider: AccountProvider,
        store: InAppProvider,
        showLogin: @escaping @MainActor () -> Void,
        showPaywall: @escaping @MainActor () -> Void
    ) {
        self.navigationController = navigationController
        self.accountProvider = accountProvider
        self.store = store
        self.showLogin = showLogin
        self.showPaywall = showPaywall
    }

    // MARK: Coordinator

    func start() {
        Task { @MainActor [weak self] in
            await self?.presentIfEntitled()
        }
    }

    // MARK: Flow

    @MainActor
    private func presentIfEntitled() async {
        let currentReceipt = GetCurrentSubscriptionReceiptUseCase(store: store)
        // Only over the bare paywall; the user may have moved on while the receipt was read.
        guard await currentReceipt() != nil,
              navigationController?.viewControllers.last is SignupPaywallHostingController
        else {
            handle(.didDismiss)
            return
        }

        let host = WelcomeBackHostingController(
            rootView: WelcomeBackView(
                dependencies: .live(
                    accountProvider: accountProvider,
                    store: store,
                    emit: { [weak self] output in
                        self?.handle(output)
                    }
                )
            )
        )
        if let navigationController {
            navigationController.pushViewController(host, animated: true)
        } else {
            handle(.didDismiss)
        }
    }

    @MainActor
    private func handle(_ output: WelcomeBack.Output) {
        switch output {
        case .didAuthenticate(let user):
            subject.send(.didAuthenticate(user: user))
            subject.send(completion: .finished)

        case .requestLogin:
            showLogin()
            // don't finish yet, user can come back

        case .didDismiss:
            subject.send(completion: .finished)
            showPaywall()
        }
    }
}
