//
//  WelcomeBackView.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsTV
import PIALocalizations
import SwiftUI

/// Shown over the signup paywall when the App Store already holds a live subscription for this
/// Apple ID. The remote's Menu button returns to the paywall.
struct WelcomeBackView: View {
    fileprivate enum Metrics {
        static let contentWidth: CGFloat = 768
        static let buttonSize = CGSize(width: 510, height: 66)
    }

    @StateObject var viewModel: WelcomeBackViewModel

    var body: some View {
        if viewModel.isRestoring {
            LoginLoadingView()
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 64) {
                    Asset.piaBrand.swiftUIImage

                    VStack(alignment: .leading, spacing: 24) {
                        Text(L10n.Signup.WelcomeBack.title)
                            .font(.system(size: 57))
                            .bold()
                        Text(L10n.Signup.WelcomeBack.message)
                            .font(.system(size: 38))
                    }
                    .foregroundColor(.piaOnBackground)
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 24) {
                        Text(L10n.Signup.WelcomeBack.signInWith)
                            .font(.system(size: 29, weight: .medium))
                            .foregroundColor(.piaOnBackground)

                        VStack(spacing: 16) {
                            ActionButton(
                                title: L10n.Signup.WelcomeBack.Cta.appStore,
                                action: { viewModel.appStoreAccountTapped() }
                            )
                            .frame(width: Metrics.buttonSize.width, height: Metrics.buttonSize.height)
                            .accessibilityIdentifier(WelcomeBackAccessibility.appStoreButton)

                            ActionButton(
                                title: L10n.Signup.WelcomeBack.Cta.credentials,
                                action: { viewModel.usernameAndPasswordTapped() }
                            )
                            .frame(width: Metrics.buttonSize.width, height: Metrics.buttonSize.height)
                            .accessibilityIdentifier(WelcomeBackAccessibility.credentialsButton)
                        }
                    }
                }
                .frame(maxWidth: Metrics.contentWidth, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                .frame(maxWidth: .infinity, alignment: .leading)

                Asset.welcomeBack.swiftUIImage
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
            }
        }
    }
}

enum WelcomeBackAccessibility {
    static let appStoreButton = "id.welcome_back.app_store"
    static let credentialsButton = "id.welcome_back.credentials"
}

// MARK: - Preview

#Preview {
    WelcomeBackView(
        viewModel: WelcomeBackViewModel(
            loginWithCurrentReceipt: WelcomeBackFactory.makeLoginWithCurrentReceiptUseCase(),
            onSuccessAction: {},
            onRequestLoginAction: {},
            onDismissAction: {}))
}
