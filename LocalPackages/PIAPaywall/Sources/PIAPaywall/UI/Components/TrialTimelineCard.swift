//
//  TrialTimelineCard.swift
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

/// "How your free trial works": today, then day seven.
///
/// Only shown when a trial is actually on offer — with no trial the timeline would describe
/// something that is not going to happen.
struct TrialTimelineCard: View {
    let layout: PaywallLayout
    let trialDays: Int

    private enum Metrics {
        static let gutterWidth: CGFloat = 30
        static let activeNodeSize: CGFloat = 16
        static let activeGlowSize: CGFloat = 29
        static let activeInnerSize: CGFloat = 6
        static let inactiveNodeSize: CGFloat = 12
        static let inactiveInnerSize: CGFloat = 5
        static let connectorWidth: CGFloat = 4
        static let cardPadding: CGFloat = PIASpacing.s20

        /// How far the line runs on past the Day 7 node before fading out. Sized so the node lands
        /// level with the "Day 7" heading rather than at the bottom of its description.
        static let tailLength: CGFloat = 26
    }

    /// Scales the tail with Dynamic Type, so the Day 7 node keeps tracking its heading as the text
    /// grows rather than drifting below it.
    @ScaledMetric private var tailLength: CGFloat = Metrics.tailLength

    var body: some View {
        Group {
            switch layout {
            case .compact:
                VStack(alignment: .leading, spacing: PIASpacing.s16) {
                    title
                    steps
                }
            case .wide:
                HStack(alignment: .center, spacing: PIASpacing.s24) {
                    title
                    steps
                }
            }
        }
        .padding(Metrics.cardPadding)
        // Compact fills the column; wide sits beside the hero and must size to its content instead
        // of stretching across the whole canvas.
        .frame(maxWidth: layout == .compact ? .infinity : nil, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                .fill(Color.pia.surfaceContainerPrimary)
        )
        .piaShadow()
    }

    private var title: some View {
        Text(L10n.Signup.Paywall.Trial.Card.title)
            .typography(.subtitle2, color: .pia.onSurface)
    }

    /// The connector has to span exactly from the first node to the second, and both step blocks
    /// grow with Dynamic Type. Rather than hardcode a height, the gutter is laid out beside the
    /// text and stretched to whatever height the text ends up needing.
    private var steps: some View {
        HStack(alignment: .top, spacing: PIASpacing.s16) {
            gutter
            VStack(alignment: .leading, spacing: PIASpacing.s16) {
                step(
                    title: L10n.Signup.Paywall.Trial.Step1.title,
                    description: L10n.Signup.Paywall.Trial.Step1.description
                )
                step(
                    title: L10n.Signup.Paywall.Trial.Step2.title(trialDays),
                    description: L10n.Signup.Paywall.Trial.Step2.description
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Today's node carries a halo, the line runs solid down to the Day 7 node, then continues a
    /// little further and fades out — the trial has a definite start but an open-ended future.
    private var gutter: some View {
        VStack(spacing: 0) {
            activeNode

            Rectangle()
                .fill(PaywallColor.timelineInactive)
                .frame(width: Metrics.connectorWidth)
                .frame(maxHeight: .infinity)

            inactiveNode

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [PaywallColor.timelineInactive, PaywallColor.timelineInactive.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: Metrics.connectorWidth, height: tailLength)
        }
        .frame(width: Metrics.gutterWidth)
        .accessibilityHidden(true)
    }

    private var activeNode: some View {
        Circle()
            .fill(PaywallColor.timelineActive)
            .frame(width: Metrics.activeNodeSize, height: Metrics.activeNodeSize)
            .overlay(
                Circle()
                    .fill(PaywallColor.onTimelineNode)
                    .frame(width: Metrics.activeInnerSize, height: Metrics.activeInnerSize)
            )
            .background(
                Circle()
                    .fill(PaywallColor.timelineInactive.opacity(0.35))
                    .frame(width: Metrics.activeGlowSize, height: Metrics.activeGlowSize)
            )
            // The halo is wider than the node; without this it would push the line off-centre.
            .frame(width: Metrics.activeGlowSize, height: Metrics.activeGlowSize)
    }

    private var inactiveNode: some View {
        Circle()
            .fill(PaywallColor.timelineInactive)
            .frame(width: Metrics.inactiveNodeSize, height: Metrics.inactiveNodeSize)
            .overlay(
                Circle()
                    .fill(PaywallColor.onTimelineNode)
                    .frame(width: Metrics.inactiveInnerSize, height: Metrics.inactiveInnerSize)
            )
    }

    private func step(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: PIASpacing.s4) {
            Text(title).typography(.subtitle2, color: .pia.onSurface)
            Text(description).typography(.caption1, color: .pia.onSurfaceContainerSecondary)
        }
        // Read as one sentence rather than two disconnected fragments.
        .accessibilityElement(children: .combine)
    }
}
