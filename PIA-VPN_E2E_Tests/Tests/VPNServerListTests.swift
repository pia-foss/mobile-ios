//
//  VPNServerListTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

class VPNServerListTests: BaseTest {
    private let regionKeyword = "belgium"
    private let characterKey = "au"
    private let favouriteRegionKeyword = "Singapore"

    // MARK: - Region selection screen

    func testShowsSearchField() {
        app.navigateToRegionSelection()
        app.revealRegionSearchField()

        XCTAssertTrue(app.searchRegionField.isHittable)
    }

    // MARK: - Search

    func testSearchReturnsResultsForRegionKeyword() {
        app.navigateToRegionSelection()
        let cellsQuery = app.searchRegion(regionName: regionKeyword)

        XCTAssertTrue(cellsQuery.firstMatch.waitForExistence(timeout: app.defaultTimeout), "No search results")
        for cell in cellsQuery.allElementsBoundByIndex {
            XCTAssertTrue(cell.label.lowercased().contains(regionKeyword))
        }
    }

    func testSearchReturnsResultsForCharacters() {
        app.navigateToRegionSelection()
        let cellsQuery = app.searchRegion(regionName: characterKey)

        XCTAssertTrue(cellsQuery.firstMatch.waitForExistence(timeout: app.defaultTimeout), "No search results")
        for cell in cellsQuery.allElementsBoundByIndex {
            XCTAssertTrue(cell.label.lowercased().contains(characterKey))
        }
    }

    // MARK: - Favourites

    func testShowsRegionMarkedAsFavourite() {
        app.navigateToRegionSelection()
        _ = app.searchRegion(regionName: favouriteRegionKeyword)
        app.setRegionFavourite(favouriteRegionKeyword, isFavourite: false)
        XCTAssertFalse(app.isRegionFavourite(regionName: favouriteRegionKeyword))

        app.setRegionFavourite(favouriteRegionKeyword, isFavourite: true)
        XCTAssertTrue(app.isRegionFavourite(regionName: favouriteRegionKeyword))
    }

    // MARK: - Sorting

    func testSortsRegionsByName() {
        app.navigateToRegionSelection()
        app.sortRegionsBy(.name)
        let regionList = visibleRegionLabels()
        XCTAssertEqual(regionList, app.sortedByRegionName(regionList))
    }

    func testSortsRegionsByLatency() {
        app.navigateToRegionSelection()
        app.sortRegionsBy(.latency)
        let regionList = visibleRegionLabels()
        let sortedByLatency = regionList.sorted {
            let latency01 = Int($0.components(separatedBy: ", ").last?.dropLast(2) ?? "") ?? 0
            let latency02 = Int($1.components(separatedBy: ", ").last?.dropLast(2) ?? "") ?? 0
            return latency01 < latency02
        }
        XCTAssertEqual(regionList, sortedByLatency)
    }

    func testSortsRegionsByFavourites() {
        app.navigateToRegionSelection()
        _ = app.searchRegion(regionName: favouriteRegionKeyword)
        app.setRegionFavourite(favouriteRegionKeyword, isFavourite: true)
        app.cancelSearch()
        app.sortRegionsBy(.favorites)
        let firstRegion = app.getRegionList().allElementsBoundByIndex.prefix(2).filter({ $0.label != app.automaticString }).first
        XCTAssertTrue(firstRegion?.label.contains(favouriteRegionKeyword) ?? false)
    }

    // MARK: - Geolocation setting

    func testShowsGeoLocatedRegionsWhenEnabled() {
        app.navigateToGeneralSettings()
        app.enableGeoLocatedRegionSwitch()
        app.navigateToHomeFromSettings()
        app.navigateToRegionSelection()
        XCTAssertTrue(app.scrollToElement(app.geoLocatedRegions.firstMatch), "No geo-located region in the list")
    }

    func testHidesGeoLocatedRegionsWhenDisabled() {
        app.navigateToGeneralSettings()
        app.disableGeoLocatedRegionSwitch()
        app.navigateToHomeFromSettings()
        app.navigateToRegionSelection()
        XCTAssertTrue(app.getRegionList().firstMatch.waitForExistence(timeout: app.defaultTimeout))
        for _ in 0..<5 {
            XCTAssertFalse(app.geoLocatedRegions.firstMatch.exists, "A geo-located region is listed")
            app.swipeUp()
        }
    }

    // MARK: - Helpers

    private func visibleRegionLabels() -> [String] {
        app.getRegionList().allElementsBoundByIndex.prefix(21).map(\.label).filter { $0 != app.automaticString }
    }
}
