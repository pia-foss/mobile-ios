//
//  AlertBannerView.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import PIADesignSystem
import SwiftUI

struct AlertBannerView: View {
    let banner: AlertBanner

    var body: some View {
        HStack(spacing: PIASpacing.s12) {
            if let image = banner.image {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .accessibilityHidden(true)
            }
            Text(banner.message)
                .typography(.body2, color: .white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(PIASpacing.s16)
        .background(
            RoundedRectangle(cornerRadius: PIARadius.r12, style: .continuous)
                .fill(banner.style.backgroundColor)
        )
        .piaShadow()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(banner.accessibilityIdentifier ?? "")
    }
}

/// Fills the overlay window and lays the current banner out at its top.
struct AlertBannerOverlay: View {
    @ObservedObject var presenter: AlertBannerPresenter
    let onBannerFrameChange: (CGRect) -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            if let presentation = presenter.current {
                AlertBannerView(banner: presentation.banner)
                    .offset(y: dragOffset)
                    .onTapGesture { presenter.dismiss(presentation.id) }
                    .gesture(swipeUpToDismiss(presentation))
                    .background(frameReader)
                    .id(presentation.id)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: 560)
        .padding(.horizontal, PIASpacing.s16)
        .padding(.top, PIASpacing.s8)
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: presenter.current?.id)
        .onPreferenceChange(BannerFrameKey.self) { frame in
            MainActor.assumeIsolated { onBannerFrameChange(frame) }
        }
        .onChange(of: presenter.current?.id) { _ in dragOffset = 0 }
    }

    private var frameReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: BannerFrameKey.self, value: proxy.frame(in: .global))
        }
    }

    private func swipeUpToDismiss(_ presentation: AlertBannerHub.Presentation) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let height = value.translation.height
                dragOffset = height < 0 ? height : height / 6
            }
            .onEnded { value in
                if value.translation.height < -24 || value.predictedEndTranslation.height < -80 {
                    presenter.dismiss(presentation.id)
                } else {
                    withAnimation(.spring()) { dragOffset = 0 }
                }
            }
    }
}

private struct BannerFrameKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if next != .zero { value = next }
    }
}

extension AlertBanner.Style {
    var backgroundColor: Color {
        switch self {
        case .error: Color(uiColor: .piaRed)
        case .warning: Color(uiColor: .piaOrange)
        case .success: Color(uiColor: .piaGreenDark20)
        }
    }
}

#Preview {
    VStack(spacing: PIASpacing.s16) {
        AlertBannerView(banner: AlertBanner(message: "Internet unreachable", image: UIImage(systemName: "exclamationmark.triangle.fill"), style: .error))
        AlertBannerView(banner: AlertBanner(message: "Your settings have been updated", style: .warning))
        AlertBannerView(banner: AlertBanner(message: "Login successful", style: .success))
    }
    .padding()
}
