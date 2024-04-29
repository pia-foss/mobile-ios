//
//  SignupEmailFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupEmailFactory {
    static var transaction: InAppTransaction?
    
    static func makeSignupEmailView() -> SignupEmailView {
        SignupEmailView(viewModel: makeSignupEmailViewModel(transaction: transaction))
    }
    
    private static func makeSignupEmailViewModel(transaction: InAppTransaction?) -> SignupEmailViewModel {
        SignupEmailViewModel(signupUseCase: makeSignupUseCase(), transaction: transaction, onSuccessAction: { userAccount in
            SignupCredentialsFactory.userAccount = userAccount
            AppRouter.navigateToSignUpCredentialsDestinationAction()
        })
    }
    
    private static func makeSignupUseCase() -> SignupUseCaseType {
        SignupUseCase(signupProvider: makeSignupProvider())
    }
    
    private static func makeSignupProvider() -> SignupProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        
        return SignupProvider(accountProvider: defaultAccountProvider, 
                              userAccountMapper: UserAccountMapper(),
                              store: Client.store,
                              errorMapper: SignupDomainErrorMapper())
    }
}
