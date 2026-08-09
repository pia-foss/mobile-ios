//
//  LegalAgreementText.swift
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

/// "Signing up constitutes acceptance of the Terms of Service and the Privacy Policy", with both
/// named documents linked in place.
///
/// App Store Review Guideline 3.1.2 requires both links on any screen that sells a subscription.
/// The Figma for KM-17721 omits them, so the sentence is carried over verbatim from the screen this
/// one replaces — links embedded in the prose rather than standing alone, as before.
struct LegalAgreementText: View {
    let termsURL: URL
    let privacyURL: URL

    var body: some View {
        Text(agreement)
            .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var agreement: AttributedString {
        var attributed = AttributedString(Self.sentence)
        attributed.replacingPlaceholder("$1", with: L10n.Welcome.Agreement.Message.tos, linkedTo: termsURL)
        attributed.replacingPlaceholder("$2", with: L10n.Welcome.Agreement.Message.privacy, linkedTo: privacyURL)
        return attributed
    }

    /// The closing sentence of the agreement paragraph.
    ///
    /// `welcome.agreement.message` holds the long renewal terms, then a blank line, then the
    /// sentence shown here — and it is already translated into all 18 locales, which is why it is
    /// reused rather than replaced by a new key that would ship as English-only legal text.
    /// This is the same split the previous screen performed.
    ///
    /// If a translation ever drops the blank line the whole paragraph is shown, which is verbose but
    /// still correct — better than showing nothing.
    private static var sentence: String {
        // The paragraph's price placeholder belongs to the part being discarded.
        let full = L10n.Welcome.Agreement.message("")
        guard let separator = full.range(of: "\n\n", options: .backwards) else { return full }
        return String(full[separator.upperBound...])
    }
}

extension AttributedString {
    /// Swaps a `$n` placeholder for a tappable, underlined link.
    fileprivate mutating func replacingPlaceholder(_ placeholder: String, with title: String, linkedTo url: URL) {
        guard let range = range(of: placeholder) else { return }

        var link = AttributedString(title)
        link.link = url
        link.foregroundColor = .pia.primary
        link.underlineStyle = .single

        replaceSubrange(range, with: link)
    }
}
