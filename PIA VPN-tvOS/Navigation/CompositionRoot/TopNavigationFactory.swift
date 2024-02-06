//
//  TopNavigationFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation


class TopNavigationFactory {
    
    static func makeLeadingSegmentedNavigationView() -> LeadingSegmentedNavigationView {
        return LeadingSegmentedNavigationView(viewModel: makeTopNavigationViewModel())
    }
    
    static func makeTrailingNavigationView() -> TrailingNavigationView {
        return TrailingNavigationView(viewModel: makeTopNavigationViewModel())
    }
    
    static func makeTopNavigationViewModel() -> TopNavigationViewModel {
        return TopNavigationViewModel(appRouter: AppRouterFactory.makeAppRouter())
    }
    
}
