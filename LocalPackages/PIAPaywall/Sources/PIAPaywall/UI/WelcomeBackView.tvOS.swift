//
//  WelcomeBackView.tvOS.swift
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

#if os(tvOS)
    import PIAAssetsTV
    import PIADesignSystem
    import PIALocalizations
    import PIASwiftUI
    import SwiftUI

    /// Shown over the signup paywall when the App Store already holds a live subscription for this
    /// Apple ID. The remote's Menu button returns to the paywall.
    public struct WelcomeBackView: View {
        fileprivate enum Metrics {
            static let contentWidth: CGFloat = 768
            static let buttonSize = CGSize(width: 510, height: 66)
        }

        @StateObject private var store: WelcomeBackStore

        public init(dependencies: WelcomeBack.Dependencies) {
            _store = StateObject(wrappedValue: WelcomeBackStore(dependencies: dependencies))
        }

        public var body: some View {
            if store.state.isRestoring {
                LoginLoadingView()
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 64) {
                        Asset.piaBrand.swiftUIImage

                        VStack(alignment: .leading, spacing: 24) {
                            Text(L10n.Signup.WelcomeBack.title)
                                .font(.system(size: 57))
                                .bold()
                            Text(L10n.Signup.WelcomeBack.message)
                                .font(.system(size: 38))
                        }
                        .foregroundColor(Color.pia.onBackground)
                        .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 24) {
                            Text(L10n.Signup.WelcomeBack.signInWith)
                                .font(.system(size: 29, weight: .medium))
                                .foregroundColor(Color.pia.onBackground)

                            VStack(spacing: 16) {
                                ActionButton(
                                    title: L10n.Signup.WelcomeBack.Cta.appStore,
                                    action: { store.send(.appStoreAccountTapped) }
                                )
                                .frame(width: Metrics.buttonSize.width, height: Metrics.buttonSize.height)
                                .accessibilityIdentifier(WelcomeBackAccessibility.appStoreButton)

                                ActionButton(
                                    title: L10n.Signup.WelcomeBack.Cta.qrCode,
                                    action: { store.send(.qrCodeTapped) }
                                )
                                .frame(width: Metrics.buttonSize.width, height: Metrics.buttonSize.height)
                                .accessibilityIdentifier(WelcomeBackAccessibility.qrCodeButton)

                                ActionButton(
                                    title: L10n.Signup.WelcomeBack.Cta.credentials,
                                    action: { store.send(.usernameAndPasswordTapped) }
                                )
                                .frame(width: Metrics.buttonSize.width, height: Metrics.buttonSize.height)
                                .accessibilityIdentifier(WelcomeBackAccessibility.credentialsButton)
                            }
                        }
                    }
                    .frame(maxWidth: Metrics.contentWidth, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Asset.welcomeBack.swiftUIImage
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                }
            }
        }
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
#endif
