//
//  TypographyPreview.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 08.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import SwiftUI

/// Preview view demonstrating PIA typography styles
///
/// This is a runtime representation of the PIA iOS Typography design system.
/// Figma reference: https://www.figma.com/design/9fECLgfxfFunLz7eBSOYmg/-PIA--iOS---Components?node-id=1-35&m=dev
///
/// **Best previewed on iPad** for optimal viewing of the full layout.
@available(iOS 13.0, *)
struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("PIA Typography")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("PIA DESIGN SYSTEM")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding()
                .background(Color(red: 0.5, green: 0.85, blue: 0.5))
                
                // Column Headers
                HStack(spacing: 20) {
                    Spacer()
                        .frame(width: 100)
                    
                    Spacer()
                    
                    Text("Currently used in")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 150, alignment: .leading)
                    
                    Text("Adapted from")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 200, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Typography rows
                VStack(spacing: 40) {
                    TypographyRow(
                        label: "Title 1",
                        example: "In another moment down went Alice after it",
                        style: .title1,
                        currentUse: "Big header",
                        adaptedFrom: "Title2/Emphasized"
                    )
                    
                    TypographyRow(
                        label: "Title 2",
                        example: "Never once considering how in the world she was to get out again.",
                        style: .title2,
                        currentUse: "Header",
                        adaptedFrom: "Title3/Emphasized"
                    )
                    
                    TypographyRow(
                        label: "Title 3",
                        example: "Never once considering how in the world she was to get out again.",
                        style: .title3,
                        currentUse: "Header",
                        adaptedFrom: "Title3/Regular"
                    )
                    
                    TypographyRow(
                        label: "Subtitle 1",
                        example: "The rabbit-hole went straight on like a tunnel for some way,",
                        style: .subtitle1,
                        currentUse: "Connection Status",
                        adaptedFrom: "Headline/Regular"
                    )
                    
                    TypographyRow(
                        label: "Subtitle 2",
                        example: "The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think",
                        style: .subtitle2,
                        currentUse: "Title",
                        adaptedFrom: "Subheadline/Emphasized"
                    )
                    
                    TypographyRow(
                        label: "Subtitle 3",
                        example: "About stopping herself before she found herself falling down what seemed to be a very deep well.",
                        style: .subtitle3,
                        currentUse: "Subtitles, countries",
                        adaptedFrom: "Footnote/Emphasized"
                    )
                    
                    TypographyRow(
                        label: "Body 1",
                        example: "Either the well was very deep, or she fell very slowly, for she had plenty of time as she went down to look about her, and to wonder what was going to happen next.",
                        style: .body1,
                        currentUse: "Body copy",
                        adaptedFrom: "Body/Regular"
                    )
                    
                    TypographyRow(
                        label: "Body 2",
                        example: "But it was too dark to see anything; then she looked at the sides of the well, and noticed that they were filled with cupboards and book-shelves: here and there she saw maps and pictures hung upon pegs.",
                        style: .body2,
                        currentUse: "Dialogs, snackbars, hint bars",
                        adaptedFrom: "Subheadline/Regular"
                    )
                    
                    TypographyRow(
                        label: "Button 1",
                        example: "She took down a jar from one of the shelves as she passed; it was labelled \"ORANGE MARMALADE,\" but to her great disappointment it was empty: she did not like to drop the jar for fear of killing somebody underneath, so managed to put it into one of the cupboards as she fell past it.",
                        style: .button1,
                        currentUse: "CTA",
                        adaptedFrom: "Body/Regular"
                    )
                    
                    TypographyRow(
                        label: "Button 2",
                        example: "\"Well!\" thought Alice to herself. \"After such a fall as this, I shall think nothing of tumbling down stairs! How brave they'll all think me at home! Why, I wouldn't say anything about it, even if I fell off the top of the house!\" (Which was very likely true.)",
                        style: .button2,
                        currentUse: "Promo banner, CTA",
                        adaptedFrom: "Subheadline/Regular"
                    )
                    
                    TypographyRow(
                        label: "Caption 1",
                        example: "Down, down, down. Would the fall never come to an end?",
                        style: .caption1,
                        currentUse: "IAM, small text",
                        adaptedFrom: "Caption1/Regular"
                    )
                    
                    TypographyRow(
                        label: "Caption 2",
                        example: "\"I wonder how many miles I've fallen by this time?\" she said aloud.",
                        style: .caption2,
                        currentUse: "Smart/Current/Recent Location",
                        adaptedFrom: "Caption2/Regular"
                    )
                    
                    TypographyRow(
                        label: "Caption 3",
                        example: "\"I wonder how many miles I've fallen by this time?\" she said aloud.",
                        style: .caption3,
                        currentUse: "Text Link",
                        adaptedFrom: "Caption3/Regular/Underline"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
    }
}

/// Individual typography demonstration row
@available(iOS 13.0, *)
struct TypographyRow: View {
    let label: String
    let example: String
    let style: TypographyStyle
    let currentUse: String
    let adaptedFrom: String

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Label
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.6))
                .frame(width: 100, alignment: .leading)

            // Example text
            Text(example)
                .typography(style, color: .black)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Currently used in
            Text(currentUse)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
                .frame(width: 150, alignment: .leading)

            // Adapted from
            Text(adaptedFrom)
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
                .frame(width: 200, alignment: .leading)
        }
    }
}

@available(iOS 13.0, *)
#Preview {
    TypographyPreview()
}
