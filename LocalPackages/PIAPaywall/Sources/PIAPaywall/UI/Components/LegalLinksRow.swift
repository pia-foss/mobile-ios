//
//  LegalLinksRow.swift
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

import PIADesignSystem
import PIALocalizations
import SwiftUI

/// Links to the Terms of Service and the Privacy Policy.
///
/// App Store Review Guideline 3.1.2 requires both on any screen that sells a subscription. The
/// Figma for KM-17721 omits them; dropping them would fail review, so they are carried over from
/// the screen this one replaces.
struct LegalLinksRow: View {
    let termsURL: URL
    let privacyURL: URL

    var body: some View {
        HStack(spacing: PIASpacing.s16) {
            link(title: L10n.Welcome.Agreement.Message.tos, url: termsURL)
            link(title: L10n.Welcome.Agreement.Message.privacy, url: privacyURL)
        }
        .frame(maxWidth: .infinity)
    }

    private func link(title: String, url: URL) -> some View {
        Link(destination: url) {
            // `.caption3` is the design system's underlined caption — exactly a link style, and it
            // avoids `View.underline()`, which is iOS 16+.
            Text(title)
                .typography(.caption3, color: .pia.onSurfaceContainerPrimary)
        }
        .accessibilityAddTraits(.isLink)
    }
}
