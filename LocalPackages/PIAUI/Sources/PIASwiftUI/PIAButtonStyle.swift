//
//  PIAButtonStyle.swift
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

import PIADesignSystem
import SwiftUI

/// The PIA button styles.
///
/// The style owns shape, fill, border, foreground colour, disabled and pressed appearance, and the
/// in-button loading indicator. Typography stays with the caller, because `.typography(_:)` is
/// defined on `Text`:
///
/// ```swift
/// Button(action: subscribe) {
///     Text(title).typography(.button1)
/// }
/// .buttonStyle(PIAButtonStyle(.primary, isLoading: isPurchasing, activityImage: Asset.piaSpinner.swiftUIImage))
/// ```
///
/// The loading indicator replaces the label **in place**, so the button never collapses and the rest
/// of the screen stays interactive — PIA never blocks a whole screen behind a purchase.
public struct PIAButtonStyle: ButtonStyle {
    public enum Kind: Sendable {
        /// Filled with the brand colour. One per screen.
        case primary
        /// Outlined, transparent fill.
        case secondary
        /// Text only, no chrome.
        case plain
    }

    private let kind: Kind
    private let isLoading: Bool
    private let activityImage: Image?

    /// - Parameters:
    ///   - kind: Which of the three PIA button appearances to use.
    ///   - isLoading: When `true` the label is replaced by a spinner and the button stops responding.
    ///   - activityImage: The spinner artwork. `PIASwiftUI` deliberately ships no assets, so the
    ///     host passes its own (the same contract as `LoadingView`). Falls back to a
    ///     `ProgressView` when `nil`.
    public init(_ kind: Kind, isLoading: Bool = false, activityImage: Image? = nil) {
        self.kind = kind
        self.isLoading = isLoading
        self.activityImage = activityImage
    }

    public func makeBody(configuration: Configuration) -> some View {
        ButtonContent(
            kind: kind,
            isLoading: isLoading,
            activityImage: activityImage,
            configuration: configuration
        )
    }
}

// MARK: - Content

extension PIAButtonStyle {
    /// Deliberately not named `Body`: that collides with `ButtonStyle.Body`, and the compiler then
    /// tries to satisfy the protocol requirement with this type.
    fileprivate struct ButtonContent: View {
        @Environment(\.isEnabled) private var isEnabled

        let kind: Kind
        let isLoading: Bool
        let activityImage: Image?
        let configuration: Configuration

        private enum Layout {
            static let height: CGFloat = 50
            static let minimumTapTarget: CGFloat = 44
            static let borderWidth: CGFloat = 1
            static let indicatorSize: CGFloat = 20
            static let pressedOpacity: CGFloat = 0.7
            static let disabledOpacity: CGFloat = 0.4
        }

        var body: some View {
            ZStack {
                configuration.label
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    indicator
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: kind == .plain ? Layout.minimumTapTarget : Layout.height)
            .foregroundColor(foregroundColor)
            .background(background)
            .contentShape(Rectangle())
            .opacity(opacity(isPressed: configuration.isPressed))
            // A loading button keeps its full-strength fill — dimming it would read as "disabled"
            // and bury the spinner — but it must stop accepting taps.
            .allowsHitTesting(!isLoading)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .accessibilityElement(children: .combine)
        }

        @ViewBuilder
        private var indicator: some View {
            if let activityImage {
                LoadingView(image: activityImage)
                    .frame(width: Layout.indicatorSize, height: Layout.indicatorSize)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(foregroundColor)
            }
        }

        @ViewBuilder
        private var background: some View {
            switch kind {
            case .primary:
                RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                    .fill(Color.pia.primary)
            case .secondary:
                RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                    .strokeBorder(Color.pia.primary, lineWidth: Layout.borderWidth)
            case .plain:
                Color.clear
            }
        }

        private var foregroundColor: Color {
            switch kind {
            case .primary: return .pia.onPrimary
            case .secondary, .plain: return .pia.primary
            }
        }

        private func opacity(isPressed: Bool) -> CGFloat {
            guard isEnabled else { return Layout.disabledOpacity }
            return isPressed && !isLoading ? Layout.pressedOpacity : 1
        }
    }
}
