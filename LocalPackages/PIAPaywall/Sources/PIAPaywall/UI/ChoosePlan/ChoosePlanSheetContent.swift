//
//  ChoosePlanSheetContent.swift
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

import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// The plan picker's contents.
///
/// The selection made here is deliberately throwaway: "Maybe Later", the close button, the backdrop
/// and the swipe all discard it, so the main screen keeps selling its default plan.
struct ChoosePlanSheetContent: View {
    @ObservedObject var store: PaywallStore

    var body: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s16) {
            header

            VStack(spacing: PIASpacing.s12) {
                ForEach(PaywallPlanID.allCases, id: \.self) { plan in
                    if store.state.offers[plan] != nil {
                        planCard(for: plan)
                    }
                }
            }

            PaywallDisclaimerView(disclaimer: store.state.sheetDisclaimer)

            VStack(spacing: PIASpacing.s8) {
                Button {
                    store.send(.purchaseTapped(source: .planSheet))
                } label: {
                    Text(store.state.sheetButtonTitle).typography(.button1)
                }
                .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.isPurchasing))
                .disabled(!store.state.canPurchase)
                .accessibilityIdentifier(PaywallAccessibility.sheetSubscribeButton)

                Button {
                    store.send(.planSheetDismissed)
                } label: {
                    Text(L10n.Signup.Paywall.Plans.maybeLater).typography(.button1)
                }
                .buttonStyle(PIAButtonStyle(.plain))
                .accessibilityIdentifier(PaywallAccessibility.maybeLaterButton)
            }
        }
        .padding(PIASpacing.s24)
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text(L10n.Signup.Paywall.Plans.title)
                .typography(.title2, color: .pia.onSurface)
            Spacer(minLength: PIASpacing.s16)
            PaywallCloseButton { store.send(.planSheetDismissed) }
        }
    }

    private func planCard(for plan: PaywallPlanID) -> some View {
        let state = store.state
        let offer = state.offers[plan]

        return PlanOptionCard(
            title: state.planTitle(for: plan),
            price: offer.map(state.priceString(for:)) ?? "",
            billingPeriod: state.billingPeriodString(for: plan),
            badge: state.badgeTitle(for: plan),
            isSelected: state.sheetSelection == plan,
            action: { store.send(.planSelected(plan)) }
        )
    }
}

#Preview {
    let offers: [PaywallPlanID: PaywallOffer] = [
        .yearly: PaywallOffer(
            id: .yearly,
            priceString: "$72.98",
            monthlyPriceString: "$6.08",
            accessibleMonthlyPriceString: "6.08 US dollars"
        ),
        .monthly: PaywallOffer(
            id: .monthly,
            priceString: "$16.99",
            monthlyPriceString: "$16.99",
            accessibleMonthlyPriceString: "16.99 US dollars"
        )
    ]

    return ChoosePlanSheetContent(
        store: PaywallStore(
            initialState: Paywall.State(
                phase: .ready,
                offers: offers,
                trialOffer: PaywallTrialOffer(days: 7),
                sheetSelection: .yearly
            ),
            dependencies: Paywall.Dependencies(
                loadOffers: { .success(OffersPayload(offers: offers, trialOffer: PaywallTrialOffer(days: 7))) },
                hasExistingEntitlement: { false },
                purchase: { _ in .failure(.userCancelled) },
                finishTransaction: { _ in },
                restore: { .failure(.nothingToRestore) },
                purchaseIntents: { AsyncStream { $0.finish() } },
                emit: { _ in }
            )
        )
    )
    .background(Color.pia.surfaceContainerPrimary)
}
