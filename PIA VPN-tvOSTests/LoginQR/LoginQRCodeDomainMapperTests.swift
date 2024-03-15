//
//  LoginQRCodeDomainMapperTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS

final class LoginQRCodeDomainMapperTests: XCTestCase {

    func test_mapToLoginQRCode() {
        // GIVEN
        let sut = LoginQRCodeDomainMapper()
        let dto = LoginQRTokenDTO(token: "token", expiresAt: "2024-05-24T00:00:00Z")
        
        // WHEN
        let domainModel = sut.map(dto: dto)
        
        // THEN
        XCTAssertEqual(domainModel?.token, "token")
        XCTAssertEqual(domainModel?.url, URL(string: "PIA://token=token"))
        XCTAssertEqual(domainModel?.expiresAt, Date.makeISO8601Date(string: "2024-05-24T00:00:00Z"))
    }
    
    func test_mapToUserToken() {
        // GIVEN
        let sut = LoginQRCodeDomainMapper()
        let dto = UserTokenDTO(token: "token", expiresAt: "2024-05-24T00:00:00Z", userId: "userId")
        
        // WHEN
        let domainModel = sut.map(dto: dto)
        
        // THEN
        XCTAssertEqual(domainModel?.token, "token")
        XCTAssertEqual(domainModel?.expiresAt, Date.makeISO8601Date(string: "2024-05-24T00:00:00Z"))
        XCTAssertEqual(domainModel?.userId, "userId")
    }
}
