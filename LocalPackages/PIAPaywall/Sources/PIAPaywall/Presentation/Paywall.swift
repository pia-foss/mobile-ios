//
//  Paywall.swift
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

public enum Paywall {}

extension Paywall {

    /// The whole paywall in one value.
    public struct State: Equatable {
        public enum Phase: Equatable {
            /// Prices have not arrived. The layout renders with redacted price text.
            case loadingProducts
            /// At least one purchasable plan is available.
            case ready
            /// Nothing can be sold right now. Restore and Log In still work.
            case productsUnavailable
        }

        /// One in-flight operation at a time.
        ///
        /// A single enum rather than separate `isPurchasing` / `isRestoring` flags. The old paywall had
        /// two booleans, only checked one of them, and could start a purchase and a restore
        /// simultaneously.
        public enum Activity: Equatable {
            case idle
            case purchasing
            case restoring
        }

        public enum AlertKind: String, Equatable, Identifiable {
            /// The App Store account already owns a subscription — offer Restore instead of buying twice.
            case existingEntitlement
            /// Restore found nothing to restore.
            case nothingToRestore
            /// Restore found a receipt but signing in with it failed.
            case restoreFailed

            public var id: String { rawValue }
        }

        public var phase: Phase
        public var activity: Activity
        public var offers: [PaywallPlanID: PaywallOffer]

        /// Whether the App Store says this account can still take an introductory offer.
        ///
        /// Captured when the offers load and then left alone: re-deciding mid-session would swap the
        /// call to action from "Start My Free Trial" to "Subscribe" under the customer's finger.
        public var trialOffer: PaywallTrialOffer?

        /// The plan the main screen sells. Not changed by the sheet.
        public var defaultPlan: PaywallPlanID

        /// The plan highlighted inside the sheet. Reset every time the sheet opens and thrown away when
        /// it closes — "Maybe Later" is a plain dismissal, so nothing carries back to the main screen.
        public var sheetSelection: PaywallPlanID

        public var isPlanSheetPresented: Bool
        public var alert: AlertKind?
        public var layout: PaywallLayout

        public init(
            phase: Phase = .loadingProducts,
            activity: Activity = .idle,
            offers: [PaywallPlanID: PaywallOffer] = [:],
            trialOffer: PaywallTrialOffer? = nil,
            defaultPlan: PaywallPlanID = .yearly,
            sheetSelection: PaywallPlanID = .yearly,
            isPlanSheetPresented: Bool = false,
            alert: AlertKind? = nil,
            layout: PaywallLayout = .compact,
        ) {
            self.phase = phase
            self.activity = activity
            self.offers = offers
            self.trialOffer = trialOffer
            self.defaultPlan = defaultPlan
            self.sheetSelection = sheetSelection
            self.isPlanSheetPresented = isPlanSheetPresented
            self.alert = alert
            self.layout = layout
        }
    }

    /// Everything that can happen to the paywall, from the customer or from the App Store.
    ///
    /// `Equatable`, so reducer tests stay plain value comparisons. The transaction and the user account
    /// produced by a purchase or a restore are neither `Equatable` nor `Sendable`, so each rides on its
    /// action inside a box compared by identity.
    public enum Action: Equatable {
        /// Which surface a purchase was started from, so the reducer knows which plan to buy.
        public enum PurchaseSource: Equatable {
            case mainScreen
            case planSheet
        }

        /// A purchased transaction, compared by `identifier`.
        public struct Transaction: Equatable {
            public let value: any InAppTransaction

            public var isExpired: Bool { value.isExpired }

            public init(_ value: any InAppTransaction) {
                self.value = value
            }

            public static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.value.identifier == rhs.value.identifier
            }
        }

        /// A restored account, compared by username.
        public struct Account: Equatable {
            public let value: UserAccount

            public init(_ value: UserAccount) {
                self.value = value
            }

            public static func == (lhs: Self, rhs: Self) -> Bool {
                lhs.value.credentials.username == rhs.value.credentials.username
            }
        }

        case onAppear
        case disappeared
        case layoutChanged(PaywallLayout)
        case offersResponse(Result<OffersPayload, PaywallError>)
        case retryTapped

        case seeOtherPlansTapped
        case planSheetDismissed
        case planSelected(PaywallPlanID)

        case purchaseTapped(source: PurchaseSource)
        case purchaseIntentReceived(AppStoreProduct)
        case existingEntitlementFound
        case purchaseSucceeded(Transaction)
        case purchaseFailed(PaywallError)

        case restoreTapped
        case restoreSucceeded(Account)
        case restoreFailedNothingToRestore
        case restoreFailedBadReceipt

        case alertDismissed
        case alertRestoreConfirmed

        case loginTapped
    }

    /// Everything the paywall needs from the outside world, as closures.
    ///
    /// This is the `Client.providers` seam from ADR 0007: the reducer never reaches for a singleton, and
    /// tests run the whole state machine with no `Client` stack, no StoreKit and no network.
    /// `Paywall+Live` is the only file in this package that names `Client`.
    /// Every closure is `@MainActor`: `InAppTransaction` and `AccountProvider` are not `Sendable`, so
    /// keeping the whole seam on one actor is what lets those values be passed around at all.
    public struct Dependencies {
        /// Fetches the purchasable plans together with the App Store's current intro-offer eligibility.
        public var loadOffers: @MainActor () async -> Result<OffersPayload, PaywallError>

        /// `true` when this App Store account already owns a subscription.
        public var hasExistingEntitlement: @MainActor () async -> Bool

        public var purchase: @MainActor (PurchaseRequest) async -> Result<any InAppTransaction, PaywallError>

        /// Tells the App Store a transaction has been dealt with, so it stops being redelivered.
        public var finishTransaction: @MainActor (any InAppTransaction) async -> Void

        /// Restores a previous purchase and signs in with it.
        public var restore: @MainActor () async -> Result<UserAccount, PaywallError>

        /// Purchases started outside the app, such as from the App Store product page.
        public var purchaseIntents: @MainActor () -> AsyncStream<AppStoreProduct>

        /// Reports an outcome to whoever is hosting the paywall.
        ///
        /// Reporting upward is a side effect like any other, so it is a dependency rather than a
        /// publisher on the store: `Store` is generic and holds nothing of its own.
        public var emit: @MainActor (Output) -> Void

        public init(
            loadOffers: @escaping @MainActor () async -> Result<OffersPayload, PaywallError>,
            hasExistingEntitlement: @escaping @MainActor () async -> Bool,
            purchase: @escaping @MainActor (PurchaseRequest) async -> Result<any InAppTransaction, PaywallError>,
            finishTransaction: @escaping @MainActor (any InAppTransaction) async -> Void,
            restore: @escaping @MainActor () async -> Result<UserAccount, PaywallError>,
            purchaseIntents: @escaping @MainActor () -> AsyncStream<AppStoreProduct>,
            emit: @escaping @MainActor (Output) -> Void
        ) {
            self.loadOffers = loadOffers
            self.hasExistingEntitlement = hasExistingEntitlement
            self.purchase = purchase
            self.finishTransaction = finishTransaction
            self.restore = restore
            self.purchaseIntents = purchaseIntents
            self.emit = emit
        }
    }
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
