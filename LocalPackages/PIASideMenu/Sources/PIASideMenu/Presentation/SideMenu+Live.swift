//
//  SideMenu+Live.swift
//  PIASideMenu
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
import PIALocalizations

private let log = PIALogger.logger(for: SideMenu.Dependencies.self)

extension SideMenu.Dependencies {

    /// - Parameters:
    ///   - purchase: Buys `plan` from the App Store (`AccountProvider.purchase(plan:)`). Passed in
    ///     because that nonisolated async call can't take a non-`Sendable` provider off the main actor.
    ///   - canManageSubscription: Whether the App Store subscription sheet supports this plan.
    ///   - logout: Logs out and resets the app's own preferences.
    @MainActor
    public static func live(
        accountProvider: AccountProvider,
        purchase: @MainActor @escaping (Plan) async -> Result<any InAppTransaction, ClientError>,
        canManageSubscription: @MainActor @escaping (AccountInfo) -> Bool,
        logout: @MainActor @escaping () async -> Void,
        emit: @MainActor @escaping (SideMenu.Output) -> Void
    ) -> Self {
        Self(
            currentAccount: {
                let info = accountProvider.currentUser?.info
                return SideMenu.Account(
                    username: accountProvider.publicUsername ?? "",
                    managedPlan: info.flatMap { canManageSubscription($0) ? $0.plan : nil },
                    expiration: info.flatMap {
                        $0.shouldPresentExpirationAlert ? SideMenu.Expiration(timeLeft: $0.dateComponentsBeforeExpiration) : nil
                    }
                )
            },
            accountUpdates: {
                AsyncStream { continuation in
                    let tasks = [Notification.Name.PIAAccountDidLogin, .PIAAccountDidRefresh].map { name in
                        Task {
                            for await _ in NotificationCenter.default.notifications(named: name) {
                                continuation.yield()
                            }
                        }
                    }
                    continuation.onTermination = { _ in tasks.forEach { $0.cancel() } }
                }
            },
            renew: { await renew(accountProvider: accountProvider, purchase: purchase) },
            logout: logout,
            emit: emit
        )
    }

    /// Buys the plan the user is already on again and redeems the receipt.
    @MainActor
    static func renew(
        accountProvider: AccountProvider,
        purchase: @MainActor (Plan) async -> Result<any InAppTransaction, ClientError>
    ) async -> SideMenu.RenewalResult {
        log.debug("Account: Fetching renewable products...")
        let fallbackPlan: Plan
        switch await renewablePlans(accountProvider) {
        case .success(let plans):
            guard let first = plans.first else {
                return .failed(message: L10n.Menu.Renewal.Message.unavailable)
            }
            fallbackPlan = first
        case .failure(ClientError.renewingTrial):
            log.error("Account: Cannot renew trial account")
            return .trial
        case .failure(ClientError.renewingNonRenewable):
            log.error("Account: Account is not renewable")
            return .nonRenewable
        case .failure(let error):
            return .failed(message: error.localizedDescription)
        }

        let plan = renewalPlan(forProductId: accountProvider.currentUser?.info?.productId) ?? fallbackPlan
        switch await purchase(plan) {
        case .failure(.userCancelled):
            log.debug("User cancelled purchase")
            return .cancelled
        case .failure(let error):
            log.error("IAP: Purchase failed (error: \(error))")
            return .failed(message: error.localizedDescription)
        case .success(let transaction):
            log.debug("Account: Submitting new payment receipt...")
            return await withCheckedContinuation { continuation in
                accountProvider.renew(with: RenewRequest(transaction: transaction)) { user, error in
                    if user == nil {
                        log.error("Account: Failed to submit renewal receipt (error: \(String(describing: error)))")
                        continuation.resume(returning: .failed(message: L10n.Renewal.Failure.message))
                    } else {
                        log.debug("Account: Renewal successfully completed")
                        continuation.resume(returning: .renewed)
                    }
                }
            }
        }
    }

    @MainActor
    private static func renewablePlans(_ accountProvider: AccountProvider) async -> Result<[Plan], any Error> {
        await withCheckedContinuation { continuation in
            accountProvider.listRenewablePlans { plans, error in
                if let plans {
                    continuation.resume(returning: .success(plans))
                } else {
                    continuation.resume(returning: .failure(error ?? ClientError.unexpectedReply))
                }
            }
        }
    }

    /// Legacy product IDs renew as today's plan of the same length.
    static func renewalPlan(forProductId productId: String?) -> Plan? {
        switch productId {
        case AppConstants.InApp.monthlyProductIdentifier,
            AppConstants.LegacyInApp.monthlyOctober2020ProductIdentifier,
            AppConstants.LegacyInApp.monthly2020ProductIdentifier,
            AppConstants.LegacyInApp.monthlySubscriptionProductIdentifier,
            AppConstants.LegacyInApp.monthlyProductIdentifier,
            AppConstants.LegacyInApp.oldMonthlyProductIdentifier:
            .monthly
        case AppConstants.InApp.yearlyProductIdentifier,
            AppConstants.LegacyInApp.yearlyOctober2020ProductIdentifier,
            AppConstants.LegacyInApp.yearly2020ProductIdentifier,
            AppConstants.LegacyInApp.yearlySubscriptionProductIdentifier,
            AppConstants.LegacyInApp.yearlyProductIdentifier,
            AppConstants.LegacyInApp.oldYearlyProductIdentifier:
            .yearly
        default:
            nil
        }
    }
}

extension SideMenu.Expiration {
    init(timeLeft: DateComponents) {
        if let days = timeLeft.day, days > 0 {
            self = .days(days)
        } else if let hours = timeLeft.hour, hours > 0 {
            self = .hours(hours)
        } else {
            self = .underAnHour
        }
    }
}
