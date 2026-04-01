//
//  RegionsContainerViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
import Combine
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
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
    }
    
    private func instantiateSut() {
        sut = RegionsContainerViewModel(favoritesUseCase: fixture.favoritesUseCaseMock, onSearchSelectedAction: fixture.appRouterActionMock)
    }
    
    private func subscribeToSideMenuUpdatesWithExpectation(_ expectation: XCTestExpectation, expectedItemsCount: Int) {
        sut.$sideMenuItems
            .sink { newItems in
                if newItems.count == expectedItemsCount {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
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
    
    func test_sideMenuItemsWhenFavoritesStored() {
        let sideMenuItemsUpdated = expectation(description: "Side menu items updated")
        // GIVEN that an item is added to favorites
        fixture.favoritesUseCaseMock.favorites = ["server-id-one"]
        instantiateSut()
        subscribeToSideMenuUpdatesWithExpectation(sideMenuItemsUpdated, expectedItemsCount: 3)
        
        wait(for: [sideMenuItemsUpdated], timeout:  3)
        // THEN the sections shown on the left side are 3 (Favorites, All and Search)
        XCTAssertEqual(sut.sideMenuItems.count, 3)
        XCTAssertEqual(sut.sideMenuItems, [.favorites, .all, .search])
    }
    
    func test_sideMenuItemsWhenNoFavoritesStored() {
        let sideMenuItemsUpdated = expectation(description: "Side menu items updated")
        // GIVEN that no items are added to favorites
        fixture.favoritesUseCaseMock.favorites = []
        instantiateSut()
        subscribeToSideMenuUpdatesWithExpectation(sideMenuItemsUpdated, expectedItemsCount: 2)
        
        wait(for: [sideMenuItemsUpdated], timeout:  2)
        // THEN the sections shown on the left side are 2 (All and Search)
        XCTAssertEqual(sut.sideMenuItems.count, 2)
        XCTAssertEqual(sut.sideMenuItems, [.all, .search])
    }
    
    func test_selectedSectionWhenAllFavoritesDeleted() {
        let sideMenuItemsUpdated = expectation(description: "Side menu items updated")
        // GIVEN that an item is added to favorites
        fixture.favoritesUseCaseMock.favorites = ["server-id-one"]
        instantiateSut()
        // AND GIVEN that the selected section is 'Favorites'
        sut.selectedSection = .favorites
        subscribeToSideMenuUpdatesWithExpectation(sideMenuItemsUpdated, expectedItemsCount: 3)
        
        wait(for: [sideMenuItemsUpdated], timeout:  3)
        // THEN the sections shown on the left side are 3 (Favorites, All and Search)
        XCTAssertEqual(sut.sideMenuItems.count, 3)
        XCTAssertEqual(sut.sideMenuItems, [.favorites, .all, .search])
        
        // WHEN the item is removed from favorites and the favorites list becomes empty
        fixture.favoritesUseCaseMock.favorites = []
        
        let sideMenuItemsUpdatedAgain = expectation(description: "Side menu items are updated again")
        subscribeToSideMenuUpdatesWithExpectation(sideMenuItemsUpdatedAgain, expectedItemsCount: 2)
        wait(for: [sideMenuItemsUpdatedAgain], timeout: 3)
        
        // THEN the side menu items become 2 (All and Search)
        XCTAssertEqual(sut.sideMenuItems.count, 2)
        XCTAssertEqual(sut.sideMenuItems, [.all, .search])
        // AND the selected section becomes 'All'
        XCTAssertEqual(sut.selectedSection, .all)
        
    }
    
    
}
