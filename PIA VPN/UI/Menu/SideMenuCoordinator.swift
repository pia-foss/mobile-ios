//
//  SideMenuCoordinator.swift
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
import PIASideMenu
import SwiftUI
import UIKit

private let log = PIALogger.logger(for: SideMenuCoordinator.self)

/// Owns the sidebar column of the main split view. Opens websites and the subscription sheet itself,
/// and reports the screens to open over the dashboard upward.
@MainActor
final class SideMenuCoordinator: @MainActor FlowCoordinator {
    enum Output {
        case show(SideMenu.Destination)
        case upgradeTrial
    }

    private weak var split: UISplitViewController?
    private let subject = PassthroughSubject<Output, Never>()

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    init(split: UISplitViewController) {
        self.split = split
    }

    func start() {
        let view = SideMenuView(
            version: Macros.localizedVersionFullString() ?? "",
            dependencies: .live(
                accountProvider: Client.providers.accountProvider,
                purchase: { await Client.providers.accountProvider.purchase(plan: $0) },
                canManageSubscription: { SubscriptionManagementUtil.canManageSubscription(for: $0) },
                logout: { await Self.logout() },
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let nav = UINavigationController(rootViewController: UIHostingController(rootView: view))
        nav.setNavigationBarHidden(true, animated: false)
        split?.setViewController(nav, for: .primary)
    }

    private func handle(_ output: SideMenu.Output) {
        switch output {
        case .show(let destination):
            hideOverlay()
            subject.send(.show(destination))
        case .upgradeTrial:
            hideOverlay()
            subject.send(.upgradeTrial)
        case .open(let website):
            UIApplication.shared.open(website.url)
        case .manageSubscription:
            guard let windowScene = split?.view.window?.windowScene else {
                log.error("Unable to get window scene for manage subscriptions")
                return
            }
            Task { await SubscriptionManagementUtil.openManageSubscription(in: windowScene) }
        }
    }

    /// A screen opening over the dashboard must not open under the sidebar overlay.
    private func hideOverlay() {
        guard let split, split.displayMode == .oneOverSecondary else { return }
        split.hide(.primary)
    }

    private static func logout() async {
        log.debug("Account: Logging out...")
        await withCheckedContinuation { continuation in
            Client.providers.accountProvider.logout { error in
                if let error {
                    log.error("Unable to log out: \(error)")
                } else {
                    AppPreferences.shared.reset()
                }
                continuation.resume()
            }
        }
    }
}

extension SideMenu.Website {
    fileprivate var url: URL {
        switch self {
        case .home: AppConstants.Web.homeURL
        case .support: AppConstants.Web.supportURL
        case .privacy: AppConstants.Web.privacyURL
        }
    }
}
