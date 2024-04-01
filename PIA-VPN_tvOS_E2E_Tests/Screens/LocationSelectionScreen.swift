//
//  LocationSelectionScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 11/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var locationButton:XCUIElement {button(with: "Location")}
    var locationSelectionTitle:XCUIElement {staticText(with: "Location Selection")}
    var allTabButton:XCUIElement {button(with: "All")}
    var allLocationsTitle:XCUIElement {staticText(with: "All Locations")}
    var optimalLocationsTitle: XCUIElement {staticText(with: "Optimal Location/Dedicated IP")}
    var searchTabButton:XCUIElement {button(with: "Search")}
    var searchForALocationButton:XCUIElement {button(with: "Search for a Location")}
    var recommendedLocationsTitle:XCUIElement {staticText(with: "Recommended Locations")}
    var lastSearchedLocationsTitle:XCUIElement {staticText(with: "Last Searched Locations")}
    var numbersButton:XCUIElement {button(with: "Numbers")}
    var punctuationButton:XCUIElement {button(with: "Punctuation")}
    var smallLettersButton:XCUIElement {button(with: "Small-Letters")}
    var searchResultsTitle: XCUIElement {staticText(with: "Search Results")}
    var addToFavoritesButton: XCUIElement {button(with: "Add to Favorites")}
    var removeFromFavoritesButton: XCUIElement {button(with: "Remove from Favorites")}
    var favouritesTabButton:XCUIElement {button(with: "Favourite(s)")}
    
    func navigateToLocationSelectionScreen() {
        locationButton.waitForElementToAppear()
        moveFocus(to: locationButton, startingDirection: .right)
        XCUIRemote.shared.press(.select)
        XCTAssert(locationSelectionTitle.waitForElementToAppear())
    }
    
    func navigateToAllLocationsScreen() {
        allTabButton.waitForElementToAppear()
        moveFocus(to: allTabButton, startingDirection: .down)
        XCTAssert(allLocationsTitle.waitForElementToAppear())
    }
    
    func navigateToSearchLocationScreen() {
        searchTabButton.waitForElementToAppear()
        moveFocus(to: searchTabButton, startingDirection: .down)
        XCTAssert(searchForALocationButton.waitForElementToAppear())
    }
    
    func navigateToFavouriteLocationScreen() {
        favouritesTabButton.waitForElementToAppear()
        moveFocus(to: favouritesTabButton, startingDirection: .up)
    }
    
    func searchLocation(keyword: String) {
        searchForALocationButton.waitForElementToAppear()
        moveFocus(to: searchForALocationButton)
        XCUIRemote.shared.press(.select)
        let navigator = KeyboardNavigator()
        navigator.resetKeyboardPosition()
        navigator.typeText(keyword, keyboardType: .singleRow)
        XCTAssert(searchResultsTitle.waitForElementToAppear())
    }
    
    func getSearchResultButtonLabels() -> [String] {
        let searchedLocations = scrollViews.allElementsBoundByIndex.first!.buttons.allElementsBoundByIndex
        let labels = searchedLocations.map { $0.label }
        return labels
    }
    
    func getSearchResults() -> [XCUIElement] {
        let searchedLocations = scrollViews.allElementsBoundByIndex.first!.buttons.allElementsBoundByIndex
        return searchedLocations
    }
    
    func addToFavorites(region: String) {
        searchLocation(keyword: region)
        XCTAssert(findElementWithPartialText(region, elementType: buttons)!.waitForElementToAppear())
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select,forDuration: 3)
        
        if(removeFromFavoritesButton.exists){
            XCUIRemote.shared.press(.menu)
            XCUIRemote.shared.press(.menu)
        }
        
        else if(addToFavoritesButton.exists) {
            XCUIRemote.shared.press(.select)
            XCUIRemote.shared.press(.menu)
        }
        
        XCTAssert(locationSelectionTitle.waitForElementToAppear())
    }
    
    func removeToFavorites(region: String) {
        searchLocation(keyword: region)
        XCTAssert(findElementWithPartialText(region, elementType: buttons)!.waitForElementToAppear())
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select,forDuration: 3)
        
        if(addToFavoritesButton.exists){
            XCUIRemote.shared.press(.menu)
        }
        
        else if(removeFromFavoritesButton.exists) {
            XCUIRemote.shared.press(.select)
            XCUIRemote.shared.press(.menu)
        }
        
        XCTAssert(locationSelectionTitle.waitForElementToAppear())
    }
    
    func removeAllRegionsFromFavorites() {
        if(!favouritesTabButton.exists){
            return
        }
        
        navigateToFavouriteLocationScreen()
        XCUIRemote.shared.press(.right)
        
        while(favouritesTabButton.exists){
            let searchResults = getSearchResults()
            for index in 0..<searchResults.count {
                searchResults[index].waitForElementToAppear()
                XCUIRemote.shared.press(.select,forDuration: 3)
                XCTAssert(removeFromFavoritesButton.waitForElementToAppear())
                XCUIRemote.shared.press(.select)
            }
        }
    }
}
