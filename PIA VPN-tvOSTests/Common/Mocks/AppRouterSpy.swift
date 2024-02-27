//
//  AppRouterSpy.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 15/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class AppRouterSpy: AppRouterType {
    
    enum Request: Equatable {
        static func == (lhs: AppRouterSpy.Request, rhs: AppRouterSpy.Request) -> Bool {
            switch (lhs, rhs) {
                case let (.navigate(lhsRoute), .navigate(rhsRoute)):
                
                    if let lhsOnboarding = lhsRoute as? OnboardingDestinations, let rhsOnboarding = rhsRoute as? OnboardingDestinations {
                        return lhsOnboarding == rhsOnboarding
                    }
                
                    if let lhsAuth = lhsRoute as? AuthenticationDestinations, let rhsAuth = rhsRoute as? AuthenticationDestinations {
                        return lhsAuth == rhsAuth
                    }
                
                    if let lhsHelp = lhsRoute as? HelpDestinations,
                       let rhsHelp = rhsRoute as? HelpDestinations {
                        return lhsHelp == rhsHelp
                    }
                    return false
                case (.pop, .pop), (.goBackToRoot, .goBackToRoot):
                    return true
                default:
                    return false
            }
        }
        
        case navigate(any Destinations)
        case pop
        case goBackToRoot
    }
    
    var stackCount: Int = 0
    var requests = [AppRouterSpy.Request]()
    
    var didGetARequest: (() -> Void)?
    
    func navigate(to destination: any Destinations) {
        requests.append(.navigate(destination))
        didGetARequest?()
    }
    
    func pop() {
        requests.append(.pop)
        didGetARequest?()
    }
    
    func goBackToRoot() {
        requests.append(.goBackToRoot)
        didGetARequest?()
    }
}
