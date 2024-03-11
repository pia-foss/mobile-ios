//
//  LoginQRFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginQRFactory {
    static func makeLoginQRView() -> LoginQRContainerView {
        LoginQRContainerView(viewModel: makeLoginQRViewModel())
    }
    
    private static func makeLoginQRViewModel() -> LoginQRViewModel {
        LoginQRViewModel(generateLoginQRCode: generateLoginQRCodeUseCase(),
                         validateLoginQRCode: validateLoginQRCodeUseCase(),
                         onSuccessAction: {
            AppRouter.Actions.navigate(router: AppRouter.shared, destination: OnboardingDestinations.connectionstats)()
        }, onNavigateAction: {
            AppRouter.Actions.goBackToRoot(router: AppRouter.shared)()
            AppRouter.Actions.navigate(router: AppRouter.shared, destination: AuthenticationDestinations.loginCredentials)()
        })
    }
    
    private static func generateLoginQRCodeUseCase() -> GenerateLoginQRCodeUseCaseType {
        GenerateLoginQRCodeUseCase()
    }
    
    private static func validateLoginQRCodeUseCase() -> ValidateLoginQRCodeUseCaseType {
        ValidateLoginQRCodeUseCase()
    }
}
