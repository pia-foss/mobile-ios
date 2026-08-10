//
//  PaywallBackgroundView.swift
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
import SwiftUI

/// The paywall's backdrop: the standard page background with a large ring bleeding off the top edge.
///
/// The ring is drawn rather than shipped as artwork — it is one primitive, and drawing keeps it crisp
/// at any size and correct in both colour schemes without an asset.
struct PaywallBackgroundView: View {
    /// The ring as designed: in a 402pt-wide frame, 444pt across and 62pt thick, centred 262pt in
    /// from the left and 68pt above the top edge. Scaled by the canvas's shorter edge, so a 402pt
    /// phone draws these points unchanged and a landscape iPad is sized by its height.
    private enum Ring {
        static let frameWidth: CGFloat = 402
        static let diameter: CGFloat = 444
        static let lineWidth: CGFloat = 62
        static let centre = CGPoint(x: 262, y: -68)

        static func scale(on canvas: CGSize) -> CGFloat {
            min(canvas.width, canvas.height) / frameWidth
        }
    }

    var body: some View {
        // `ignoresSafeArea` sits on the colour, and the `GeometryReader` measuring the ring sits
        // inside the overlay. The other way round — a `GeometryReader` carrying the modifier — leaves
        // the status-bar strip unpainted on iOS 15, where the window's black shows through.
        Color.pia.background
            .overlay(alignment: .topLeading) {
                GeometryReader { proxy in
                    ring(on: proxy.size)
                }
                .clipped()
            }
            .ignoresSafeArea()
    }

    private func ring(on canvas: CGSize) -> some View {
        let scale = Ring.scale(on: canvas)
        let diameter = Ring.diameter * scale

        return Circle()
            .strokeBorder(
                Color.pia.surfaceContainerPrimary.opacity(0.6),
                lineWidth: Ring.lineWidth * scale
            )
            .frame(width: diameter, height: diameter)
            .offset(
                x: Ring.centre.x * scale - diameter / 2,
                y: Ring.centre.y * scale - diameter / 2
            )
            .accessibilityHidden(true)
    }
}

#Preview("Light") {
    PaywallBackgroundView()
}

#Preview("Dark") {
    PaywallBackgroundView()
        .environment(\.colorScheme, .dark)
}
