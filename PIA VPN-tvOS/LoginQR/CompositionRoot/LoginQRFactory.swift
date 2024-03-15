//
//  LoginQRFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 4/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class LoginQRFactory {
    static func makeLoginQRView() -> LoginQRContainerView {
        LoginQRContainerView(viewModel: makeLoginQRViewModel())
    }
    
    private static func makeLoginQRViewModel() -> LoginQRViewModel {
        LoginQRViewModel(generateLoginQRCode: generateLoginQRCodeUseCase(),
                         validateLoginQRCode: validateLoginQRCodeUseCase(),
                         onSuccessAction: {
            AppRouter.navigateToConnectionstatsDestinationAction()
        }, onNavigateAction: {
            AppRouter.navigateToRoot()
            AppRouter.navigateToLoginWithCredentialsDestinationAction()
        })
    }
    
    private static func generateLoginQRCodeUseCase() -> GenerateLoginQRCodeUseCaseType {
        GenerateLoginQRCodeUseCase(generateLoginQRCodeProvider: makeLoginQRProvider())
    }
    
    private static func makeLoginQRProvider() -> LoginQRProvider {
        LoginQRProvider(httpClient: URLSessionHTTPClient(),
                        urlRequestMaker: LoginQRURLRequestMaker(),
                        domainMapper: LoginQRCodeDomainMapper(), 
                        errorMapper: LoginQRErrorMapper())
    }
    
    private static func validateLoginQRCodeUseCase() -> ValidateLoginQRCodeUseCaseType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
    
        return ValidateLoginQRCodeUseCase(accountProviderType: defaultAccountProvider,
                                          validateLoginQRCodeProvider: makeLoginQRProvider())
    }
}
