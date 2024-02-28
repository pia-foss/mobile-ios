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
    
    static func makePrivacyPolicyView() -> PrivacyPolicyView {
        let privacyPolicyURL = URL(string: "https://www.privateinternetaccess.com/privacy-policy")!
        
        return PrivacyPolicyView(privacyPolicyURL: privacyPolicyURL)
    }
    
    static var makeLicensesUseCase: LicensesUseCaseType = {
        return LicensesUseCase(urlSession: URLSession.shared)
    }()
    
    
    private static func makeAcknowledgementsViewModel() -> AcknowledgementsViewModel {
        return AcknowledgementsViewModel(licencesUseCase: makeLicensesUseCase)
    }
    
    static func makeAcknowledgementsView() -> AcknowledgementsView {
        return AcknowledgementsView(viewModel: makeAcknowledgementsViewModel())
    }
    
}

