//
//  HelpFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation


class HelpFactory {
    static func makeHelpOptionsView() -> HelpOptionsView {
        HelpOptionsView(viewModel: makeHelpOptionsViewModel())
    }
    
    private static func makeHelpOptionsViewModel() -> HelpOptionsViewModel {
        HelpOptionsViewModel(connectionStatsPermission: OnboardingFactory.makeConnectionStatsPermission(), aboutOptionNavigationAction: .navigate(router: AppRouterFactory.makeAppRouter(), destination: HelpDestinations.about), infoDictionary: Bundle.main.infoDictionary)
    }
    
    static func makeAboutOptionsView() -> AboutOptionsView {
        AboutOptionsView(viewModel: makeAboutOptionsViewModel())
    }
    
    private static func makeAboutOptionsViewModel() -> AboutOptionsViewModel {
        let appRouter = AppRouterFactory.makeAppRouter()
        return AboutOptionsViewModel(
            onAcknowledgementsAction: .navigate(router: appRouter, destination: HelpDestinations.acknowledments),
            onPrivacyPolicyAction: .navigate(router: appRouter, destination: HelpDestinations.privacyPolicy))
    }
    
    
}

