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
    var locationTitle:XCUIElement {staticText(with: "Location Selection")}
    var allTabButton:XCUIElement {button(with: "All")}
    var allLocationsTitle:XCUIElement {staticText(with: "All Locations")}
    var optimalLocationsTitle: XCUIElement {staticText(with: "Optimal Location/Dedicated IP")}
    var searchTabButton:XCUIElement {button(with: "Search")}
    var searchForALocationButton:XCUIElement {button(with: "Search for a Location")}
    var recommendedLocationsTitle:XCUIElement {staticText(with: "Recommended Locations")}
    var numbersButton:XCUIElement {button(with: "Numbers")}
    var punctuationButton:XCUIElement {button(with: "Punctuation")}
    var smallLettersButton:XCUIElement {button(with: "Small-Letters")}
    var searchResultsTitle: XCUIElement {staticText(with: "Search Results")}
    
    func navigateToLocationSelection() {
        locationButton.waitForElementToAppear()
        moveFocus(to: locationButton, startingDirection: .up)
        XCUIRemote.shared.press(.select)
        locationTitle.waitForElementToAppear()
    }
    
    func navigateToAllLocations() {
        allTabButton.waitForElementToAppear()
        moveFocus(to: allTabButton, startingDirection: .down)
        allLocationsTitle.waitForElementToAppear()
    }
    
    func navigateToSearchLocation() {
        searchTabButton.waitForElementToAppear()
        moveFocus(to: searchTabButton, startingDirection: .down)
        searchForALocationButton.waitForElementToAppear()
    }
    
    func searchLocation(keyword: String) {
        searchForALocationButton.waitForElementToAppear()
        moveFocus(to: searchForALocationButton)
        XCUIRemote.shared.press(.select)
        let navigator = KeyboardNavigator()
        navigator.resetKeyboardPosition()
        navigator.typeText(keyword, keyboardType: .singleRow)
        searchResultsTitle.waitForElementToAppear()
    }
    
    func getSearchResultButtonLabels() -> [String] {
        let searchedLocations = buttons.allElementsBoundByIndex
        let labels = searchedLocations.map { $0.label }
        
        return labels
    }
}
