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

    public enum Size: Sendable {
        /// 50pt tall. A screen's main action.
        case regular
        /// 40pt tall, for cards and banners where the action sits beside the copy rather than under it.
        case compact

        var height: CGFloat {
            switch self {
            case .regular: return 50
            case .compact: return 40
            }
        }
    }

    private let kind: Kind
    private let size: Size
    private let isLoading: Bool
    private let activityImage: Image?

    /// - Parameters:
    ///   - kind: Which of the three PIA button appearances to use.
    ///   - size: How tall the button is. Defaults to the full-height `.regular`.
    ///   - isLoading: When `true` the label is replaced by a spinner and the button stops responding.
    ///   - activityImage: The spinner artwork. `PIASwiftUI` deliberately ships no assets, so the
    ///     host passes its own (the same contract as `LoadingView`). Falls back to a
    ///     `ProgressView` when `nil`.
    public init(
        _ kind: Kind,
        size: Size = .regular,
        isLoading: Bool = false,
        activityImage: Image? = nil
    ) {
        self.kind = kind
        self.size = size
        self.isLoading = isLoading
        self.activityImage = activityImage
    }

    public func makeBody(configuration: Configuration) -> some View {
        ButtonContent(
            kind: kind,
            size: size,
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
        let size: Size
        let isLoading: Bool
        let activityImage: Image?
        let configuration: Configuration

        private enum Layout {
            static let minimumTapTarget: CGFloat = 44
            /// A full-width button hides the absence of this, its label being centred with room to
            /// spare; one sized to its content has the label flush against the fill without it.
            static let horizontalPadding: CGFloat = PIASpacing.s16
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
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(maxWidth: .infinity)
            .frame(height: kind == .plain ? Layout.minimumTapTarget : size.height)
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

// The loading buttons pass no `activityImage` on purpose: `LoadingView` spins forever, whereas the
// `ProgressView` fallback renders statically in the canvas.
#Preview("Primary") {
    VStack(spacing: PIASpacing.s8) {
        Button(action: {}) {
            Text("Start My 7-day Free Trial").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.primary))

        Button(action: {}) {
            Text("Loading").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.primary, isLoading: true))

        Button(action: {}) {
            Text("Disabled").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.primary))
        .disabled(true)
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}

#Preview("Compact") {
    VStack(spacing: PIASpacing.s8) {
        Button(action: {}) {
            Text("Claim My Free Days").typography(.button2)
        }
        .buttonStyle(PIAButtonStyle(.primary, size: .compact))
        .fixedSize(horizontal: true, vertical: false)

        Button(action: {}) {
            Text("See Other Plans").typography(.button2)
        }
        .buttonStyle(PIAButtonStyle(.secondary, size: .compact))
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}

#Preview("Secondary") {
    VStack(spacing: PIASpacing.s8) {
        Button(action: {}) {
            Text("See Other Plans").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.secondary))

        Button(action: {}) {
            Text("Disabled").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.secondary))
        .disabled(true)
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}

#Preview("Plain") {
    VStack(spacing: PIASpacing.s8) {
        Button(action: {}) {
            Text("Restore Purchases").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.plain))

        Button(action: {}) {
            Text("Disabled").typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(.plain))
        .disabled(true)
    }
    .padding(PIASpacing.s24)
    .background(Color.pia.background)
}
