//
//  PaywallAction.swift
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

/// Everything that can happen to the paywall, from the customer or from the App Store.
///
/// `Equatable` and payload-free where it matters, so reducer tests stay plain value comparisons.
/// The transaction and the user account produced by a purchase or a restore are held by the store
/// and attached when the corresponding `PaywallOutput` is emitted.
public enum PaywallAction: Equatable {
    /// Which surface a purchase was started from, so the reducer knows which plan to buy.
    public enum PurchaseSource: Equatable {
        case mainScreen
        case planSheet
    }

    case none
    case onAppear
    case layoutChanged(PaywallLayout)
    case offersResponse(Result<OffersPayload, PaywallError>)
    case retryTapped

    case seeOtherPlansTapped
    case planSheetDismissed
    case planSelected(PaywallPlanID)

    case purchaseTapped(source: PurchaseSource)
    case purchaseIntentReceived(AppStoreProduct)
    case existingEntitlementFound
    case purchaseSucceeded(isExpired: Bool)
    case purchaseFailed(PaywallError)

    case restoreTapped
    case restoreSucceeded
    case restoreFailedNothingToRestore
    case restoreFailedBadReceipt

    case alertDismissed
    case alertRestoreConfirmed

    case loginTapped
    case closeTapped
}

/// What a successful catalogue load produced.
public struct OffersPayload: Equatable, Sendable {
    public let offers: [PaywallPlanID: PaywallOffer]
    public let trialOffer: PaywallTrialOffer?

    public init(offers: [PaywallPlanID: PaywallOffer], trialOffer: PaywallTrialOffer?) {
        self.offers = offers
        self.trialOffer = trialOffer
    }
}
