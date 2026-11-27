//
//  RegionSelectionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIAAccessibility
import XCTest

extension XCUIApplication {
    var automaticString: String { getString(key: "global.automatic", comment: "Automatic") }
    var regionSelectionTitleString: String { getString(key: "menu.item.region", comment: "Region selection") }
    var regionSelectionHeader: XCUIElement { staticText(with: regionSelectionTitleString) }
    var searchRegionFieldString: String { getString(key: "region.search.placeholder", comment: "Search for a region") }
    var searchRegionField: XCUIElement { searchField(with: searchRegionFieldString) }
    var searchRegionButton: XCUIElement { toolbars.buttons["Search"].firstMatch }
    var cancelSearchButton: XCUIElement { buttons["close"].firstMatch }
    var filterButtonString: String { getString(key: "region.accessibility.filter", comment: "Filter") }
    var sortButton: XCUIElement { button(with: filterButtonString) }
    var emptyListScreen: XCUIElement { image(with: AccessibilityID.RegionList.emptyBackground) }
    var dedicatedIPRegion: XCUIElement {
        getRegionList().containing(NSPredicate(format: "label == %@", dedicatedIPTitleString)).firstMatch
    }
    var geoLocatedRegions: XCUIElementQuery {
        getRegionList().containing(.image, identifier: AccessibilityID.RegionList.geoIcon)
    }

    func navigateToRegionSelection() {
        XCTAssertTrue(regionTileCollectionViewCell.waitForElementToAppear(), "Region tile collection view cell not found")
        regionTileCollectionViewCell.tap()
        XCTAssertTrue(regionSelectionHeader.waitForElementToAppear())
    }

    func revealRegionSearchField() {
        XCTAssertTrue(searchRegionButton.waitForElementToAppear(), "Region search button not found")
        searchRegionButton.tap()
        XCTAssertTrue(searchRegionField.waitForElementToAppear())
    }

    func searchRegion(regionName: String) -> XCUIElementQuery {
        revealRegionSearchField()
        searchRegionField.tap()
        searchRegionField.typeText(regionName)

        return getRegionList()
    }

    func cancelSearch() {
        cancelSearchButton.tap()
        XCTAssertTrue(sortButton.waitForElementToAppear())
    }

    func getRegionList() -> XCUIElementQuery {
        // The SwiftUI region list exposes each row as a Button.
        buttons.matching(identifier: AccessibilityID.RegionList.region)
    }

    var addFavoriteString: String { getString(key: "region.accessibility.favorite", comment: "Add a favorite region") }
    var removeFavoriteString: String { getString(key: "region.accessibility.unfavorite", comment: "Remove a favorite region") }

    /// The listed row for `regionName`, whose label is the region name followed by its latency.
    func regionRow(named regionName: String) -> XCUIElement {
        getRegionList().matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", regionName, "\(regionName),")).firstMatch
    }

    /// Whether the listed `regionName` is a favorite: its button then offers to remove it.
    func isRegionFavourite(regionName: String) -> Bool {
        let region = regionRow(named: regionName)
        XCTAssertTrue(region.waitForElementToAppear(), "\(regionName) isn't listed")
        return region.buttons[removeFavoriteString].exists
    }

    /// Marks the listed `regionName` as a favorite or not, unless it already is in that state.
    func setRegionFavourite(_ regionName: String, isFavourite: Bool) {
        let region = regionRow(named: regionName)
        XCTAssertTrue(region.waitForElementToAppear(), "\(regionName) isn't listed")
        let addButton = region.buttons[addFavoriteString]
        let removeButton = region.buttons[removeFavoriteString]
        XCTAssertTrue(addButton.waitForElementToAppear() || removeButton.exists, "No favorite button on \(regionName)")
        guard (isFavourite ? addButton : removeButton).exists else { return }

        (isFavourite ? addButton : removeButton).tap()
        XCTAssertTrue(
            (isFavourite ? removeButton : addButton).waitForElementToAppear(),
            "\(regionName) didn't change its favorite state"
        )
    }

    /// `labels` sorted by region name, the part before the first comma, as the Name sort orders them.
    func sortedByRegionName(_ labels: [String]) -> [String] {
        labels.sorted { $0.components(separatedBy: ",")[0] < $1.components(separatedBy: ",")[0] }
    }

    func sortRegionsBy(_ sort: RegionSort) {
        XCTAssertTrue(sortButton.waitForElementToAppear(), "Sort button not found")
        sortButton.tap()
        let option = button(with: getString(key: sort.rawValue, comment: ""))
        XCTAssertTrue(option.waitForElementToAppear())
        option.tap()
        XCTAssertTrue(option.waitForElementToBeHidden())
    }
}

/// The region list's sort options, keyed by their localized menu titles.
enum RegionSort: String {
    case name = "region.filter.name"
    case latency = "region.filter.latency"
    case favorites = "region.filter.favorites"
}
