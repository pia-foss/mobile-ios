//
//  AddEmailCoordinator.swift
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
import PIAAccountDetails
import PIALibrary
import SwiftUI
import UIKit

/// Presents the add email screen full screen, with no way to close it until the email is set or
/// the person logs out.
final class AddEmailCoordinator: @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?
    private weak var host: UIViewController?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    @MainActor
    func start() {
        // Something else is on screen (e.g. the region picker): the next check asks again.
        guard let presenter, presenter.presentedViewController == nil else {
            subject.send(completion: .finished)
            return
        }

        let accountProvider = Client.providers.accountProvider
        let view = AddEmailView(
            email: accountProvider.currentUser?.info?.email,
            dependencies: .live(
                accountProvider: accountProvider,
                temporaryPassword: { Client.configuration.tempAccountPassword },
                clearTemporaryPassword: { Client.configuration.tempAccountPassword = "" },
                storedAppleIDEmail: { Client.preferences.signInWithAppleFakeEmail },
                storeAppleIDEmail: { email in
                    let preferences = Client.preferences.editable()
                    preferences.signInWithAppleFakeEmail = email
                    preferences.commit()
                },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let host = AddEmailHostingController(rootView: view)
        host.modalPresentationStyle = .fullScreen
        host.isModalInPresentation = true
        // Finishes however the screen leaves, including when something else tears down the modal
        // stack, so `startAsync()` never waits forever.
        host.onDismissed = { [subject] in subject.send(completion: .finished) }
        self.host = host
        presenter.present(host, animated: true)
    }

    @MainActor
    private func handle(_ output: AddEmail.Output) {
        guard let host else {
            subject.send(completion: .finished)
            return
        }
        switch output {
        case .finished:
            host.dismiss(animated: true)
        case .loggedOut:
            host.dismiss(animated: true) {
                AppPreferences.shared.reset()
            }
        }
    }
}

private final class AddEmailHostingController: UIHostingController<AddEmailView> {
    var onDismissed: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Not when it is merely covered, e.g. by the Sign in with Apple sheet.
        guard isBeingDismissed else { return }
        onDismissed?()
        onDismissed = nil
    }
}
