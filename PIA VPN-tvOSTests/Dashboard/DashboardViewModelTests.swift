//
//  DashboardViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 1/16/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS
import SwiftUI

class DashboardViewModelTests: XCTestCase {
    class Fixture {
        let accountProviderMock = AccountProviderTypeMock()
        let appRouter = AppRouter.shared
    }
    
    var fixture: Fixture!
    var sut: DashboardViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    private func initializeSut() {
        sut = DashboardViewModel(accountProvider: fixture.accountProviderMock, appRouter: fixture.appRouter, navigationDestination: RegionsDestinations.serversList)
    }
    
    func test_navigateToRegionsList() {
        // GIVEN that the Dashboard view is visible
        initializeSut()
        
        let emptyNavigationPath: NavigationPath = NavigationPath()
        let regionsListNavigationPath: NavigationPath = NavigationPath([RegionsDestinations.serversList])
        
        // AND GIVEN that the path of the navigation router is empty
        XCTAssertEqual(fixture.appRouter.path, emptyNavigationPath)
        XCTAssertTrue(fixture.appRouter.path.isEmpty)
        
        // WHEN the regions selection section is tapped
        sut.regionSelectionSectionWasTapped()
        
        // THEN the app router navigates to the Regions list
        XCTAssertFalse(fixture.appRouter.path.isEmpty)
        XCTAssertEqual(fixture.appRouter.path, regionsListNavigationPath)
        
    }
    
}
