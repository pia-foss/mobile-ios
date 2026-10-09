//
//  ForceUpdateCoordinator.swift
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

import CoreArchitecture
import PIAForceUpdate
import PIALibrary
import SwiftUI
import UIKit

/// Covers the presenter with the blocking force-update screen, replacing whatever it shows.
///
/// Reports nothing upward: the screen stays until the app is updated.
final class ForceUpdateCoordinator: @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    @MainActor
    func start() {
        #if !STAGING
            guard let presenter else { return }

            switch presenter.presentedViewController {
            case is ForceUpdateHostingController:
                return
            case .some:
                // Dismissing from the presenter tears down the whole modal stack above it.
                presenter.dismiss(animated: false) { [weak presenter] in
                    presenter?.present(Self.makeHost(), animated: false)
                }
            case .none:
                presenter.present(Self.makeHost(), animated: false)
            }
        #endif
    }

    @MainActor
    private static func makeHost() -> UIViewController {
        let view = ForceUpdateView(
            dependencies: .live(
                isVPNConnected: { Client.providers.vpnProvider.isVPNConnected },
                uninstallVPNProfiles: { Client.providers.vpnProvider.uninstallAll() },
                openURL: { UIApplication.shared.open($0) }
            )
        )
        let host = ForceUpdateHostingController(rootView: view)
        host.modalPresentationStyle = .fullScreen
        host.isModalInPresentation = true
        return host
    }
}

/// A distinct type, so a second force-update notification can tell the screen is already up.
private final class ForceUpdateHostingController: UIHostingController<ForceUpdateView> {}
