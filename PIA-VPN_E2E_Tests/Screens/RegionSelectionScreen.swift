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
        guard regionTileCollectionViewCell.waitForExistence(timeout: defaultTimeout) else { return }
        regionTileCollectionViewCell.tap()
        WaitHelper.waitForElementToBeVisible(regionSelectionHeader, timeout: defaultTimeout,
                                             onSuccess:{print("successful navigation to region selection screen")}, onFailure:{error in print("regionSelectionHeader is not visible")})
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
        WaitHelper.waitForElementToBeVisible(sortButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("sortButton is not displayed")})
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
        
        guard (regionRemoveAsAFavouriteButton.waitForExistence(timeout: defaultTimeout)) else {return}
        regionRemoveAsAFavouriteButton.tap()

        WaitHelper.waitForElementToBeVisible(regionAddAsAFavouriteButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("regionAddAsAFavouriteButton is not visible")})
        WaitHelper.waitForElementToNotBeVisible(regionRemoveAsAFavouriteButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("regionRemoveAsAFavouriteButton is visible")})

    }
    
    func removeRegionAsFavourite(regionName: String) {
        
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
        guard sortButton.waitForExistence(timeout: defaultTimeout) else {return}
        sortButton.tap()
        WaitHelper.waitForElementToBeVisible(sortPopUpHeader, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("sortPopUpHeader is not visible")})
        button(with: sortType).tap()
    }
}
