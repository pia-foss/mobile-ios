//
//  PlatformSDKMigrationView.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsTV
import PIALocalizations
import SwiftUI

struct PlatformSDKMigrationView: View {

    let onConfirm: () -> Void

    @State private var isConfirming = false

    var body: some View {
        VStack(spacing: 0) {
            illustration

            Text(L10n.PlatformSdkMigration.Label.title)
                .font(.system(size: 57))
                .bold()
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.pia_on_background)
                .padding(.top, 40)

            Text(L10n.PlatformSdkMigration.Label.subtitle)
                .font(.system(size: 31))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.pia_on_surface_container_secondary)
                .padding(.top, 20)

            confirmButton
                .padding(.top, 60)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: Spacing.contentViewMaxWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var illustration: some View {
        Asset.configureRobots.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 300)
            .accessibilityHidden(true)
    }

    private var confirmButton: some View {
        ActionButton(
            title: L10n.PlatformSdkMigration.Button.confirm,
            action: confirmButtonTapped
        )
        .frame(width: 510, height: Spacing.settingsButtonHeight)
    }

    private func confirmButtonTapped() {
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
