//
//  VPNServerListTests.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 20/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Nimble

class VPNServerListTests : BaseTest {
    override class func spec() {
        let regionKeyword = "australia"
        let characterKey = "au"
        let favouriteRegionKeyword = "Singapore"
        let geoLocatedRegionKeyword = "South Korea"
        
        super.spec()
        
        describe("vpn server list tests") {
            context("when the user navigates to region selection screen") {
                it("should show the search region field when the user scrolls down") {
                    app.navigateToRegionSelection()
                    while(!app.searchRegionField.isHittable) {
                        app.swipeDown()
                    }
                    
                    expect(app.searchRegionField.isHittable).to(beTrue())
                }
            }
             
            context("when the user performs search") {
                it("should return results based on searched keyword \(regionKeyword)") {
                    app.navigateToRegionSelection()
                    let cellsQuery = app.searchRegion(regionName: regionKeyword)
                    
                    for cell in cellsQuery.allElementsBoundByIndex {
                        expect(cell.label.lowercased().contains(regionKeyword)).to(beTrue())
                    }
                }
                it("should return results based on searched \(characterKey)") {
                    app.navigateToRegionSelection()
                    let cellsQuery = app.searchRegion(regionName: characterKey)
                    
                    for cell in cellsQuery.allElementsBoundByIndex {
                        expect(cell.label.lowercased().contains(characterKey)).to(beTrue())
                    }
                }
            }
            
            context("when the user selects a region as a favorite") {
                it("should be displayed as a favourite region") {
                    app.navigateToRegionSelection()
                    app.addRegionAsFavourite(regionName: favouriteRegionKeyword)
                    expect(app.isRegionFavourite(regionName: favouriteRegionKeyword)).to(beTrue())
                }
            }
            
            context("when the user sorts the region selection") {
                it("should sort the regions by name, when 'name' is selected") {
                    app.navigateToRegionSelection()
                    app.sortRegionsBy(sortType: "NAME")
                    let regionList = app.getRegionList().allElementsBoundByIndex.prefix(21).map{$0.label}.filter{$0 != "Automatic"}
                    expect(regionList).to(equal(regionList.sorted(by: <)))
                }
                
                it("should sort the regions by latency, when 'latency' is selected") {
                    app.navigateToRegionSelection()
                    app.sortRegionsBy(sortType: "LATENCY")
                    let regionList = app.getRegionList().allElementsBoundByIndex.prefix(21).map{$0.label}.filter{$0 != "Automatic"}
                    expect(regionList) == regionList.sorted {
                        let latency01 = Int($0.components(separatedBy: ", ").last?.dropLast(2) ?? "") ?? 0
                        let latency02 = Int($1.components(separatedBy: ", ").last?.dropLast(2) ?? "") ?? 0
                        return latency01<latency02
                    }
                }
                
                it("should sort the regions by favourites, when 'favourites' is selected") {
                    app.navigateToRegionSelection()
                    app.addRegionAsFavourite(regionName: favouriteRegionKeyword)
                    app.cancelSearch()
                    app.sortRegionsBy(sortType: "FAVORITES")
                    let firstRegion = app.getRegionList().allElementsBoundByIndex.prefix(2).filter({$0.label != "Automatic"}).first
                    expect(firstRegion?.label).to(contain(favouriteRegionKeyword))
                }
            }
            
            context("when the user updates the geolocation setting") {
                it("should show geo-located regions when the setting is enabled") {
                    app.navigateToGeneralSettings()
                    app.enableGeoLocatedRegionSwitch()
                    app.navigateToHomeFromSettings()
                    app.navigateToRegionSelection()
                    app.searchRegion(regionName: geoLocatedRegionKeyword)
                    expect(app.emptyListScreen.exists).to(beFalse())
                }
                
                it("should hide geo-located regions when the setting is disabled") {
                    app.navigateToGeneralSettings()
                    app.disableGeoLocatedRegionSwitch()
                    app.navigateToHomeFromSettings()
                    app.navigateToRegionSelection()
                    app.searchRegion(regionName: geoLocatedRegionKeyword)
                    expect(app.emptyListScreen.exists).to(beTrue())
                }
            }
        }
    }
}
