//
//  SignupPaywallView+Preview.swift
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
import SwiftUI

/// Fixtures for the previews and the snapshot tests.
///
/// Deliberately builds the view from a fixed `PaywallState` and dependencies that never resolve, so
/// a rendered paywall is completely deterministic — no StoreKit, no network, no animation.
enum PaywallPreviewFixtures {

    static let legal = PaywallLegalLinks(
        termsURL: URL(string: "https://www.privateinternetaccess.com/pages/terms-of-service")!,
        privacyURL: URL(string: "https://www.privateinternetaccess.com/pages/privacy-policy")!
    )

    static let yearly = PaywallOffer(
        id: .yearly,
        priceString: "$72.98",
        monthlyPriceString: "$6.08",
        accessibleMonthlyPriceString: "6.08 US dollars"
    )

    static let monthly = PaywallOffer(
        id: .monthly,
        priceString: "$16.99",
        monthlyPriceString: "$16.99",
        accessibleMonthlyPriceString: "16.99 US dollars"
    )

    static func state(
        phase: PaywallState.Phase = .ready,
        isEligibleForIntroOffer: Bool = true,
        layout: PaywallLayout = .compact,
        isPlanSheetPresented: Bool = false,
        sheetSelection: PaywallPlanID = .yearly,
        isDismissable: Bool = false
    ) -> PaywallState {
        PaywallState(
            phase: phase,
            offers: phase == .ready ? [.yearly: yearly, .monthly: monthly] : [:],
            isEligibleForIntroOffer: isEligibleForIntroOffer,
            defaultPlan: .yearly,
            sheetSelection: sheetSelection,
            isPlanSheetPresented: isPlanSheetPresented,
            layout: layout,
            isDismissable: isDismissable
        )
    }

    /// Dependencies that never return, so no state transition can race a snapshot.
    @MainActor
    static var inertDependencies: PaywallDependencies {
        PaywallDependencies(
            loadOffers: { await neverReturns() },
            hasExistingEntitlement: { await neverReturns() },
            purchase: { _ in await neverReturns() },
            finishTransaction: { _ in },
            restore: { await neverReturns() }
        )
    }

    private static func neverReturns<T>() async -> T {
        await withCheckedContinuation { (_: CheckedContinuation<T, Never>) in }
    }

    @MainActor
    static func view(_ state: PaywallState) -> SignupPaywallView {
        SignupPaywallView(
            store: PaywallStore(initialState: state, dependencies: inertDependencies),
            legal: legal
        )
    }
}

#Preview("Trial – light") {
    PaywallPreviewFixtures.view(PaywallPreviewFixtures.state())
}

#Preview("Trial – dark") {
    PaywallPreviewFixtures.view(PaywallPreviewFixtures.state())
        .environment(\.colorScheme, .dark)
}

#Preview("No trial") {
    PaywallPreviewFixtures.view(PaywallPreviewFixtures.state(isEligibleForIntroOffer: false))
}

#Preview("Loading") {
    PaywallPreviewFixtures.view(PaywallPreviewFixtures.state(phase: .loadingProducts))
}

#Preview("Products unavailable") {
    PaywallPreviewFixtures.view(PaywallPreviewFixtures.state(phase: .productsUnavailable))
}
