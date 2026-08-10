//
//  PaywallReducer.swift
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
import PIALocalizations

/// The paywall's entire decision-making, as one pure function.
///
/// No `Client.providers`, no networking, no `Task`, no clock. Given a state and an action it returns
/// the next state and the work to do — which is what makes the purchase rules here provable in a
/// unit test rather than only observable on a device with a sandbox account.
public enum PaywallReducer {

    public static func reduce(into state: inout PaywallState, action: PaywallAction) -> PaywallEffect {
        switch action {

        // MARK: Lifecycle

        case .none:
            return .none

        case .onAppear:
            // it is safe to send these again
            // .observePurchaseIntents recreates the observer
            // .loadOffers returns cached offers
            return .batch([.observePurchaseIntents, .loadOffers])

        case .retryTapped:
            guard state.phase == .productsUnavailable, state.activity == .idle else { return .none }
            state.phase = .loadingProducts
            return .loadOffers

        case .layoutChanged(let layout):
            state.layout = layout
            return .none

        case .offersResponse(.success(let payload)):
            // An empty catalogue is a failure, not an empty success: there is nothing to sell.
            guard !payload.offers.isEmpty else {
                state.phase = .productsUnavailable
                return .none
            }
            state.offers = payload.offers
            state.trialOffer = payload.trialOffer
            state.defaultPlan = payload.offers[.yearly] != nil ? .yearly : .monthly
            state.sheetSelection = state.defaultPlan
            state.phase = .ready
            return .none

        case .offersResponse(.failure):
            // Inline, not a banner: the customer did nothing wrong, and the screen offers a retry.
            state.phase = .productsUnavailable
            return .none

        // MARK: Plan sheet

        case .seeOtherPlansTapped:
            guard state.canPurchase else { return .none }
            state.sheetSelection = state.defaultPlan
            state.isPlanSheetPresented = true
            return .none

        case .planSheetDismissed:
            // "Maybe Later", the close button, the backdrop and the swipe all land here. The
            // selection is discarded: the main screen keeps selling `defaultPlan`.
            state.isPlanSheetPresented = false
            state.sheetSelection = state.defaultPlan
            return .none

        case .planSelected(let plan):
            guard state.offers[plan] != nil else { return .none }
            state.sheetSelection = plan
            return .none

        // MARK: Purchase

        case .purchaseTapped(let source):
            guard state.canPurchase else { return .none }
            let plan = source == .planSheet ? state.sheetSelection : state.defaultPlan
            guard state.offers[plan] != nil else { return .none }
            state.activity = .purchasing
            // A banner or alert would otherwise be hidden behind the sheet.
            state.isPlanSheetPresented = false
            return .checkEntitlementThenPurchase(.plan(plan))

        case .purchaseIntentReceived(let product):
            guard state.canPurchase else { return .none }
            state.activity = .purchasing
            state.isPlanSheetPresented = false
            return .checkEntitlementThenPurchase(.product(product))

        case .existingEntitlementFound:
            state.activity = .idle
            state.alert = .existingEntitlement
            return .none

        case .purchaseSucceeded(isExpired: true):
            // An unfinished, already-expired transaction. Finish it so the App Store stops
            // redelivering it, and do not create an account from it.
            state.activity = .idle
            return .batch([
                .finishPendingTransaction,
                .emit(.showWarning(message: L10n.Signup.Paywall.Error.expiredTransaction))
            ])

        case .purchaseSucceeded(isExpired: false):
            state.activity = .idle
            return .emit(.didPurchase)

        case .purchaseFailed(let error):
            state.activity = .idle
            guard let message = error.userFacingMessage else { return .none }
            return .emit(.showWarning(message: message))

        // MARK: Restore

        case .restoreTapped:
            guard state.canRestore else { return .none }
            state.activity = .restoring
            return .restore

        case .alertRestoreConfirmed:
            state.alert = nil
            guard state.canRestore else { return .none }
            state.activity = .restoring
            return .restore

        case .restoreSucceeded:
            state.activity = .idle
            return .emit(.didAuthenticate)

        case .restoreFailedNothingToRestore:
            state.activity = .idle
            state.alert = .nothingToRestore
            return .none

        case .restoreFailedBadReceipt:
            state.activity = .idle
            state.alert = .restoreFailed
            return .none

        // MARK: Misc

        case .alertDismissed:
            state.alert = nil
            return .none

        case .loginTapped:
            guard state.activity == .idle else { return .none }
            return .emit(.requestLogin)

        case .closeTapped:
            return .emit(.didCancel)
        }
    }
}
