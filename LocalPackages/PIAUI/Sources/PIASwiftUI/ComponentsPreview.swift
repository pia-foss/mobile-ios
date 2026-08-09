//
//  ComponentsPreview.swift
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

/// Every state of the shared `PIASwiftUI` components on one canvas.
///
/// Used by the SwiftUI previews and by the snapshot tests, so a visual regression in any component
/// state fails a test rather than reaching a screen.
///
/// The loading states deliberately use `nil` for `activityImage`: `LoadingView` animates forever and
/// would make snapshots non-deterministic, whereas the `ProgressView` fallback renders statically.
struct ComponentsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: PIASpacing.s24) {
            group("Primary") {
                button("Start My 7-day Free Trial", kind: .primary)
                button("Loading", kind: .primary, isLoading: true)
                button("Disabled", kind: .primary, isDisabled: true)
            }

            group("Secondary") {
                button("See Other Plans", kind: .secondary)
                button("Disabled", kind: .secondary, isDisabled: true)
            }

            group("Plain") {
                button("Restore Purchases", kind: .plain)
                button("Disabled", kind: .plain, isDisabled: true)
            }

            group("Badge") {
                HStack(spacing: PIASpacing.s8) {
                    PIABadge("Best Value", background: .pia.onWarningOutline, foreground: .pia.onSurface)
                    PIABadge("7-day Free Trial", background: .pia.successContainer, foreground: .pia.onSuccessContainer)
                }
            }

            group("Card shadow") {
                RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                    .fill(Color.pia.surfaceContainerPrimary)
                    .frame(height: 64)
                    .piaShadow()
            }
        }
        .padding(PIASpacing.s24)
        .background(Color.pia.background)
    }

    @ViewBuilder
    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PIASpacing.s8) {
            Text(title).typography(.subtitle3, color: .pia.onSurfaceContainerSecondary)
            content()
        }
    }

    private func button(
        _ title: String,
        kind: PIAButtonStyle.Kind,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) -> some View {
        Button(action: {}) {
            Text(title).typography(.button1)
        }
        .buttonStyle(PIAButtonStyle(kind, isLoading: isLoading))
        .disabled(isDisabled)
    }
}

#Preview("Light") {
    ComponentsPreview()
}

#Preview("Dark") {
    ComponentsPreview()
        .environment(\.colorScheme, .dark)
}
