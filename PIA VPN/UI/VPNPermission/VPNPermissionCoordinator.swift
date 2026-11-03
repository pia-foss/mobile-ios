//
//  VPNPermissionCoordinator.swift
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
import MessageUI
import PIALibrary
import PIAVPNPermission
import SwiftUI
import UIKit

/// Presents the VPN permission screen full screen and finishes once the profile is installed.
final class VPNPermissionCoordinator: NSObject, @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?
    private weak var host: UIViewController?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    @MainActor
    func start() {
        guard let presenter else {
            subject.send(completion: .finished)
            return
        }

        let view = VPNPermissionView(
            dependencies: .live(
                obtainPermission: { Client.providers.vpnProvider.obtainVPNPermission($0) },
                canSendMail: { MFMailComposeViewController.canSendMail() },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let host = VPNPermissionHostingController(rootView: view)
        host.modalPresentationStyle = .fullScreen
        host.isModalInPresentation = true
        // Finishes however the screen leaves, including when something else tears down the modal
        // stack (e.g. the force-update screen), so `startAsync()` never waits forever.
        host.onDismissed = { [subject] in subject.send(completion: .finished) }
        self.host = host
        presenter.present(host, animated: true)
    }

    @MainActor
    private func handle(_ output: VPNPermission.Output) {
        switch output {
        case .granted:
            guard let host else {
                subject.send(completion: .finished)
                return
            }
            host.dismiss(animated: true)
        case .contactSupport:
            let composer = MFMailComposeViewController()
            composer.setToRecipients([AppConstants.Web.csEmail])
            composer.mailComposeDelegate = self
            host?.present(composer, animated: true)
        }
    }
}

extension VPNPermissionCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: (any Error)?
    ) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}

private final class VPNPermissionHostingController: UIHostingController<VPNPermissionView> {
    var onDismissed: (() -> Void)?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Not when it is merely covered, e.g. by the mail composer.
        guard isBeingDismissed else { return }
        onDismissed?()
        onDismissed = nil
    }
}
