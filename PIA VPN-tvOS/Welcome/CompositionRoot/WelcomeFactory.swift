//
//  WelcomeFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

class WelcomeFactory {
    static func makeWelcomeView() -> OnboardingComponentView {
        OnboardingComponentView(viewModel: makeWelcomeViewModel(),
                                style: makeWelcomeViewStyle())
    }
    
    private static func makeWelcomeViewModel() -> OnboardingComponentViewModelType {
        let loginButton = OnboardingComponentButton(title: L10n.Localizable.Tvos.Welcome.Button.login) {
            AppRouter.navigateToLoginQRCodeDestinationAction()
        }
        
        let signupButton = OnboardingComponentButton(title: L10n.Localizable.Tvos.Welcome.Button.signup) {
            AppRouter.navigateToSignUpDestinationAction()
        }
        
        return OnboardingComponentViewModel(title: L10n.Localizable.Tvos.Welcome.title,
                                            subtitle: nil,
                                            buttons: [loginButton, signupButton])
    }
    
    private static func makeWelcomeViewStyle() -> OnboardingComponentStytle {
        OnboardingComponentStytle(headerImage: Image.onboarding_pia_brand,
                                  headerSpacing: 60,
                                  backgroundImage: Image.onboarding_signin_world, 
                                  buttonsEdgeInsets: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
    }
}
