//
//  PaywallState.swift
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

/// The whole paywall in one value.
public struct PaywallState: Equatable {
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
    public var isEligibleForIntroOffer: Bool

    /// The plan the main screen sells. Not changed by the sheet.
    public var defaultPlan: PaywallPlanID

    /// The plan highlighted inside the sheet. Reset every time the sheet opens and thrown away when
    /// it closes — "Maybe Later" is a plain dismissal, so nothing carries back to the main screen.
    public var sheetSelection: PaywallPlanID

    public var isPlanSheetPresented: Bool
    public var alert: AlertKind?
    public var layout: PaywallLayout

    /// `true` when the paywall was presented modally and can be dismissed, or when the wide layout
    /// shows its corner close button.
    public var isDismissable: Bool

    public init(
        phase: Phase = .loadingProducts,
        activity: Activity = .idle,
        offers: [PaywallPlanID: PaywallOffer] = [:],
        isEligibleForIntroOffer: Bool = false,
        defaultPlan: PaywallPlanID = .yearly,
        sheetSelection: PaywallPlanID = .yearly,
        isPlanSheetPresented: Bool = false,
        alert: AlertKind? = nil,
        layout: PaywallLayout = .compact,
        isDismissable: Bool = false
    ) {
        self.phase = phase
        self.activity = activity
        self.offers = offers
        self.isEligibleForIntroOffer = isEligibleForIntroOffer
        self.defaultPlan = defaultPlan
        self.sheetSelection = sheetSelection
        self.isPlanSheetPresented = isPlanSheetPresented
        self.alert = alert
        self.layout = layout
        self.isDismissable = isDismissable
    }
}
