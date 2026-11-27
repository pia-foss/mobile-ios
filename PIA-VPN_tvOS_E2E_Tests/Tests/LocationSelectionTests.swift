//
//  LocationSelectionTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

class LocationSelectionTests: BaseTest {
    // MARK: - "All" tab

    func testAllTabShowsAllAvailableLocations() {
        app.navigateToLocationSelectionScreen()
        app.navigateToAllLocationsScreen()

        XCTAssertTrue(app.allLocationsTitle.exists)
        XCTAssertTrue(app.optimalLocationsTitle.exists)
    }

    // MARK: - "Search" tab

    func testSearchTabShowsRecommendedLocationsAndSearchButton() {
        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        XCTAssertTrue(app.searchForALocationButton.exists)
        XCTAssertTrue(app.recommendedLocationsTitle.exists || app.lastSearchedLocationsTitle.exists)
    }

    func testSearchReturnsRelatedResults() {
        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.searchLocation(keyword: "Chi")
        XCTAssertTrue(app.getSearchResultButtonLabels().allSatisfy { $0.contains("Chi") })
    }

    // MARK: - Favourites tab

    func testShowsFavouritesTabWhenRegionIsFavourited() {
        app.navigateToLocationSelectionScreen()
        app.navigateToAllLocationsScreen()
        app.navigateToSearchLocationScreen()
        app.addToFavorites(region: "India")
        XCTAssertTrue(app.favouritesTabButton.exists)
        app.navigateToFavouriteLocationScreen()
        XCTAssertTrue(app.getSearchResultButtonLabels().contains { $0.contains("India") })
    }

    func testHidesFavouritesTabWhenAllFavouritesAreRemoved() {
        app.navigateToLocationSelectionScreen()
        app.navigateToSearchLocationScreen()
        app.addToFavorites(region: "Peru")
        app.addToFavorites(region: "Chile")
        app.navigateToFavouriteLocationScreen()
        app.removeAllRegionsFromFavorites()
        XCTAssertFalse(app.favouritesTabButton.exists)
    }
}
