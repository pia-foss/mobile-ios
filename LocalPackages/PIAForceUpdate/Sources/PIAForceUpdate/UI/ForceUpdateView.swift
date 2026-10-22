//
//  ForceUpdateView.swift
//  PIAForceUpdate
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

/// Blocks the app until the person updates it from the App Store.
///
/// Has no way out on purpose: the host presents it full screen and never dismisses it.
public struct ForceUpdateView: View {
    private enum Metrics {
        static let shieldWidth: CGFloat = 146
        static let shieldHeight: CGFloat = 138
        static let verticalMargin: CGFloat = 60

        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    @StateObject private var store: ForceUpdateStore

    public init(dependencies: ForceUpdate.Dependencies) {
        self.init(initialState: ForceUpdate.State(), dependencies: dependencies)
    }

    init(initialState: ForceUpdate.State, dependencies: ForceUpdate.Dependencies) {
        _store = StateObject(
            wrappedValue: ForceUpdateStore(
                initialState: initialState,
                dependencies: dependencies
            ))
    }

    public var body: some View {
        VStack(spacing: PIASpacing.s24) {
            ScrollView {
                VStack(spacing: PIASpacing.s24) {
                    Asset.forceUpdateShield.swiftUIImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Metrics.shieldWidth, height: Metrics.shieldHeight)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: PIASpacing.s24) {
                        Text(L10n.Forceupdate.Label.title)
                            .typography(.title1, color: .pia.onBackground)
                            .accessibilityAddTraits(.isHeader)
                        Text(L10n.Forceupdate.Label.subtitle)
                            .typography(.body1, color: .pia.onBackground)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            actions
        }
        .padding(.horizontal, PIASpacing.s20)
        .padding(.vertical, Metrics.verticalMargin)
        .frame(maxWidth: Metrics.maxContentWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pia.background.ignoresSafeArea())
        .interactiveDismissDisabled()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ForceUpdateAccessibility.screen)
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var actions: some View {
        VStack(spacing: PIASpacing.s24) {
            Button {
                store.send(.updateTapped)
            } label: {
                Text(L10n.Forceupdate.Button.update).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary))
            .accessibilityIdentifier(ForceUpdateAccessibility.updateButton)

            if store.state.isVPNConnected {
                Text(L10n.Forceupdate.Label.Vpn.connected)
                    .typography(.subtitle3, color: .pia.onBackground)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(ForceUpdateAccessibility.vpnConnectedHint)
            }
        }
    }
}

/// Stable identifiers for the UI tests.
public enum ForceUpdateAccessibility {
    public static let screen = "ForceUpdateScreen"
    public static let updateButton = "ForceUpdateScreenUpdateButton"
    public static let vpnConnectedHint = "ForceUpdateScreenVPNConnectedHint"
}

#Preview("VPN connected") {
    ForceUpdateView(
        initialState: ForceUpdate.State(isVPNConnected: true),
        dependencies: ForceUpdate.Dependencies(isVPNConnected: { true }, update: {})
    )
}

#Preview("VPN disconnected") {
    ForceUpdateView(
        dependencies: ForceUpdate.Dependencies(isVPNConnected: { false }, update: {})
    )
}
