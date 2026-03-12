//
//  GetStartedView.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 05.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import SwiftUI
import PIALibrary
import PIADesignSystem
import PIASwiftUI

// TODO: Replace hardcoded text with localizable ones
// TODO: Define common Spacing contants in PIADesignSystem

struct GetStartedView<ViewModel: GetStartedViewModelProtocol>: View {
    @StateObject private var viewModel: ViewModel

    var body: some View {
        if UserInterface.isIpad {
            ZStack {
                ScrollView {
                    contents
                        .padding(.horizontal, 80)
                }
                .frame(maxWidth: 495, maxHeight: 860, alignment: .center)
                .background(Color.pia.surfaceContainerPrimary)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.pia.background)
        } else {
            ScrollView {
                contents
            }
            .background(Color.pia.background)
        }
    }

    private var headerSection: some View {
        // Header Section
        VStack(spacing: 12) {
            Text("Connect to Secure VPN Servers Worldwide!")
                .typography(.title1, color: .pia.onSurface)
                .multilineTextAlignment(.center)

            SwiftUI.Image(uiImage: Asset.Ui.imagePaywallGlobe.image)

            Text("NextGen Servers in 91 Countries | 100% No Logs | Unlimited Device Security")
                .typography(.body2, color: .pia.onSurface)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var plansSection: some View {
        VStack(spacing: 8) {
            switch viewModel.plans {
            case .loading, .error:
                ProgressView()
                    .progressViewStyle(.circular)

            case .loaded(let purchasePlans):
                ForEach(purchasePlans) { purchasePlan in
                    if purchasePlan.plan == .yearly || purchasePlan.plan == .monthly {
                        PlanCardView(
                            configuration: PlanCardConfiguration(
                                headerText: "Get 3-Day Free Trial",
                                savingsText: "Save 68%",
                                title: purchasePlan.title,
                                detail: purchasePlan.detail,
                                secondaryDetail: purchasePlan.secondaryDetail
                            ),
                            isSelected: viewModel.selectedPlan == purchasePlan,
                            onTap: { viewModel.selectedPlan = purchasePlan }
                        )
                    } else {
                        PlanCardView(
                            configuration: PlanCardConfiguration(
                                title: purchasePlan.title,
                                detail: purchasePlan.detail
                            ),
                            isSelected: viewModel.selectedPlan == purchasePlan,
                            onTap: { viewModel.selectedPlan = purchasePlan }
                        )
                    }
                }
            }
        }
    }

    private var buttonsSection: some View {
        VStack(spacing: 8) {
            Button(action: viewModel.confirmPlan) {
                Text(L10n.Signup.Purchase.Subscribe.now)
                    .typography(.button1, color: .pia.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.pia.primary)
                    .cornerRadius(12)
            }
            .disabled(viewModel.selectedPlan == nil)
            .opacity(viewModel.selectedPlan == nil ? 0.5 : 1.0)

            Button(action: viewModel.navigateToLoginView) {
                Text(L10n.Welcome.Login.title)
                    .typography(.button1, color: .pia.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.pia.onPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.pia.primary, lineWidth: 2)
                    )
                    .cornerRadius(12)
            }
        }
        .padding(.bottom, 44)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription Details")
                .typography(.subtitle2, color: .pia.onBackground)

            VStack(alignment: .leading, spacing: 12) {
                BulletPointView(text: "Your Apple ID account will be charged on the last day of your free trial.")

                BulletPointView(text: "Your subscription will automatically renew at the end of each billing period unless it is canceled at least 24 hours before the expiry date.")

                BulletPointView(text: "You can manage and cancel your subscriptions by going to your App Store account settings after purchase.")

                BulletPointView(text: "Any unused portion of a free trial period, if offered, will be forfeited when you purchase a subscription.")

                BulletPointView(text: "By subscribing, you agree to the Terms of Service and Privacy Policy.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var contents: some View {
        VStack(spacing: 20) {
            headerSection
            plansSection
            buttonsSection
            detailsSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct BulletPointView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("• \(text)")
                .typography(.caption2, color: .pia.onBackground)
        }
    }
}

// MARK: - Previews

#Preview("Loaded") {
    final class DummyProduct: NSObject, InAppProduct {
        var identifier: String = ""
        var price: NSNumber = .init(floatLiteral: 99.9)
        var priceLocale: Locale = .current
        var native: Any? = nil
    }

    let viewModel = GetStartedViewModel(
        accountProvider: MockAccountProvider()
    )

    // TODO: Extract dummy plans to some extension
    let yearlyPlan = {
        let plan = PurchasePlan(
            plan: .yearly,
            product: DummyProduct(),
            monthlyFactor: 12
        )

        plan.title = L10n.Welcome.Plan.Yearly.title
        plan.bestValue = true
        plan.detail = L10n.Welcome.Plan.Yearly.detailFormat("$", "99.90")
        plan.secondaryDetail = L10n.Welcome.Plan.Weekly.detailFormat("$", "9.90")

        return plan
    }()

    let monthlyPlan = {
        let plan = PurchasePlan(
            plan: .monthly,
            product: DummyProduct(),
            monthlyFactor: 1
        )

        plan.title = L10n.Welcome.Plan.Monthly.title
        plan.bestValue = false
        plan.detail = L10n.Welcome.Plan.Monthly.detailFormat("$", "59.90")
        plan.secondaryDetail = L10n.Welcome.Plan.Monthly.detailFormat("$", "9.90")

        return plan
    }()

    viewModel.plans = .loaded([yearlyPlan, monthlyPlan])
    viewModel.selectedPlan = yearlyPlan

    return GetStartedView(viewModel: viewModel)
}

#Preview("Loading") {
    let viewModel = GetStartedViewModel(
        accountProvider: MockAccountProvider()
    )
    viewModel.plans = .loading
    return GetStartedView(viewModel: viewModel)
}
