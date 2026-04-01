//
//  OnboardingComponentViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 6/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

struct OnboardingComponentButton {
    let title: String
    let action: () -> Void
}

protocol OnboardingComponentViewModelType {
    var title: String { get }
    var subtitle: String? { get }
    var buttons: [OnboardingComponentButton] { get }
}

class OnboardingComponentViewModel: OnboardingComponentViewModelType {
    let title: String
    let subtitle: String?
    let buttons: [OnboardingComponentButton]
    
    init(title: String, subtitle: String?, buttons: [OnboardingComponentButton]) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons
    }
}
