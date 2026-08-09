//
//  SignupPaywallView.swift
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

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// The signup paywall.
///
/// Holds no navigation of its own: every outcome leaves through the store's `output` publisher, so
/// the same view works whether it is the app's root or a modal over the dashboard.
public struct SignupPaywallView: View {
    @ObservedObject private var store: PaywallStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let legal: PaywallLegalLinks

    public init(store: PaywallStore, legal: PaywallLegalLinks) {
        self.store = store
        self.legal = legal
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                PaywallBackgroundView()

                ScrollView(showsIndicators: false) {
                    content
                        .padding(.top, PIASpacing.s16)
                        .padding(.bottom, PIASpacing.s24)
                }

                if store.state.isDismissable {
                    PaywallCloseButton { store.send(.closeTapped) }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, PIASpacing.s8)
                }

                PaywallSheetContainer(
                    isPresented: store.state.isPlanSheetPresented,
                    layout: store.state.layout,
                    onDismiss: { store.send(.planSheetDismissed) }
                ) {
                    ChoosePlanSheetContent(store: store)
                }
            }
            .onAppear {
                store.send(.layoutChanged(resolveLayout(for: proxy.size)))
            }
            .onChange(of: proxy.size) { newSize in
                store.send(.layoutChanged(resolveLayout(for: newSize)))
            }
        }
        .task { store.send(.onAppear) }
        .onDisappear { store.cancelAll() }
        .alert(item: alertBinding) { kind in makeAlert(kind) }
    }

    private func resolveLayout(for size: CGSize) -> PaywallLayout {
        PaywallLayout.resolve(size: size, horizontalSizeClass: horizontalSizeClass)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch store.state.layout {
        case .compact:
            compactContent
        case .wide:
            wideContent
        }
    }

    private var compactContent: some View {
        VStack(spacing: PIASpacing.s24) {
            header
            BenefitsList(layout: .compact)
                .padding(.horizontal, PaywallLayoutMetrics.headerMargin)

            if store.state.showsTrialTimeline {
                TrialTimelineCard(layout: .compact)
                    .padding(.horizontal, PaywallLayoutMetrics.contentMargin)
            }

            actions
                .padding(.horizontal, PaywallLayoutMetrics.contentMargin)
        }
        .frame(maxWidth: PaywallLayoutMetrics.maxContentWidth)
        .frame(maxWidth: .infinity)
    }

    private var wideContent: some View {
        VStack(spacing: PIASpacing.s24) {
            VStack(spacing: PIASpacing.s16) {
                logo
                SocialProofRow()
            }

            HStack(alignment: .center, spacing: PIASpacing.s40) {
                hero
                if store.state.showsTrialTimeline {
                    TrialTimelineCard(layout: .wide)
                }
            }

            BenefitsList(layout: .wide)

            actions
                .frame(maxWidth: PaywallLayoutMetrics.wideMaxContentWidth)
        }
        .padding(.horizontal, PaywallLayoutMetrics.contentMargin)
        // Without a ceiling the row of benefits and the trial card stretch to the full width of a
        // 13" iPad, which leaves the text marooned at opposite edges.
        .frame(maxWidth: PaywallLayoutMetrics.wideMaxCanvasWidth)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: PIASpacing.s12) {
            logo
            SocialProofRow()
            hero
        }
    }

    private var logo: some View {
        Asset.navLogo.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 50)
            .accessibilityHidden(true)
    }

    private var hero: some View {
        Asset.paywallHero.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: PaywallLayoutMetrics.heroWidth,
                height: PaywallLayoutMetrics.heroHeight
            )
            .accessibilityHidden(true)
    }

    // MARK: - Actions

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: PIASpacing.s12) {
            if store.state.phase == .productsUnavailable {
                unavailableNotice
            } else {
                PaywallDisclaimerView(disclaimer: store.state.disclaimer)
                primaryButton
                if store.state.showsOtherPlansButton {
                    secondaryButton
                }
            }

            restoreButton
            loginButton
            LegalAgreementText(termsURL: legal.termsURL, privacyURL: legal.privacyURL)
                .padding(.top, PIASpacing.s8)
        }
    }

    private var primaryButton: some View {
        Button {
            store.send(.purchaseTapped(source: .mainScreen))
        } label: {
            Text(store.state.primaryButtonTitle)
                .typography(.button1)
                .redacted(reason: store.state.isSkeleton ? .placeholder : [])
        }
        .buttonStyle(PIAButtonStyle(.primary, isLoading: store.state.isPurchasing))
        .disabled(!store.state.canPurchase)
        .accessibilityIdentifier(PaywallAccessibility.subscribeButton)
    }

    private var secondaryButton: some View {
        Button {
            store.send(.seeOtherPlansTapped)
        } label: {
            Text(L10n.Signup.Paywall.Cta.otherPlans).typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.secondary))
        .disabled(!store.state.canPurchase)
        .accessibilityIdentifier(PaywallAccessibility.otherPlansButton)
    }

    private var restoreButton: some View {
        Button {
            store.send(.restoreTapped)
        } label: {
            Text(L10n.Signup.Paywall.Cta.restore).typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.plain, isLoading: store.state.isRestoring))
        .disabled(!store.state.canRestore)
        .accessibilityIdentifier(PaywallAccessibility.restoreButton)
    }

    /// Not in the Figma, but this screen is the logged-out root — without it an existing customer
    /// has no way into their account.
    private var loginButton: some View {
        Button {
            store.send(.loginTapped)
        } label: {
            Text(L10n.Signup.Paywall.Cta.login).typography(.button2)
        }
        .buttonStyle(PIAButtonStyle(.plain))
        // The label is a question rather than an action, so on its own VoiceOver would announce
        // "Already have an account?, button" without saying what tapping does.
        .accessibilityHint(L10n.Signup.Paywall.Accessibility.loginHint)
        .accessibilityIdentifier(PaywallAccessibility.loginButton)
    }

    private var unavailableNotice: some View {
        VStack(spacing: PIASpacing.s12) {
            Text(L10n.Signup.Paywall.Error.productsUnavailable)
                .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
                .multilineTextAlignment(.center)

            Button {
                store.send(.retryTapped)
            } label: {
                Text(L10n.Signup.Paywall.Error.retry).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.secondary))
        }
    }

    // MARK: - Alerts

    private var alertBinding: Binding<PaywallState.AlertKind?> {
        Binding(
            get: { store.state.alert },
            set: { if $0 == nil { store.send(.alertDismissed) } }
        )
    }

    private func makeAlert(_ kind: PaywallState.AlertKind) -> Alert {
        switch kind {
        case .existingEntitlement:
            return Alert(
                title: Text(L10n.Signup.Purchase.Existing.Subscription.title),
                message: Text(L10n.Signup.Purchase.Existing.Subscription.message),
                primaryButton: .default(Text(L10n.Account.Restore.button)) {
                    store.send(.alertRestoreConfirmed)
                },
                secondaryButton: .cancel(Text(L10n.Global.close)) {
                    store.send(.alertDismissed)
                }
            )

        case .nothingToRestore:
            return Alert(
                title: Text(L10n.Signup.Purchase.Restore.Empty.title),
                message: Text(L10n.Signup.Purchase.Restore.Empty.message),
                dismissButton: .default(Text(L10n.Global.close)) { store.send(.alertDismissed) }
            )

        case .restoreFailed:
            return Alert(
                title: Text(L10n.Account.Restore.Failure.title),
                message: Text(L10n.Account.Restore.Failure.message),
                dismissButton: .default(Text(L10n.Global.close)) { store.send(.alertDismissed) }
            )
        }
    }
}

/// The legal destinations the paywall links to, injected so the view never reaches for `Client`.
public struct PaywallLegalLinks {
    public let termsURL: URL
    public let privacyURL: URL

    public init(termsURL: URL, privacyURL: URL) {
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }
}

/// Stable identifiers for the UI tests.
public enum PaywallAccessibility {
    public static let subscribeButton = "id.paywall.subscribe"
    public static let otherPlansButton = "id.paywall.other_plans"
    public static let restoreButton = "id.paywall.restore"
    public static let sheetSubscribeButton = "id.paywall.sheet.subscribe"
    public static let maybeLaterButton = "id.paywall.sheet.maybe_later"

    /// Kept as the historical login identifier so the existing UI tests keep finding the way in.
    public static let loginButton = "id.login.submit"
}
