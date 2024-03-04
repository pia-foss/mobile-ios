//
//  RegionsContainerViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS

class RegionsContainerViewModelTests: XCTestCase {
    class Fixture {
        let favoritesUseCaseMock = FavoriteRegionUseCaseMock()
        let appRouterSpy = AppRouterSpy()
        var appRouterActionMock: AppRouter.Actions!
        
        init() {
            self.appRouterActionMock = AppRouter.Actions.navigate(router: appRouterSpy, destination: RegionsDestinations.search)
        }
        
    }
    
    var fixture: Fixture!
    var sut: RegionsContainerViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = RegionsContainerViewModel(favoritesUseCase: fixture.favoritesUseCaseMock, onSearchSelectedAction: fixture.appRouterActionMock)
    }
    
    func test_sideMenuFiltersDisabled_whenSideMenuSectionIsOutOfFocus() {
        // GIVEN that the current selected region filter is 'all'
        instantiateSut()
        sut.selectedSection = .all
        // AND GIVEN that the current focus is NOT on the side menu items
        
        let isAllDisabledWhenSideMenuOutOfFocus = sut.isRegionNavigationItemDisabled(.all, when: nil)
        
        let isFavoritesDisabledWhenSideMenuOutIsOfFocus = sut.isRegionNavigationItemDisabled(.favorites, when: nil)
        
        let isSearchDisabledWhenSideMenuOutIsOfFocus = sut.isRegionNavigationItemDisabled(.search, when: nil)
        
        // THEN only the 'All' item (selected section) remains enabled
        XCTAssertFalse(isAllDisabledWhenSideMenuOutOfFocus)
        XCTAssertTrue(isFavoritesDisabledWhenSideMenuOutIsOfFocus)
        XCTAssertTrue(isSearchDisabledWhenSideMenuOutIsOfFocus)
        
    }
    
    
    func test_sideMenuFiltersDisabled_whenSideMenuSectionIsNotOutOfFocus() {
        // GIVEN that the current selected region filter is 'all'
        instantiateSut()
        sut.selectedSection = .all
        // AND GIVEN that the current focus is on the side menu items
        
        let isAllDisabledWhenSideMenuOutOfFocus = sut.isRegionNavigationItemDisabled(.all, when: .all)
        
        let isFavoritesDisabledWhenSideMenuOutIsOfFocus = sut.isRegionNavigationItemDisabled(.favorites, when: .all)
        
        let isSearchDisabledWhenSideMenuOutIsOfFocus = sut.isRegionNavigationItemDisabled(.search, when: .all)
        
        // THEN None of the side menu filters are Disabled
        XCTAssertFalse(isAllDisabledWhenSideMenuOutOfFocus)
        XCTAssertFalse(isFavoritesDisabledWhenSideMenuOutIsOfFocus)
        XCTAssertFalse(isSearchDisabledWhenSideMenuOutIsOfFocus)
        
    }
    
}
