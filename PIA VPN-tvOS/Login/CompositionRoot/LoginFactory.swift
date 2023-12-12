//
//  LoginFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class LoginFactory {
    static func makeLoginView() -> LoginView {
        LoginView(viewModel: makeLoginViewModel())
    }
    
    private static func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(loginWithCredentialsUseCase: makeLoginWithCredentialsUseCase(),
                       checkLoginAvailability: CheckLoginAvailability(),
                       validateLoginCredentials: ValidateCredentialsFormat(),
                       errorMapper: LoginPresentableErrorMapper())
    }
    
    private static func makeLoginWithCredentialsUseCase() -> LoginWithCredentialsUseCaseType {
        LoginWithCredentialsUseCase(loginProvider: makeLoginProvider(),
                                    errorMapper: LoginDomainErrorMapper())
    }
    
    private static func makeLoginProvider() -> LoginProviderType {
        LoginProvider(accountProvider: Client.providers.accountProvider, 
                      userAccountMapper: UserAccountMapper())
    }
}
