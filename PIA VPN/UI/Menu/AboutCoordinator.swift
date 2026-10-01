//
//  AboutCoordinator.swift
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
import PIAAbout
import PIALibrary
import PIALocalizations
import SwiftUI
import UIKit

final class AboutCoordinator: @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?
    private let subject = PassthroughSubject<Void, Never>()
    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    @MainActor
    func start() {
        let header = "Copyright © \(AppConfiguration.About.copyright) \(AppConfiguration.About.companyName)\n\(L10n.About.app) \(Macros.versionFullString() ?? "")"
        let host = UIHostingController(rootView: AboutFactory.makeAboutView(header: header))
        host.title = L10n.Menu.Item.about

        let close = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in self?.finish() }
        )
        close.accessibilityLabel = L10n.Global.close
        host.navigationItem.leftBarButtonItem = close

        let nav = EscapeNavigationController(rootViewController: host) { [weak self] in self?.finish() }
        Theme.current.applyCustomNavigationBar(nav.navigationBar, withTintColor: nil, andBarTintColors: nil)
        if presenter?.traitCollection.horizontalSizeClass == .regular {
            nav.modalPresentationStyle = .formSheet
            nav.isModalInPresentation = true
        } else {
            nav.modalPresentationStyle = .overFullScreen
        }

        presenter?.present(nav, animated: true)
    }

    @MainActor
    private func finish() {
        presenter?.dismiss(animated: true)
        subject.send(completion: .finished)
    }
}
