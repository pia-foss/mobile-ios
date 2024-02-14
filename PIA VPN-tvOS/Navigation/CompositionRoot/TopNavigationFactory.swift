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
        return leadingNavigationViewShared
    }
    
    static func makeTrailingNavigationView() -> TrailingNavigationView {
        return trailingNavigationViewShared
    }
    
    static func makeTopNavigationViewModel() -> TopNavigationViewModel {
        return topNavigationViewModelShared
    }
    
    
    // MARK: - Private
    
    private static var topNavigationViewModelShared: TopNavigationViewModel = {
        TopNavigationViewModel(appRouter: AppRouterFactory.makeAppRouter())
    }()
    
    private static var leadingNavigationViewShared: LeadingSegmentedNavigationView = {
        LeadingSegmentedNavigationView(viewModel: makeTopNavigationViewModel())
    }()
    
    private static var trailingNavigationViewShared: TrailingNavigationView = {
        TrailingNavigationView(viewModel: makeTopNavigationViewModel())
    }()
    
}
