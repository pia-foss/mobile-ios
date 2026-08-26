//
//  PlatformSDKMigrationView.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsMobile
import PIADesignSystem
import PIALocalizations
import PIASwiftUI
import SwiftUI

struct PlatformSDKMigrationView: View {

    let onConfirm: () -> Void

    @State private var isConfirming = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    content
                        .frame(maxWidth: 440)
                }
                .frame(width: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
        .background(Color.pia.background.ignoresSafeArea())
    }

    private var content: some View {
        VStack(spacing: 0) {
            illustration

            Text(L10n.PlatformSdkMigration.Label.title)
                .typography(.title2, color: .pia.onBackground)
                .padding(.top, PIASpacing.s24)

            Text(L10n.PlatformSdkMigration.Label.subtitle)
                .typography(.body2, color: .pia.onSurfaceContainerSecondary)
                .padding(.top, PIASpacing.s16)

            confirmButton
                .padding(.top, PIASpacing.s24)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, PIASpacing.s24)
        .padding(.vertical, PIASpacing.s24)
    }

    private var illustration: some View {
        Asset.Cards.WireGuard.wgMain.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .accessibilityHidden(true)
    }

    private var confirmButton: some View {
        Button(action: confirmButtonWasTapped) {
            Text(L10n.PlatformSdkMigration.Button.confirm)
                .typography(.button1)
        }
        .buttonStyle(
            PIAButtonStyle(
                .primary,
                isLoading: isConfirming,
                activityImage: Asset.piaSpinner.swiftUIImage
            )
        )
        .accessibilityIdentifier("id.platformSDKMigration.confirm")
    }

    private func confirmButtonWasTapped() {
        guard !isConfirming else {
            return
        }

        isConfirming = true
        onConfirm()
    }
}

#Preview {
    PlatformSDKMigrationView(onConfirm: {})
}
