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
    
    
    // MARK: - Private
    
    private static var leadingNavigationViewModelShared: LeadingNavigationBarViewModel = {
        LeadingNavigationBarViewModel(appRouter: AppRouterFactory.makeAppRouter())
    }()
    
    private static var trailingNavigationViewModelShared: TrailingNavigationBarViewModel = {
        TrailingNavigationBarViewModel(appRouter: AppRouterFactory.makeAppRouter())
    }()

    
    private static var leadingNavigationViewShared: LeadingSegmentedNavigationView = {
        LeadingSegmentedNavigationView(viewModel: leadingNavigationViewModelShared)
    }()
    
    private static var trailingNavigationViewShared: TrailingNavigationView = {
        TrailingNavigationView(viewModel: trailingNavigationViewModelShared)
    }()
    
}
