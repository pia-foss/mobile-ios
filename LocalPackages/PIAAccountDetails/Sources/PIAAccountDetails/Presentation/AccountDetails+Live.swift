//
//  AccountDetails+Live.swift
//  PIAAccountDetails
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

private let log = PIALogger.logger(for: AccountDetails.Dependencies.self)

// The provider is handed in by the host, so nothing here reaches for `Client`.
extension AccountDetails.Dependencies {

    /// `@MainActor` because `AccountProvider` is not `Sendable`: pinning the adapter to one actor is
    /// what allows it to be captured by the dependency closures at all.
    ///
    /// - Parameters:
    ///   - refreshAccount: Fetches fresh account info, logging out when the session is no longer
    ///     valid. Lives in the app, which owns that logout.
    ///   - restorePurchases: Syncs the purchase history with the App Store
    ///     (`AccountProvider.restorePurchases()`). Passed in rather than called on
    ///     `accountProvider`, because that nonisolated async call can't hop off the main actor with
    ///     a non-`Sendable` provider under Swift 6 checking.
    ///   - canManageSubscription: Whether the App Store subscription sheet supports this plan.
    @MainActor
    public static func live(
        accountProvider: AccountProvider,
        refreshAccount: @MainActor @escaping () -> Void,
        restorePurchases: @MainActor @escaping () async -> Result<Void, any Error>,
        canManageSubscription: @MainActor @escaping (AccountInfo) -> Bool,
        emit: @MainActor @escaping (AccountDetails.Output) -> Void
    ) -> AccountDetails.Dependencies {
        AccountDetails.Dependencies(
            currentAccount: {
                guard let info = accountProvider.currentUser?.info else { return nil }
                return AccountDetails.Account(
                    username: accountProvider.publicUsername ?? "",
                    expiry: info.isExpired ? .expired : .expires(on: info.humanReadableExpirationDate()),
                    canManageSubscription: canManageSubscription(info),
                    isRenewable: info.isRenewable
                )
            },
            refreshAccount: refreshAccount,
            accountUpdates: {
                AsyncStream { continuation in
                    let task = Task {
                        for await _ in NotificationCenter.default.notifications(named: .PIAAccountDidRefresh) {
                            continuation.yield()
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            restorePurchase: {
                // Syncs the receipt with the App Store first, so the renewal redeems the latest one.
                let restored = await restorePurchases()
                return await renew(after: restored) { completion in
                    accountProvider.renew(with: RenewRequest(transaction: nil)) { _, error in
                        completion(error)
                    }
                }
            },
            emit: emit
        )
    }

    /// Redeems the restored receipt to renew the plan.
    ///
    /// - Parameters:
    ///   - restored: How syncing the purchase history with the App Store went. A failure skips the
    ///     renewal.
    ///   - renew: Redeems the receipt, calling back with `nil` on success. The callback may arrive
    ///     on any queue.
    @MainActor
    static func renew(
        after restored: Result<Void, any Error>,
        renew: (@escaping @Sendable ((any Error)?) -> Void) -> Void
    ) async -> AccountDetails.RestoreResult {
        if case .failure(let error) = restored {
            log.error("IAP: Failed to restore payment receipt (error: \(error.localizedDescription))")
            return .failed(message: error.localizedDescription)
        }

        log.debug("IAP: Restored payment receipt, redeeming...")
        return await withCheckedContinuation { continuation in
            renew { error in
                switch error {
                case nil:
                    log.debug("Account: Renewal successfully completed")
                    continuation.resume(returning: .renewed)
                case let clientError as ClientError where clientError == .badReceipt:
                    continuation.resume(returning: .badReceipt)
                case let error?:
                    log.error("Account: Renewal failed (error: \(error.localizedDescription))")
                    continuation.resume(returning: .failed(message: error.localizedDescription))
                }
            }
        }
    }
}
