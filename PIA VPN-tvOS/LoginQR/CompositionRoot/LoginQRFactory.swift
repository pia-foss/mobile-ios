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
        LoginQRViewModel(generateLoginQRCode: makeGenerateLoginQRCodeUseCase(),
                         validateLoginQRCode: makeValidateLoginQRCodeUseCase(),
                         loginWithReceipt: makeloginWithReceiptUseCase(),
                         onSuccessAction: {
            AppRouter.navigateToConnectionstatsDestinationAction()
        }, onNavigateAction: {
            AppRouter.navigateToRoot()
            AppRouter.navigateToLoginWithCredentialsDestinationAction()
        })
    }
    
    private static func makeGenerateLoginQRCodeUseCase() -> GenerateLoginQRCodeUseCaseType {
        GenerateLoginQRCodeUseCase(generateLoginQRCodeProvider: makeLoginQRProvider())
    }
    
    private static func makeLoginQRProvider() -> LoginQRProvider {
        LoginQRProvider(httpClient: URLSessionHTTPClient(),
                        urlRequestMaker: LoginQRURLRequestMaker(),
                        domainMapper: LoginQRCodeDomainMapper(), 
                        errorMapper: LoginQRErrorMapper(),
                        generateQRLogin: AccountFactory.makeGenerateQRLoginUseCase(),
                        accountProvider: Client.providers.accountProvider)
    }
    
    private static func makeValidateLoginQRCodeUseCase() -> ValidateLoginQRCodeUseCaseType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
    
        return ValidateLoginQRCodeUseCase(accountProviderType: defaultAccountProvider,
                                          validateLoginQRCodeProvider: makeLoginQRProvider())
    }
    
    private static func makeloginWithReceiptUseCase() -> LoginWithReceiptUseCaseType {
        LoginWithReceiptUseCase(paymentProvider: makePaymentProvider(),
                                loginProvider: LoginFactory.makeLoginProvider(),
                                errorMapper: LoginDomainErrorMapper())
    }
    
    private static func makePaymentProvider() -> PaymentProviderType {
        PaymentProvider(store: Client.store)
    }
}
