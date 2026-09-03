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
/// still holds a live subscription.
///
/// Decides on its own whether there is a flow to run — `start()` checks for a receipt and reports
/// `.didDismiss` without presenting anything when there is none. It does not decide when it goes
/// away, though: the caller tears it down through `dismiss`, since only the caller knows what comes
/// on screen next.
final class WelcomeBackCoordinator: FlowCoordinator {
    typealias Output = WelcomeBack.Output

    private let presentingViewController: UIViewController
    private let accountProvider: AccountProvider
    private let store: InAppProvider

    private let subject = PassthroughSubject<Output, Never>()

    private weak var hostViewController: UIViewController?

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    init(
        presentingViewController: UIViewController,
        accountProvider: AccountProvider,
        store: InAppProvider
    ) {
        self.presentingViewController = presentingViewController
        self.accountProvider = accountProvider
        self.store = store
    }

    // MARK: FlowCoordinator

    func start() {
        Task { @MainActor [weak self] in
            await self?.presentIfEntitled()
        }
    }

    func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        guard let hostViewController, hostViewController.presentingViewController != nil else {
            completion?()
            return
        }
        presentingViewController.dismiss(animated: animated, completion: completion)
    }

    // MARK: Flow

    @MainActor
    private func presentIfEntitled() async {
        let currentReceipt = GetCurrentSubscriptionReceiptUseCase(store: store)
        guard await currentReceipt() != nil else {
            subject.send(.didDismiss)
            return
        }

        let host = WelcomeBackHostingController(
            rootView: WelcomeBackView(
                dependencies: .live(
                    accountProvider: accountProvider,
                    store: store,
                    emit: { [weak self] output in
                        self?.subject.send(output)
                    }
                )
            )
        )
        host.modalPresentationStyle = .fullScreen
        hostViewController = host
        presentingViewController.present(host, animated: false)
    }
}
