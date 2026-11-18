//
//  ContentBlockerTutorialView.swift
//  PIASettings
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

/// Explains how to turn on the Safari Content Blocker from the system Settings.
public struct ContentBlockerTutorialView: View {
    private enum Metrics {
        static let imageHeight: CGFloat = 120
        static let titleSpacing: CGFloat = 20
        static let messageSpacing: CGFloat = 10
        static let footerSpacing: CGFloat = 20
        static let buttonSpacing: CGFloat = 40
        static let maxContentWidth: CGFloat = 480
    }

    private let onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                content
                    .padding(PIASpacing.s20)
                    .frame(maxWidth: Metrics.maxContentWidth)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
    }

    private var content: some View {
        VStack(spacing: 0) {
            Asset.imageContentBlocker.swiftUIImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: Metrics.imageHeight)
                .accessibilityHidden(true)

            Text(L10n.ContentBlocker.title)
                .typography(.title2, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, Metrics.titleSpacing)

            Text(L10n.ContentBlocker.Body.subtitle)
                .typography(.body2, color: .pia.onBackground)
                .multilineTextAlignment(.center)
                .padding(.top, Metrics.messageSpacing)

            Text(L10n.ContentBlocker.Body.footer)
                .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, Metrics.footerSpacing)

            Button(action: onDismiss) {
                Text(L10n.Global.ok).typography(.button1)
            }
            .buttonStyle(PIAButtonStyle(.primary))
            .keyboardShortcut(.defaultAction)
            .padding(.top, Metrics.buttonSpacing)
        }
    }
}

#Preview {
    ContentBlockerTutorialView {}
}
