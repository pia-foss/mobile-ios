//
//  SocialProofRow.swift
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

/// The App Store rating line: five stars, the score, and how many ratings it is based on.
struct SocialProofRow: View {
    /// The published App Store figures. Marketing copy rather than live data — update them here when
    /// the store listing moves.
    enum Rating {
        static let score = 4.7
        static let displayScore = "4.7"
        static let count = "223K"
        static let starCount = 5
    }

    var body: some View {
        HStack(spacing: PIASpacing.s8) {
            RatingStars(score: Rating.score, starCount: Rating.starCount)

            Text(L10n.Signup.Paywall.socialProof(Rating.displayScore, Rating.count))
                .typography(.caption1, color: .pia.onSurfaceContainerPrimary)
        }
        // Five separate star glyphs would be read out one by one otherwise.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.Signup.Paywall.Accessibility.rating(Rating.displayScore, Rating.count))
    }
}

/// Stars for a fractional rating: whole stars filled, the last one filled proportionally.
///
/// A 4.7 rating shows four full stars and one filled to 70% of its width — the same way the App
/// Store draws it. The unfilled remainder is transparent, not a greyed-out star, matching the
/// design. Drawn rather than shipped as artwork so the fraction follows the score.
private struct RatingStars: View {
    let score: Double
    let starCount: Int

    private enum Metrics {
        static let starSize: CGFloat = 13
        static let spacing: CGFloat = 1
    }

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            ForEach(0..<starCount, id: \.self) { index in
                star(fillFraction: fillFraction(at: index))
            }
        }
    }

    /// How much of the star at `index` is covered by the score: 1 for a whole star, 0 for an empty
    /// one, and the remainder for the one the score lands inside.
    private func fillFraction(at index: Int) -> CGFloat {
        CGFloat(min(max(score - Double(index), 0), 1))
    }

    private func star(fillFraction: CGFloat) -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Metrics.starSize, height: Metrics.starSize)
            .foregroundColor(PaywallColor.ratingStar)
            .mask(alignment: .leading) {
                Rectangle().frame(width: Metrics.starSize * fillFraction)
            }
    }
}
