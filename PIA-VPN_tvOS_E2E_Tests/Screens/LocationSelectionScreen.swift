//
//  LocationSelectionScreen.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 11/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    var locationButtonString: String {getString(key: "settings.dedicatedip.stats.location", comment: "Location")}
    var locationButton: XCUIElement {button(with: locationButtonString)}
    var locationSelectionTitleString: String {getString(key: "top_navigation_bar.location_selection_screen.title", comment: "Location Selection")}
    var locationSelectionTitle: XCUIElement {staticText(with: locationSelectionTitleString)}
    var allTitleString: String {getString(key: "regions.filter.all.title", comment: "All")}
    var allTabButton: XCUIElement {button(with: allTitleString)}
    var allLocationsString: String {getString(key: "regions.list.all_locations.title", comment: "All Locations")}
    var allLocationsTitle: XCUIElement {staticText(with: allLocationsString)}
    var optimalWithDIPLocationsString: String {getString(key: "regions.list.optimal_location_with_dip_location.title", comment: "Optimal Location/Dedicated IP")}
    var optimalLocationsTitle: XCUIElement {staticText(with: optimalWithDIPLocationsString)}
    var searchTitleString: String {getString(key: "regions.filter.search.title", comment: "Search")}
    var searchTabButton: XCUIElement {button(with: searchTitleString)}
    var searchButtonString: String {getString(key: "regions.search.button.title", comment: "Search for a Location")}
    var searchForALocationButton: XCUIElement {button(with: searchButtonString)}
    var recommendedLocationsTitleString: String {getString(key: "regions.search.recommended_locations.title", comment: "Recommended Locations")}
    var recommendedLocationsTitle: XCUIElement {staticText(with: recommendedLocationsTitleString)}
    var lastSearchedLocationsTitleString: String {getString(key: "regions.search.previous_results.title", comment: "Last Searched Locations")}
    var lastSearchedLocationsTitle: XCUIElement {staticText(with: lastSearchedLocationsTitleString)}
    var numbersButton: XCUIElement {button(with: "Numbers")}
    var punctuationButton: XCUIElement {button(with: "Punctuation")}
    var smallLettersButton: XCUIElement {button(with: "Small-Letters")}
    var searchResultsTitleString: String {getString(key: "regions.search.results.title", comment: "Search Results")}
    var searchResultsTitle: XCUIElement {staticText(with: searchResultsTitleString)}
    var addToFavoritesButtonString: String {getString(key: "regions.context_menu.favorites.add.text", comment: "Add to Favorites")}
    var addToFavoritesButton: XCUIElement{button(with: addToFavoritesButtonString)}
    var removeFromFavoritesButtonString: String {getString(key: "regions.context_menu.favorites.remove.text", comment: "Remove from Favorites")}
    var removeFromFavoritesButton: XCUIElement {button(with: removeFromFavoritesButtonString)}
    var favouritesTitleString: String {getString(key: "regions.filter.favorites.title", comment: "Favourite(s)")}
    var favouritesTabButton: XCUIElement {button(with: favouritesTitleString)}
    
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
        XCTAssert(findElementWithPartialText(partialText: region, elementType: .button)!.waitForElementToAppear())
        
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
        XCTAssert(findElementWithPartialText(partialText: region, elementType: .button)!.waitForElementToAppear())
        
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
    
    func connectTo(region: String) {
        searchLocation(keyword: region)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        XCTAssert(connectButton.waitForElementToAppear())
    }
}
