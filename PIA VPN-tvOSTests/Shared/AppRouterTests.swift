//
//  AppRouterTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/7/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

import XCTest
@testable import PIA_VPN_tvOS

class AppRouterTests: XCTestCase {
    class Fixture {
        var initialDestinations: [any Destinations] = []
    }
    
    var fixture: Fixture!
    var sut: AppRouter!
    
    func instantiateSubject() {
        sut = AppRouter(with: fixture.initialDestinations)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    func test_startAppRouter_WithoutAnyDestination() {
        // GIVEN that the initial destinations of the AppRouter is empty
        fixture.initialDestinations = []
        instantiateSubject()
        
        // THEN the path and the path destinations are empty
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertTrue(sut.pathDestinations.isEmpty)
        
    }
    
    func test_startAppRouter_withAGivenDestination() {
        // GIVEN that the initial destinations of the AppRouter is Regions List
        fixture.initialDestinations = [RegionsDestinations.serversList]
        instantiateSubject()
        
        // THEN the path and the path destinations contain one Destination item
        XCTAssertFalse(sut.path.isEmpty)
        XCTAssertFalse(sut.pathDestinations.isEmpty)
        XCTAssertEqual(sut.stackCount, 1)
        XCTAssertEqual(sut.pathDestinations.count, 1)
        
        // AND the current Destination of the router is set to the servers list
        XCTAssertEqual(sut.pathDestinations.last! as! RegionsDestinations, .serversList)
        
    }
    
    func test_navigateToDestination() {
        // GIVEN that the current path is empty
        instantiateSubject()
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertTrue(sut.pathDestinations.isEmpty)
        
        // WHEN navigating to the RegionsDestination search
        sut.navigate(to: RegionsDestinations.search)
        
        // THEN the current path destination is updated to RegionsDestinations search
        XCTAssertEqual(sut.pathDestinations.last! as! RegionsDestinations, .search)
        XCTAssertEqual(sut.stackCount, 1)
        XCTAssertEqual(sut.pathDestinations.count, 1)
        
    }
    
    func test_navigateBack() {
        // GIVEN that the AppRouter has navigated to the Regions search destination from the regions list destination
        fixture.initialDestinations = [RegionsDestinations.serversList, RegionsDestinations.search]
        instantiateSubject()
        XCTAssertEqual(sut.stackCount, 2)
        XCTAssertEqual(sut.pathDestinations.count, 2)
        XCTAssertEqual(sut.pathDestinations.last! as! RegionsDestinations, .search)
        
        // WHEN navigating back to the previous destination
        sut.pop()
        
        // THEN the path stack count decreases to 1 and the current destination becomes the Regions List
        XCTAssertEqual(sut.stackCount, 1)
        XCTAssertEqual(sut.pathDestinations.count, 1)
        XCTAssertEqual(sut.pathDestinations.last! as! RegionsDestinations, .serversList)
        
    }
    
    func test_navigateBackToRoot() {
        // GIVEN that the AppRouter has navigated to the Regions search destination from the regions list destination
        fixture.initialDestinations = [RegionsDestinations.serversList, RegionsDestinations.search]
        instantiateSubject()
        XCTAssertEqual(sut.stackCount, 2)
        XCTAssertEqual(sut.pathDestinations.count, 2)
        XCTAssertEqual(sut.pathDestinations.last! as! RegionsDestinations, .search)
        
        // WHEN navigating back to the root
        sut.goBackToRoot()
        
        // THEN the path and path destinations become empty
        XCTAssertTrue(sut.path.isEmpty)
        XCTAssertTrue(sut.pathDestinations.isEmpty)
        
    }
    
}
