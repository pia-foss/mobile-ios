//
//  WelcomeBackView.swift
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

/// Shown over the paywall when the App Store already holds a live subscription for this Apple ID.
public struct WelcomeBackView: View {
    fileprivate enum Metrics {
        static let contentMargin: CGFloat = 20
        static let maxContentWidth: CGFloat = 480
        static let heroHeight: CGFloat = 297
    }

    @StateObject private var store: WelcomeBackStore

    public init(
        initialState: WelcomeBack.State = WelcomeBack.State(),
        dependencies: WelcomeBack.Dependencies
    ) {
        _store = StateObject(
            wrappedValue: WelcomeBackStore(initialState: initialState, dependencies: dependencies)
        )
    }

    public var body: some View {
        ZStack(alignment: .top) {
            PaywallBackgroundView()

            VStack(spacing: 0) {
                PIALogoView()
                Spacer(minLength: PIASpacing.s20)
                WelcomeBackBody()
                Spacer(minLength: PIASpacing.s20)
                WelcomeBackActions(isRestoring: store.state.isRestoring, send: store.send(_:))
            }
            .padding(.horizontal, Metrics.contentMargin)
            .padding(.vertical, PIASpacing.s16)
            .frame(maxWidth: Metrics.maxContentWidth)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct WelcomeBackBody: View {
    var body: some View {
        VStack(spacing: PIASpacing.s20) {
            Asset.welcomeBackHero.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: WelcomeBackView.Metrics.heroHeight)
                .accessibilityHidden(true)

            VStack(spacing: PIASpacing.s16) {
                Text(L10n.Signup.WelcomeBack.title)
                    .typography(.title1, color: .pia.primary)
                Text(L10n.Signup.WelcomeBack.message)
                    .typography(.body1, color: .pia.onBackground)
            }
            .multilineTextAlignment(.center)
        }
    }
}

private struct WelcomeBackActions: View {
    let isRestoring: Bool
    let send: (WelcomeBack.Action) -> Void

    var body: some View {
        VStack(spacing: PIASpacing.s12) {
            Text(L10n.Signup.WelcomeBack.signInWith)
                .typography(.body2, color: .pia.onBackground)

            Button {
                send(.appStoreAccountTapped)
            } label: {
                Text(L10n.Signup.WelcomeBack.Cta.appStore).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary, isLoading: isRestoring))
            .accessibilityIdentifier(WelcomeBackAccessibility.appStoreButton)

            Text(L10n.Signup.WelcomeBack.or)
                .typography(.body2, color: .pia.onBackground)

            Button {
                send(.usernameAndPasswordTapped)
            } label: {
                Text(L10n.Signup.WelcomeBack.Cta.credentials).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.secondary))
            .disabled(isRestoring)
            .accessibilityIdentifier(WelcomeBackAccessibility.credentialsButton)
        }
        .padding(.bottom, PIASpacing.s16)
    }
}

public enum WelcomeBackAccessibility {
    public static let appStoreButton = "id.welcome_back.app_store"
    public static let credentialsButton = "id.welcome_back.credentials"
}

// MARK: - Preview

#Preview {
    WelcomeBackView(
        dependencies: WelcomeBack.Dependencies(
            restore: { .failure(.nothingToRestore) },
            emit: { _ in }
        )
    )
}
