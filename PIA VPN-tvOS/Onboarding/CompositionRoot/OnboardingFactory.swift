//
//  OnboardingFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

class OnboardingFactory {
    static func makeOnboardingConnectionStatsView() -> OnboardingComponentView {
        return OnboardingComponentView(viewModel: makeOnboardingConnectionStatsViewModel(),
                                       style: makeOnboardingConnectionStatsViewStyle())
    }
    
    private static func makeOnboardingConnectionStatsViewModel() -> OnboardingComponentViewModelType {
        let acceptButton = OnboardingComponentButton(title: L10n.Signup.Share.Data.Buttons.accept, 
                                                     action: {
            let connectionStatsPermisson = ConnectionStatsPermisson()
            connectionStatsPermisson.set(value: true)
            AppRouter.Actions.navigate(router: AppRouter.shared, destination: OnboardingDestinations.installVPNProfile)()
        })
        
        let declineButton = OnboardingComponentButton(title: L10n.Signup.Share.Data.Buttons.noThanks, 
                                                      action: {
            let connectionStatsPermisson = ConnectionStatsPermisson()
            connectionStatsPermisson.set(value: false)
            AppRouter.Actions.navigate(router: AppRouter.shared, destination: OnboardingDestinations.installVPNProfile)()
        })
        
        let title = L10n.Localizable.Onboarding.ConnectionStats.title
        let subtitle = L10n.Localizable.Onboarding.ConnectionStats.subtitle
        return OnboardingComponentViewModel(title: title,
                                            subtitle: subtitle,
                                            buttons: [acceptButton, declineButton])
    }
    
    private static func makeOnboardingConnectionStatsViewStyle() -> OnboardingComponentStytle {
        OnboardingComponentStytle(headerImage: nil,
                                  headerSpacing: 30,
                                  backgroundImage: .onboarding_stats_tv, 
                                  buttonsEdgeInsets: EdgeInsets(top: 40, leading: 30, bottom: 0, trailing: 0))
    }
}
