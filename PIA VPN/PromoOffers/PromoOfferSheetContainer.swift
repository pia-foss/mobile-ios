//
//  PromoOfferSheetContainer.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import PIADesignSystem
import SwiftUI

/// Presents the offer as a bottom sheet: dimmed backdrop, drag to dismiss, rounded top corners.
///
/// Hand-rolled because `.presentationDetents` is iOS 16 and the deployment target is iOS 15.
/// `PIAPaywall.PaywallSheetContainer` solves the same problem but is internal to that package; if a
/// third sheet appears, both belong in `PIASwiftUI`.
struct PromoOfferSheetContainer<Content: View>: View {
    let isPresented: Bool
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

    private var card: some View {
        VStack {
            Spacer(minLength: 0)

            content()
                .frame(maxWidth: Metrics.maxWidth)
                .clipShape(
                    TopRoundedRectangle(radius: Metrics.cornerRadius)
                )
                .piaShadow()
                // What a real sheet gives for free: trap VoiceOver inside the card, and give the
                // escape gesture something to do.
                .accessibilityAddTraits(.isModal)
                .accessibilityAction(.escape, dismiss)
                .offset(y: max(0, dragOffset))
                .gesture(dragToDismiss)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .transition(.move(edge: .bottom))
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
    /// Not one of the `PIARadius` tokens.
    static let cornerRadius: CGFloat = 8
    /// Matches the cap on the primary button's width, so the sheet does not outgrow it on an iPad.
    static let maxWidth: CGFloat = 520
    /// How far the card must be dragged before the gesture counts as a dismissal.
    static let dismissThreshold: CGFloat = 100
}

/// Rounds the top two corners only. `RoundedRectangle` rounds all four, and `cornerRadius(_:corners:)`
/// is UIKit-only.
private struct TopRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

#if DEBUG
    #Preview {
        PromoOfferSheetContainer(isPresented: true, onDismiss: {}) {
            PromoOfferDetailsSheet(data: .preview, isPurchasing: false, errorMessage: nil, onClaim: {})
        }
        .background(Color.pia.background)
    }
#endif
