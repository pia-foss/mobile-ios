//
//  WelcomeBackFactory.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class WelcomeBackFactory {
    @MainActor
    static func makeWelcomeBackView() -> WelcomeBackView {
        WelcomeBackView(viewModel: makeWelcomeBackViewModel())
    }

    @MainActor
    private static func makeWelcomeBackViewModel() -> WelcomeBackViewModel {
        WelcomeBackViewModel(
            loginWithCurrentReceipt: makeLoginWithCurrentReceiptUseCase(),
            onSuccessAction: {
                AppRouter.navigateToConnectionstatsDestinationAction()
            },
            onRequestLoginAction: {
                AppRouter.navigateToLoginWithCredentialsDestinationAction()
            },
            onDismissAction: {
                // Back to the paywall, unless the user already left this screen.
                guard AppRouter.shared.isShowing(AuthenticationDestinations.welcomeBack) else { return }
                AppRouter.shared.pop()
            })
    }

    static func makeHasActiveSubscriptionUseCase() -> HasActiveSubscriptionUseCaseType {
        HasActiveSubscriptionUseCase(paymentProvider: LoginQRFactory.makePaymentProvider())
    }

    static func makeLoginWithCurrentReceiptUseCase() -> LoginWithCurrentReceiptUseCaseType {
        LoginWithCurrentReceiptUseCase(
            paymentProvider: LoginQRFactory.makePaymentProvider(),
            loginProvider: LoginFactory.makeLoginProvider(),
            errorMapper: LoginDomainErrorMapper())
    }
}
