//
//  SignupFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SignUpFactory {
    static func makeSignupQRView() -> SignupQRView {
        let url = URL(string: "https://apps.apple.com/us/app/vpn-by-private-internet-access/id955626407")!
        return SignupQRView(signUpURL: url)
    }
    
    static func makeSignUpView() -> SignupView {
        let optionButtons = [
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.privacy, action: {}),
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.tos, action: {})
        ]
        
        return SignupView(viewModel: SignupViewModel(optionButtons: optionButtons,
                                                     getAvailableProducts: GetAvailableProductsUseCase(),
                                                     purchaseProduct: PurchaseProductUseCase(),
                                                     viewModelMapper: SubscriptionOptionViewModelMapper()))
    }
}
