//
//  PaywallSheetContainer.swift
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

/// Presents the plan picker: a bottom sheet on a phone, a centred card on a landscape iPad.
///
/// Hand-rolled rather than `.sheet` + `.presentationDetents`, which is iOS 16+ while the deployment
/// target is iOS 15. Owning the presentation also means one implementation covers both the bottom
/// sheet and the centred-card variant, and the selection stays in `PaywallState` instead of being
/// split across a UIKit presentation boundary.
///
/// What this gives up versus a real sheet: the system grabber and interactive detents. The modal
/// accessibility behaviour is therefore declared explicitly below.
struct PaywallSheetContainer<Content: View>: View {
    let isPresented: Bool
    let layout: PaywallLayout
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            if isPresented {
                backdrop
                card
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
    }

    private var backdrop: some View {
        Color.pia.surfaceOverlay
            .ignoresSafeArea()
            .onTapGesture(perform: dismiss)
            .transition(.opacity)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var card: some View {
        switch layout {
        case .compact:
            VStack {
                Spacer(minLength: 0)
                cardBody
                    .clipShape(
                        RoundedCornerShape(radius: Metrics.cornerRadius, corners: [.topLeft, .topRight])
                    )
                    .offset(y: max(0, dragOffset))
                    .gesture(dragToDismiss)
            }
            .ignoresSafeArea(edges: .bottom)
            .transition(.move(edge: .bottom))

        case .wide:
            cardBody
                .frame(maxWidth: Metrics.centredMaxWidth)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
                .padding(PIASpacing.s24)
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
        }
    }

    private var cardBody: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(Color.pia.surfaceContainerPrimary)
            // Replaces what a real sheet does for free: trap VoiceOver inside the card and give the
            // escape gesture something to do.
            .accessibilityAddTraits(.isModal)
            .accessibilityAction(.escape, dismiss)
    }

    private var dragToDismiss: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let shouldDismiss =
                    value.translation.height > Metrics.dismissThreshold
                    || value.predictedEndTranslation.height > Metrics.dismissThreshold * 2
                dragOffset = 0
                if shouldDismiss { dismiss() }
            }
    }

    private func dismiss() {
        dragOffset = 0
        onDismiss()
    }
}

/// At file scope rather than nested: a generic type cannot hold static stored properties.
private enum Metrics {
    static let cornerRadius: CGFloat = 16
    static let centredMaxWidth: CGFloat = 480
    /// How far the card must be dragged before the gesture counts as a dismissal.
    static let dismissThreshold: CGFloat = 100
}

/// Rounds only some corners. `RoundedRectangle` rounds all four, and `cornerRadius(_:corners:)` is
/// UIKit-only.
private struct RoundedCornerShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}
