//
//  AccountDetailsCoordinator.swift
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

import PIAAccountDetails
import PIALibrary
import UIKit

private let log = PIALogger.logger(for: AccountDetailsCoordinator.self)

final class AccountDetailsCoordinator: ModalCoordinator<AccountDetailsView> {
    @MainActor
    override func buildContent() -> AccountDetailsView {
        let accountProvider = Client.providers.accountProvider
        return AccountDetailsView(
            dependencies: .live(
                accountProvider: accountProvider,
                refreshAccount: { accountProvider.retrieveAccount() },
                restorePurchases: {
                    await Client.providers.accountProvider.restorePurchases().map { _ in }.mapError { $0 }
                },
                canManageSubscription: { SubscriptionManagementUtil.canManageSubscription(for: $0) },
                emit: { [weak self] in self?.handle($0) }
            )
        )
    }

    // MARK: Outputs

    @MainActor
    private func handle(_ output: AccountDetails.Output) {
        switch output {
        case .manageSubscription:
            guard let windowScene = presenter?.view.window?.windowScene else {
                log.error("Unable to get window scene for manage subscriptions")
                return
            }
            Task {
                await SubscriptionManagementUtil.openManageSubscription(in: windowScene)
            }
        case .deleteAccount:
            let url = AppConstants.Web.deleteAccountUrl
            guard UIApplication.shared.canOpenURL(url) else { return }
            log.debug("Opening delete account help page")
            UIApplication.shared.open(url)
        }
    }
}
