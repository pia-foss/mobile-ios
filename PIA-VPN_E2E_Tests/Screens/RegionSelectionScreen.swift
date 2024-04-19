//
//  RegionSelectionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var regionSelectionTitleString: String {getString(key: "menu.item.region", comment: "Region selection")}
    var regionSelectionHeader: XCUIElement {staticText(with: regionSelectionTitleString)}
    var searchRegionFieldString: String {getString(key: "region.search.placeholder", comment: "Search for a region")}
    var searchRegionField: XCUIElement {searchField(with: searchRegionFieldString)}
    var cancelSearchButton: XCUIElement {button(with: "Cancel")}
    var filterButtonString: String {getString(key: "region.accessibility.filter", comment: "Filter")}
    var sortButton: XCUIElement {button(with: filterButtonString)}
    var sortByString: String {getString(key: "region.filter.sortby", comment: "Sort regions by")}
    var sortPopUpHeader: XCUIElement {staticText(with: sortByString)}
    var emptyListScreen: XCUIElement {image(with: "empty set background image")}
    
    func navigateToRegionSelection(){
        regionTileCollectionViewCell.waitForElementToAppear()
        regionTileCollectionViewCell.tap()
        XCTAssert(regionSelectionHeader.waitForElementToAppear())
    }
    
    func searchRegion(regionName: String) -> XCUIElementQuery {
        while(!searchRegionField.isHittable) {
            swipeDown()
        }
        searchRegionField.tap()
        searchRegionField.typeText(regionName)
        
        return getRegionList()
    }
    
    func cancelSearch() {
        cancelSearchButton.tap()
        XCTAssert(sortButton.waitForElementToAppear())
    }
    
    func getRegionList() -> XCUIElementQuery {
        while(!searchRegionField.isHittable) {
            swipeDown()
        }
        let query = cells.matching(NSPredicate(format: "identifier == %@", "uitests.regions.region_name"))
        return query
    }
    
    func addRegionAsFavourite(regionName: String) {
        let region = searchRegion(regionName: regionName).firstMatch
        
        let regionAddAsAFavouriteButton = region.buttons["Add a favorite region"]
        let regionRemoveAsAFavouriteButton = region.buttons["Remove a favorite region"]
        
        if(regionAddAsAFavouriteButton.waitForElementToAppear()){
            return
        }
        
        regionRemoveAsAFavouriteButton.waitForElementToAppear()
        regionRemoveAsAFavouriteButton.tap()

        XCTAssert(regionAddAsAFavouriteButton.waitForElementToAppear())
        XCTAssert(regionRemoveAsAFavouriteButton.waitForElementToBeHidden())
    }
    
    func isRegionFavourite(regionName: String) -> Bool {
        var isFavourite: Bool = false
        
        let region = getRegionList().firstMatch
        
        let regionAddAsAFavouriteButton = region.buttons["Add a favorite region"]
        let regionRemoveAsAFavouriteButton = region.buttons["Remove a favorite region"]
        
        if(regionAddAsAFavouriteButton.exists && !regionRemoveAsAFavouriteButton.exists) {
            isFavourite = true
        }
        
        return isFavourite
    }
    
    func sortRegionsBy(sortType: String) {
        sortButton.waitForElementToAppear()
        sortButton.tap()
        sortPopUpHeader.waitForElementToAppear()
        button(with: sortType).tap()
        sortPopUpHeader.waitForElementToBeHidden()
    }
}
