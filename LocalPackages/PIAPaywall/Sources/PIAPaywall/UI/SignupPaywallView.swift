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
/// Holds no navigation of its own: every outcome leaves through `Paywall.Dependencies.emit`, so the
/// same view works whether it is the app's root or a modal over the dashboard.
public struct SignupPaywallView: View {
    /// Measurements taken from the 402pt-wide design.
    private enum Metrics {
        /// Side margin for the trial card and the button stack.
        static let contentMargin: CGFloat = 33

        /// The benefits block. The design insets it to 42.5, which leaves the longest benefit exactly
        /// one point of slack — but only because every text style there carries `letterSpacing: -0.4`,
        /// and `PIADesignSystem` does not apply tracking (SwiftUI gained `Text.tracking` in iOS 16 and
        /// the deployment target is iOS 15). Without that tightening the line wraps, so the block is
        /// inset to the same margin as the cards below it instead.
        static let headerMargin: CGFloat = 33

        /// Keeps the single column readable when the canvas is much wider than a phone. Both
        /// arrangements share it: landscape widens what sits *inside* the column rather than the
        /// column itself.
        static let maxContentWidth: CGFloat = 480

        static let heroWidth: CGFloat = 149
        static let heroHeight: CGFloat = 120

        /// The tablet's vertical rhythm. Deliberately between the `PIASpacing` steps either side of
        /// it, which jump 24 → 40.
        static let tabletBlockSpacing: CGFloat = 32

        /// How much larger a portrait iPad draws the hero.
        static let tabletHeroScale: CGFloat = 1.17
    }

    @StateObject private var store: PaywallStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let legal: PaywallLegalLinks

    /// Portrait iPad and portrait iPhone are both `PaywallLayout.compact`; the size class separates
    /// them.
    private var isTablet: Bool { horizontalSizeClass == .regular }

    private var blockSpacing: CGFloat {
        isTablet ? Metrics.tabletBlockSpacing : PIASpacing.s24
    }

    /// Landscape has width to spare, but not height.
    private var heroScale: CGFloat {
        isTablet && store.state.layout == .compact ? Metrics.tabletHeroScale : 1
    }

    /// Creates the paywall and the store behind it.
    ///
    /// The view owns its store, so the store's lifetime is the screen's: releasing the view cancels
    /// whatever the reducer still had in flight.
    public init(
        initialState: Paywall.State = Paywall.State(),
        dependencies: Paywall.Dependencies,
        legal: PaywallLegalLinks
    ) {
        _store = StateObject(
            wrappedValue: PaywallStore(initialState: initialState, dependencies: dependencies)
        )
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
                        // Without this the stretched frame below truncates wrapped text.
                        .fixedSize(horizontal: false, vertical: true)
                        // Centres the column on a canvas taller than it; inert on a phone.
                        .frame(minHeight: proxy.size.height, alignment: .center)
                }

                if store.state.layout == .wide {
                    logo
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, PIASpacing.s40)
                        .padding(.top, PIASpacing.s40)
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
        .onDisappear { store.send(.disappeared) }
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
        VStack(spacing: blockSpacing) {
            header
            BenefitsList(layout: .compact)
                .padding(.horizontal, Metrics.headerMargin)

            if let trialDays = store.state.trialOffered(for: .yearly)?.days {
                TrialTimelineCard(layout: .compact, trialDays: trialDays)
                    .padding(.horizontal, Metrics.contentMargin)
            }

            actions
                .padding(.horizontal, Metrics.contentMargin)
        }
        .frame(maxWidth: Metrics.maxContentWidth)
        .frame(maxWidth: .infinity)
    }

    /// The same column as `compactContent`, at the same width: only its contents change.
    private var wideContent: some View {
        VStack(spacing: blockSpacing) {
            SocialProofRow()
            hero
            BenefitsList(layout: .wide)

            if let trialDays = store.state.trialOffered(for: .yearly)?.days {
                TrialTimelineCard(layout: .wide, trialDays: trialDays)
            }

            actions
        }
        // No inset: the benefits row and the card need the column's full width.
        .frame(maxWidth: Metrics.maxContentWidth)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: isTablet ? PIASpacing.s20 : PIASpacing.s12) {
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
                width: Metrics.heroWidth * heroScale,
                height: Metrics.heroHeight * heroScale
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

    /// Not in the design, but this screen is the logged-out root — without it an existing customer
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

    private var alertBinding: Binding<Paywall.State.AlertKind?> {
        Binding(
            get: { store.state.alert },
            set: { if $0 == nil { store.send(.alertDismissed) } }
        )
    }

    private func makeAlert(_ kind: Paywall.State.AlertKind) -> Alert {
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

// MARK: - Preview

/// The trial-eligible ready state.
///
/// `loadOffers` hands back the same offers the initial state already holds, so `.task`'s `onAppear`
/// resolves to exactly what is on screen rather than flipping the preview to a loading or error
/// state. The remaining dependencies are never reached: previews are not tapped.
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

    return SignupPaywallView(
        initialState: Paywall.State(
            phase: .ready,
            offers: offers,
            trialOffer: PaywallTrialOffer(days: 7)
        ),
        dependencies: Paywall.Dependencies(
            loadOffers: { .success(OffersPayload(offers: offers, trialOffer: PaywallTrialOffer(days: 7))) },
            hasExistingEntitlement: { false },
            purchase: { _ in .failure(.userCancelled) },
            finishTransaction: { _ in },
            restore: { .failure(.nothingToRestore) },
            purchaseIntents: { AsyncStream { $0.finish() } },
            emit: { _ in }
        ),
        legal: PaywallLegalLinks(
            termsURL: URL(string: "https://www.privateinternetaccess.com/pages/terms-of-service")!,
            privacyURL: URL(string: "https://www.privateinternetaccess.com/pages/privacy-policy")!
        )
    )
}
