//
//  GDPRView.swift
//  PIASignup
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

import PIAAccessibility
import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

/// Tells a new subscriber what their email is collected and used for, before it is attached to
/// the account.
///
/// Holds no state of its own: the host decides what accepting or closing means.
public struct GDPRView: View {
    private enum Metrics {
        /// Keeps the column readable on iPad, Mac Catalyst and the unfolded iPhone Duo.
        static let maxContentWidth: CGFloat = 480
    }

    private let onAccept: () -> Void
    private let onReject: () -> Void

    /// The host dismisses the screen, so a second tap during the dismissal must not accept twice.
    @State private var didAccept = false

    public init(onAccept: @escaping () -> Void, onReject: @escaping () -> Void) {
        self.onAccept = onAccept
        self.onReject = onReject
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PIACloseButton(accessibilityLabel: L10n.Global.close, action: onReject)
                .padding(.leading, PIASpacing.s8)
                .padding(.top, PIASpacing.s8)
                .accessibilityIdentifier(AccessibilityID.GDPR.closeButton)

            GeometryReader { proxy in
                ScrollView {
                    content
                        .frame(maxWidth: Metrics.maxContentWidth)
                        .padding(.horizontal, PIASpacing.s20)
                        .padding(.vertical, PIASpacing.s24)
                        .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.GDPR.screen)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s24) {
            VStack(alignment: .leading, spacing: PIASpacing.s16) {
                Text(L10n.Welcome.Gdpr.Collect.Data.title)
                    .typography(.title1, color: .pia.onBackground)
                    .accessibilityAddTraits(.isHeader)
                Text(L10n.Welcome.Gdpr.Collect.Data.description)
                    .typography(.body1, color: .pia.onSurfaceContainerSecondary)
                Text(L10n.Welcome.Gdpr.Usage.Data.description)
                    .typography(.body1, color: .pia.onSurfaceContainerSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)

            Button {
                guard !didAccept else { return }
                didAccept = true
                onAccept()
            } label: {
                Text(L10n.Welcome.Gdpr.Accept.Button.title).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary))
            .disabled(didAccept)
            .accessibilityIdentifier(AccessibilityID.GDPR.acceptButton)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Light") {
    GDPRView(onAccept: {}, onReject: {})
}

#Preview("Dark") {
    GDPRView(onAccept: {}, onReject: {})
        .preferredColorScheme(.dark)
}
