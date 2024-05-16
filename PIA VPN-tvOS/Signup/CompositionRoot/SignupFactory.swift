//
//  SignupFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignUpFactory {
    static func makeSignupQRView() -> SignupQRView {
        let url = URL(string: "https://apps.apple.com/us/app/vpn-by-private-internet-access/id955626407")!
        return SignupQRView(signUpURL: url)
    }
    
    static func makeSignUpView() -> SignupView {
        let optionButtons = [
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.privacy, action: {
                AppRouter.navigateToPrivacyPolicyDestinationAction()
            }),
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.tos, action: {
                AppRouter.navigateToTermsAndConditionsDestinationAction()
            })
        ]
        
        return SignupView(viewModel: SignupViewModel(optionButtons: optionButtons,
                                                     getAvailableProducts: makeGetAvailableProductsUseCase(),
                                                     purchaseProduct: makePurchaseProductUseCase(),
                                                     viewModelMapper: SubscriptionOptionViewModelMapper(), signupPresentableMapper: SignupPresentableErrorMapper(), 
                                                     onSuccessAction: { transaction in
            SignupEmailFactory.transaction = transaction
            AppRouter.navigateToSignUpEmailDestinationAction()
        }))
    }
    
    private static func makeGetAvailableProductsUseCase() -> GetAvailableProductsUseCaseType {
        return GetAvailableProductsUseCase(productsProvider: makeDecoratorProductsProvider())
    }
    
    private static func makePurchaseProductUseCase() -> PurchaseProductUseCaseType {
        PurchaseProductUseCase(purchaseProductsProvider: makeDecoratorPurchaseProductsProvider())
    }
    
    private static func makeDecoratorProductsProvider() -> ProductsProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        
        return DecoratorProductsProvider(subscriptionInformationProvider: SubscriptionInformationProvider(accountProvider: defaultAccountProvider),
                                  decoratee: defaultAccountProvider,
                                  store: Client.store,
                                  productConfiguration: Client.configuration)
    }
    
    private static func makeDecoratorPurchaseProductsProvider() -> PurchaseProductsProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        
        return DecoratorPurchaseProductsProvider(purchaseProductsProvider: defaultAccountProvider,
                                                 errorMapper: PurchaseProductDomainErrorMapper(), 
                                                 store: Client.store)
    }
    
    static func makePrivacySignupTermsView() -> SignupTermsView {
        SignupTermsView(url: URL(string: "https://www.privateinternetaccess.com/privacy-policy")!,
                        title: L10n.Localizable.HelpMenu.AboutOptions.PrivacyPolicy.title,
                        description: L10n.Localizable.HelpMenu.AboutSection.PrivacyPolicy.description,
                        qrCodeMessage: L10n.Localizable.HelpMenu.AboutSection.PrivacyPolicy.QrCode.message)
    }
    
    static func makeTermsConditionsSignupTermsView() -> SignupTermsView {
        SignupTermsView(url: URL(string: "https://www.privateinternetaccess.com/terms-of-service")!,
                        title: L10n.Localizable.Tvos.Signup.TermsConditions.title,
                        description: L10n.Localizable.Tvos.Signup.TermsConditions.description,
                        qrCodeMessage: L10n.Localizable.Tvos.Signup.TermsConditions.QrCode.message)
    }
}

extension DefaultAccountProvider: ProductsProviderType {}
extension Client.Configuration: ProductConfigurationType {}
extension DefaultAccountProvider: PurchaseProductsAccountProviderType {}
