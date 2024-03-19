//
//  RegionSelectionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var regionSelectionHeader: XCUIElement {
        staticText(with: "Region selection")
    }
    
    var searchRegionField: XCUIElement {
        searchField(with: "Search for a region")
    }
    
    var cancelSearchButton: XCUIElement {
        button(with: "Cancel")
    }
    
    var sortButton: XCUIElement {
        button(with: "Filter")
    }
    
    var sortPopUpHeader: XCUIElement {
        staticText(with: "SORT REGIONS BY")
    }
    
    var emptyListScreen: XCUIElement {
        image(with: "empty set background image")
    }
    
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
