//
//  RegionSelectionTests.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 8/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Nimble
import XCTest

class LocationSelectionTests:BaseTest {
    override class func spec() {
        super.spec()
        
        describe("location selection tests") {
            context("when the user goes to 'All' tab") {
                it("then the user sees all available locations") {
                    app.navigateToLocationSelection()
                    app.navigateToAllLocations()
                    
                    expect(app.allLocationsTitle.exists).to(beTrue())
                    expect(app.optimalLocationsTitle.exists).to(beTrue())
                }
            }
            
            context("when the user goes to 'Search' tab") {
                it("should display recommended locations and search location button") {
                    app.navigateToLocationSelection()
                    app.navigateToSearchLocation()
                    expect(app.recommendedLocationsTitle.exists && app.searchForALocationButton.exists).to(beTrue())
                }
                
                it("should return related results when the user searches a keyword") {
                    app.navigateToLocationSelection()
                    app.navigateToSearchLocation()
                    app.searchLocation(keyword: "Chi")
                    print (app.getSearchResultButtonLabels())
                    expect(app.getSearchResultButtonLabels().allSatisfy{$0.contains("Chi")}).to(beTrue())
                }
            }
        }
    }
}
