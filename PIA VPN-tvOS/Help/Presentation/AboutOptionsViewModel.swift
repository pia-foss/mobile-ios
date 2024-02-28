//
//  HelpSettingsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class AboutOptionsViewModel: ObservableObject {
    enum Sections: Equatable, Identifiable {
        case acknowledgements
        case privacyPolicy
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .acknowledgements:
                return L10n.Localizable.HelpMenu.AboutOptions.Acknowledgements.title
            case .privacyPolicy:
                return L10n.Localizable.HelpMenu.AboutOptions.PrivacyPolicy.title
            }
        }
    }
    
    let onAcknowledgementsAction: AppRouter.Actions
    let onPrivacyPolicyAction: AppRouter.Actions
    
    // TODO: Add .acknowledgments section here when implemented
    let sections: [Sections] = [.privacyPolicy]
    
    init(onAcknowledgementsAction: AppRouter.Actions, onPrivacyPolicyAction: AppRouter.Actions) {
        self.onAcknowledgementsAction = onAcknowledgementsAction
        self.onPrivacyPolicyAction = onPrivacyPolicyAction
    }
    
    func navigate(to section: Sections) {
        switch section {
        case .acknowledgements:
            onAcknowledgementsAction()
        case .privacyPolicy:
            onPrivacyPolicyAction()
        }
    }
}
