//
//  AccountDetailsTestDoubles.swift
//  PIAAccountDetailsTests
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

@testable import PIAAccountDetails

@MainActor
final class AccountDetailsDependencySpy {
    var account: AccountDetails.Account? = .stub()
    var restoreResult: AccountDetails.RestoreResult = .renewed
    private(set) var refreshCallCount = 0
    private(set) var restoreCallCount = 0
    private(set) var emittedOutputs: [AccountDetails.Output] = []

    /// Each `yield()` is one account update, as a `.PIAAccountDidRefresh` would be. Buffered, so a
    /// test can yield before the stream effect starts listening.
    let updates: AsyncStream<Void>.Continuation
    private let updateStream: AsyncStream<Void>

    init() {
        (updateStream, updates) = AsyncStream.makeStream()
    }

    func makeDependencies() -> AccountDetails.Dependencies {
        .init(
            currentAccount: { [self] in account },
            refreshAccount: { [self] in refreshCallCount += 1 },
            accountUpdates: { [updateStream] in updateStream },
            restorePurchase: { [self] in
                restoreCallCount += 1
                return restoreResult
            },
            emit: { [self] output in emittedOutputs.append(output) }
        )
    }
}

extension AccountDetails.Account {
    static func stub(
        username: String = "p1234567",
        expiry: Expiry = .expires(on: "October 19, 2027"),
        canManageSubscription: Bool = true,
        isRenewable: Bool = false
    ) -> Self {
        .init(
            username: username,
            expiry: expiry,
            canManageSubscription: canManageSubscription,
            isRenewable: isRenewable
        )
    }
}

struct AccountDetailsTestError: LocalizedError {
    var errorDescription: String? { "Something failed" }
}
