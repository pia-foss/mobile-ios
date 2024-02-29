//
//  LicensesUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/28/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS

class LicensesUseCaseTests: XCTestCase {
    class Fixture {
        let urlSessionMock = URLSessionMock()
        let licenseOne = LicenseComponent("license-name", "license-copyright", URL(string: "license-url")!)
    }
    
    var fixture: Fixture!
    var sut: LicensesUseCase!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = LicensesUseCase(urlSession: fixture.urlSessionMock)
    }
    
    func test_getLicensesContentWhenNoCache() async {
        // GIVEN that no licenses content has been retrieved before
        instantiateSut()
        let initialCache = await sut.cachedLicenseContent
        XCTAssertTrue(initialCache.isEmpty)
        XCTAssertFalse(fixture.urlSessionMock.dataTaskCalled)
        
        // WHEN getting the content for a license
        let content = await sut.getLicenseContent(for: fixture.licenseOne)
        
        // THEN the license is retrieved from the Network
        XCTAssertTrue(fixture.urlSessionMock.dataTaskCalled)
        
        // AND the content gets cached
        let cachedContent = await sut.cachedLicenseContent[fixture.licenseOne.name]
        XCTAssertNotNil(cachedContent)
    }
    
    func test_getLicensesContentWhenCached() async {
        // GIVEN that a license content has been retrieved before
        instantiateSut()
        await MainActor.run {
            sut.cachedLicenseContent = ["license-name" : "some license content"]
        }
        
        // WHEN getting the content for a license
        let content = await sut.getLicenseContent(for: fixture.licenseOne)
        
        // THEN the license is NOT retrieved from the Network
        XCTAssertFalse(fixture.urlSessionMock.dataTaskCalled)
        
        // AND the content remains cached
        let cachedContent = await sut.cachedLicenseContent[fixture.licenseOne.name]
        XCTAssertNotNil(cachedContent)
    }
    
}
