//
//  PIADialog.swift
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

/// A modal dialog in the style of the app's legacy PopupDialog alerts: a dimmed backdrop, a flat
/// card with a title and message, and a row of buttons along the bottom.
///
/// Unlike `.alert`, every button keeps its `accessibilityIdentifier`, so UI tests can find it.
/// Present one with `View.piaDialog(_:)`.
public struct PIADialog: Equatable {
    public struct Action: Equatable {
        public enum Role: Sendable {
            /// Tinted with the brand colour.
            case `default`
            /// Muted; dismisses without doing anything else.
            case cancel
        }

        public let title: String
        public let role: Role
        /// What UI tests query.
        public let identifier: String
        public let handler: @MainActor () -> Void

        public init(
            title: String,
            role: Role = .default,
            identifier: String,
            handler: @MainActor @escaping () -> Void
        ) {
            self.title = title
            self.role = role
            self.identifier = identifier
            self.handler = handler
        }

        /// Ignores `handler`, which closures can't compare.
        public static func == (lhs: Action, rhs: Action) -> Bool {
            lhs.title == rhs.title && lhs.role == rhs.role && lhs.identifier == rhs.identifier
        }
    }

    public let title: String
    public let message: String
    public let actions: [Action]

    public init(title: String, message: String, actions: [Action]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

extension View {
    /// Shows `dialog` over this view while it is non-nil.
    ///
    /// The backdrop doesn't dismiss it: as with an alert, only one of its actions does.
    public func piaDialog(_ dialog: PIADialog?) -> some View {
        overlay {
            ZStack {
                if let dialog {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .accessibilityHidden(true)

                    PIADialogCard(dialog: dialog)
                        .padding(PIASpacing.s24)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: dialog)
        }
    }
}

private struct PIADialogCard: View {
    private enum Metrics {
        static let maxWidth: CGFloat = 340
        static let buttonHeight: CGFloat = 45
        static let hairline: CGFloat = 1
    }

    let dialog: PIADialog

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: PIASpacing.s12) {
                Text(dialog.title)
                    .typography(.body2, color: .pia.onSurface)
                    .accessibilityAddTraits(.isHeader)
                Text(dialog.message)
                    .typography(.caption1, color: .pia.onSurface)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(PIASpacing.s20)

            Color.pia.outline.frame(height: Metrics.hairline)

            HStack(spacing: 0) {
                ForEach(Array(dialog.actions.enumerated()), id: \.element.identifier) { index, action in
                    if index > 0 {
                        Color.pia.outline.frame(width: Metrics.hairline)
                    }
                    button(for: action)
                }
            }
            .frame(minHeight: Metrics.buttonHeight)
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(Color.pia.surface)
        .frame(maxWidth: Metrics.maxWidth)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private func button(for action: PIADialog.Action) -> some View {
        Button {
            action.handler()
        } label: {
            Text(action.title)
                .typography(
                    .caption1,
                    color: action.role == .cancel ? .pia.onSurfaceContainerSecondary : .pia.primary
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, PIASpacing.s8)
                .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(action.identifier)
    }
}

#Preview("One action") {
    Color.pia.background
        .ignoresSafeArea()
        .piaDialog(
            PIADialog(
                title: "PIA",
                message: "We need this permission for the application to function.",
                actions: [.init(title: "OK", role: .cancel, identifier: "ok") {}]
            )
        )
}

#Preview("Two actions") {
    Color.pia.background
        .ignoresSafeArea()
        .piaDialog(
            PIADialog(
                title: "PIA",
                message: "We need this permission for the application to function.\nYou can also get in touch with customer support if you need assistance.",
                actions: [
                    .init(title: "Contact", identifier: "contact") {},
                    .init(title: "OK", role: .cancel, identifier: "ok") {}
                ]
            )
        )
}
