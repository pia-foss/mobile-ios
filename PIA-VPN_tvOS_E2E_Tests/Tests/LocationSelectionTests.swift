//
//  RegionSelectionTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/3/24.
//  Copyright © 2024 Private Internet Ac`cess Inc. All rights reserved.
//

import Nimble
import XCTest

class LocationSelectionTests:BaseTest {
    override class func spec() {
        super.spec()
        
        describe("location selection tests") {
            context("when the user goes to 'All' tab") {
                it("then the user sees all available locations") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToAllLocationsScreen()
                    
                    expect(app.allLocationsTitle.exists).to(beTrue())
                    expect(app.optimalLocationsTitle.exists).to(beTrue())
                }
            }
            
            context("when the user goes to 'Search' tab") {
                it("should display recommended locations and search location button") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    expect(app.searchForALocationButton.exists).to(beTrue())
                    expect(app.recommendedLocationsTitle.exists || app.lastSearchedLocationsTitle.exists).to(beTrue())
                }
                
                it("should return related results when the user searches a keyword") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.searchLocation(keyword: "Chi")
                    expect(app.getSearchResultButtonLabels().allSatisfy{$0.contains("Chi")}).to(beTrue())
                }
            }
            
            context("display of the favourites tab") {
                it("should display the favourites tab when a region is added to favourites") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToAllLocationsScreen()
                    app.navigateToSearchLocationScreen()
                    app.addToFavorites(region: "India")
                    expect(app.favouritesTabButton.exists).to(beTrue())
                    app.navigateToFavouriteLocationScreen()
                    expect(app.getSearchResultButtonLabels().contains{$0.contains("India")}).to(beTrue())
                }
                
                it("should hide the favourites tab when all regions are removed from favourites") {
                    app.navigateToLocationSelectionScreen()
                    app.navigateToSearchLocationScreen()
                    app.addToFavorites(region: "Peru")
                    app.addToFavorites(region: "Chile")
                    app.navigateToFavouriteLocationScreen()
                    app.removeAllRegionsFromFavorites()
                    expect(!app.favouritesTabButton.exists).to(beTrue())
                }
            }
        }
    }
}
