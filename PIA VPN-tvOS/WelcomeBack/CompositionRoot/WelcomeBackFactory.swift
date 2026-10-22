//
//  WelcomeBackFactory.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIAPaywall

class WelcomeBackFactory {
    @MainActor
    static func makeWelcomeBackView() -> WelcomeBackView {
        WelcomeBackView(
            dependencies: .live(
                accountProvider: Client.providers.accountProvider,
                store: Client.store,
                emit: handle))
    }

    static func makeHasActiveSubscriptionUseCase() -> HasActiveSubscriptionUseCase {
        HasActiveSubscriptionUseCase(store: Client.store)
    }

    @MainActor
    private static func handle(_ output: WelcomeBack.Output) {
        switch output {
        case .didAuthenticate(let user):
            // Same as signing in with credentials: an expired account goes to the expired screen.
            if user.info?.isExpired == true {
                AppRouter.navigateToExpiredDestinationAction()
            } else {
                AppRouter.navigateToConnectionstatsDestinationAction()
            }

        case .requestLogin:
            AppRouter.navigateToLoginWithCredentialsDestinationAction()

        case .requestQRLogin:
            AppRouter.navigateToLoginQRCodeDestinationAction()

        case .didDismiss:
            // Back to the paywall, unless the user already left this screen.
            guard AppRouter.shared.isShowing(AuthenticationDestinations.welcomeBack) else { return }
            AppRouter.shared.pop()
        }
    }
}
