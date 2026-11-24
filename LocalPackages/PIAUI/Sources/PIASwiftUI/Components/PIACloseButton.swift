//
//  PIACloseButton.swift
//  PIASwiftUI
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

#if os(iOS)
    import PIAAssetsMobile
    import PIADesignSystem
    import SwiftUI

    /// The corner "X" that dismisses a sheet or modal screen.
    ///
    /// Also answers the Escape key, so a hardware keyboard can close the screen.
    public struct PIACloseButton: View {
        private enum Metrics {
            static let glyphSize: CGFloat = 24
            static let tapTarget: CGFloat = 44
        }

        private let color: Color
        private let accessibilityLabel: String
        private let action: () -> Void

        public init(
            color: Color = .pia.onSurfaceContainerPrimary,
            accessibilityLabel: String,
            action: @escaping () -> Void
        ) {
            self.color = color
            self.accessibilityLabel = accessibilityLabel
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                Asset.Piax.Global.iconCloseSmall.swiftUIImage
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Metrics.glyphSize, height: Metrics.glyphSize)
                    .foregroundColor(color)
                    .frame(width: Metrics.tapTarget, height: Metrics.tapTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel(Text(accessibilityLabel))
        }
    }

    #Preview {
        HStack {
            PIACloseButton(accessibilityLabel: "Close") {}
            PIACloseButton(color: .pia.onSurfaceContainerSecondary, accessibilityLabel: "Close") {}
        }
        .padding(PIASpacing.s8)
        .background(Color.pia.background)
    }
#endif
