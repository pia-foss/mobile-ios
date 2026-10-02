//
//  ValidateQRLoginCoordinator.swift
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
import PIAValidateQRLogin
import SwiftUI
import UIKit

final class ValidateQRLoginCoordinator: @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?
    private weak var host: UIViewController?
    private let qrToken: String
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController, qrToken: String) {
        self.presenter = presenter
        self.qrToken = qrToken
    }

    @MainActor
    func start() {
        guard let presenter else {
            subject.send(completion: .finished)
            return
        }

        let view = ValidateQRLoginView(
            dependencies: .live(
                qrToken: qrToken,
                accountAPI: Client.nativeAccountAPI,
                discardQRToken: { Client.configuration.tvOSBindToken = nil },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let host = UIHostingController(rootView: view)
        host.modalPresentationStyle = .fullScreen
        self.host = host
        presenter.present(host, animated: true)
    }

    @MainActor
    private func handle(_ output: ValidateQRLogin.Output) {
        switch output {
        case .dismiss:
            host?.dismiss(animated: true) { [subject] in
                subject.send(completion: .finished)
            }
        }
    }
}
