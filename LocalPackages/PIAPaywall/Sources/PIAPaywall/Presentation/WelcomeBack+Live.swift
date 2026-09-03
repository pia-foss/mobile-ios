//
//  WelcomeBack+Live.swift
//  PIAPaywall
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

import Foundation
import PIALibrary

extension WelcomeBack.Dependencies {

    @MainActor
    public static func live(
        accountProvider: AccountProvider,
        store: InAppProvider,
        emit: @escaping @MainActor (WelcomeBack.Output) -> Void
    ) -> WelcomeBack.Dependencies {
        let currentReceipt = GetCurrentSubscriptionReceiptUseCase(store: store)
        let loginWithReceipt = LoginWithReceiptUseCase(accountProvider: accountProvider)

        return WelcomeBack.Dependencies(
            restore: {
                guard let jws = await currentReceipt() else { return .failure(.nothingToRestore) }
                return await loginWithReceipt(jws)
            },
            emit: emit
        )
    }
}
