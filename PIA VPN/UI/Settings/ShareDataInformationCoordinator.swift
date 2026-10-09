//
//  ShareDataInformationCoordinator.swift
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
import PIAConsent
import SwiftUI
import UIKit

final class ShareDataInformationCoordinator: @MainActor FlowCoordinator {
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

        let view = ConsentFactory.makeReadMoreView(onClose: { [weak self] in self?.dismiss() })
        let host = UIHostingController(rootView: view)
        host.modalPresentationStyle = .fullScreen
        self.host = host
        presenter.present(host, animated: true)
    }

    @MainActor
    private func dismiss() {
        host?.dismiss(animated: true) { [subject] in
            subject.send(completion: .finished)
        }
    }
}
