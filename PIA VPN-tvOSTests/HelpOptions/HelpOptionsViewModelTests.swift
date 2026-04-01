//
//  HelpOptionsViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/27/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

import XCTest
@testable import PIA_VPN_tvOS

class HelpOptionsViewModelTests: XCTestCase {
    class Fixture {
        let connectionStatsPermissionMock = ConnectionStatsPermissonMock(value: nil)
        var infoDictionaryMock: [String: Any] = [:]
        var aboutOptionNavigationAction: AppRouter.Actions? = .navigate(router: AppRouterSpy(), destination: HelpDestinations.about)
        let appRouterSpy = AppRouterSpy()
    }
    
    var fixture: Fixture!
    var sut: HelpOptionsViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = HelpOptionsViewModel(connectionStatsPermission: fixture.connectionStatsPermissionMock, aboutOptionNavigationAction: fixture.aboutOptionNavigationAction!, infoDictionary: fixture.infoDictionaryMock)
    }
    
    func test_navigateToAboutSection() {
        // GIVEN that the navigation action is to navigate to 'HelpDestinations.about'
        fixture.aboutOptionNavigationAction = .navigate(router: fixture.appRouterSpy, destination: HelpDestinations.about)
        instantiateSut()
        
        XCTAssertTrue(fixture.appRouterSpy.requests.isEmpty)
        
        // WHEN the About Option button is tapped
        sut.aboutOptionsButtonWasTapped()
        
        // THEN the app router is called to navigate to the About section
        XCTAssertEqual(fixture.appRouterSpy.requests.count, 1)
        XCTAssertEqual(fixture.appRouterSpy.requests.first!, AppRouterSpy.Request.navigate(HelpDestinations.about))
        
    }
    
    func test_appInfo() {
        // GIVEN that the current app version is 3.10.15
        fixture.infoDictionaryMock["CFBundleShortVersionString"] = "3.10.15"
        // AND the build number is 25
        fixture.infoDictionaryMock[kCFBundleVersionKey as String] = "25"
        
        instantiateSut()
        
        let appInfoContent = sut.appInfoContent
        // THEN the value displayed for the app info is '3.10.15 (25)'
        XCTAssertEqual(appInfoContent.value, "3.10.15 (25)")
        XCTAssertEqual(appInfoContent.title, "App Version")
        
    }
    
    func test_tooggleConnectionStatsPermission() {
        // GIVEN that the connection stats is not allowed
        fixture.connectionStatsPermissionMock.set(value: false)
        
        // WHEN the sut is created
        instantiateSut()
        
        // THEN the value displayed for 'Help Improved PIA' is OFF
        XCTAssertEqual(sut.helpImproveSectionContent.value, "OFF")
        
        // AND when pressing the button to toggle the Connection stats permission
        sut.toggleHelpImprove()
        
        
        // THEN the Connection Stats permission is updated to 'true'
        XCTAssertEqual(fixture.connectionStatsPermissionMock.settedValues.last!, true)
        
        // AND the value displayed for 'Help Improved PIA' becomes ON
        XCTAssertEqual(sut.helpImproveSectionContent.value, "ON")
        
    }
    
}
