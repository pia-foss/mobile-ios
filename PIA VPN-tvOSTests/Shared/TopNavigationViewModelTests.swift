//
//  TopNavigationViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/7/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS

class TopNavigationViewModelTests: XCTestCase {
    class Fixture {
        var appRouter: AppRouter = AppRouter()
        
        func stubPathDestinations(_ destinations: [any Destinations]) {
            self.appRouter = AppRouter(with: destinations)
        }
    }
    
    var fixture: Fixture!
    var sut: TopNavigationViewModel!
    
    func instantiateSut() {
        sut = TopNavigationViewModel(appRouter: fixture.appRouter)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    func test_selectedSectionForEmptyDestinationPath() {
        // GIVEN that the app router path is empty
        instantiateSut()
        XCTAssertTrue(fixture.appRouter.path.isEmpty)
        XCTAssertTrue(fixture.appRouter.pathDestinations.isEmpty)
        
        // THEN the selected section is vpn
        XCTAssertEqual(sut.selectedSection, .vpn)
    }
    
    func test_selectedSectionForRegionsListDestination() {
        // GIVEN that the app path destination is Regions
        fixture.stubPathDestinations([RegionsDestinations.serversList])
        instantiateSut()
        
        // THEN the selected section is locations
        XCTAssertEqual(sut.selectedSection, .locations)
    }
    
    func test_selectedSectionForRegionsSearchDestination() {
        // GIVEN that the app path destination is Regions
        fixture.stubPathDestinations([RegionsDestinations.search])
        instantiateSut()
        
        // THEN the selected section is locations
        XCTAssertEqual(sut.selectedSection, .locations)
    }
    
    func test_updateSelectedSection() {
        // GIVEN that the selected section is vpn
        instantiateSut()
        XCTAssertEqual(sut.selectedSection, .vpn)
        XCTAssertTrue(fixture.appRouter.pathDestinations.isEmpty)
        
        // WHEN updating the selected section to Locations
        sut.sectionDidUpdateSelection(to: .locations)
        
        // THEN the selected section becomes locations
        XCTAssertEqual(sut.selectedSection, .locations)
        // AND the router path destination is updated to Regions servers list
        XCTAssertEqual(fixture.appRouter.pathDestinations.last! as! RegionsDestinations, .serversList)
        
    }
    
    func test_updateHighlightedSection() {
        instantiateSut()
        XCTAssertNil(sut.highlightedSection)
        
        // WHEN the focus becomes the Locations buttons
        sut.sectionDidUpdateFocus(to: .locations)
        
        // THEN the highlighted section becomes the locations section
        XCTAssertEqual(sut.highlightedSection, .locations)
    }
    
}
