//
//  RegionSelectionScreen.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
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
        let query = cells.matching(NSPredicate(format: "identifier == %@", "uitests.regions.region_name"))
        return query
    }
    
    func addRegionAsFavourite(regionName: String) {
        let region = searchRegion(regionName: regionName).firstMatch
        
        let regionAddAsAFavouriteButton = region.buttons["Add a favorite region"]
        let regionRemoveAsAFavouriteButton = region.buttons["Remove a favorite region"]
        
        if(regionRemoveAsAFavouriteButton.exists) {
            regionRemoveAsAFavouriteButton.tap()
        }
        WaitHelper.waitForElementToBeVisible(regionAddAsAFavouriteButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("regionRemoveAsAFavouriteButton is not visible")})
        WaitHelper.waitForElementToNotBeVisible(regionRemoveAsAFavouriteButton, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("regionAddAsAFavouriteButton is not visible")})

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
        guard sortButton.exists else {return}
        sortButton.tap()
        WaitHelper.waitForElementToBeVisible(sortPopUpHeader, timeout: defaultTimeout, onSuccess: {}, onFailure: {error in print("sortPopUpHeader is not visible")})
        button(with: sortType).tap()
    }
}
