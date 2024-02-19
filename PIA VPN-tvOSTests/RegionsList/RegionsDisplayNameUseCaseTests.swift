//
//  File.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/9/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS

class RegionsDisplayNameUseCaseTests: XCTestCase {
    class Fixture {
        static let barcelona = ServerMock(name: "Barcelona-1", identifier: "es-server-barcelona", regionIdentifier: "es-region", country: "ES", geo: false, pingTime: 25)
        static let madrid = ServerMock(name: "Madrid", identifier: "es-server-madrid", regionIdentifier: "es-region2", country: "ES", geo: false, pingTime: 12)
        static let toronto = ServerMock(name: "CA Toronto", identifier: "ca-server", regionIdentifier: "canada", country: "CA", geo: false, pingTime: 30)
        static let montreal = ServerMock(name: "CA Montreal", identifier: "ca-server2", regionIdentifier: "canada2", country: "CA", geo: false, pingTime: 42)
        static let france = ServerMock(name: "France", identifier: "fr-server", regionIdentifier: "france-region", country: "FR", geo: false, pingTime: 18)
        
        var allServers: [ServerMock] = [
            toronto,
            montreal,
            barcelona,
            madrid,
            france
        ]
        
    }
    
    var fixture: Fixture!
    var sut: RegionsDisplayNameUseCase!
    
    func instantiateSut() {
        sut = RegionsDisplayNameUseCase()
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    
    func test_displayNameForDefaultServer() {
        // GIVEN that we have 5 servers (2 in ES, 2 in CA and 1 in FR)
        instantiateSut()
        
        // WHEN calculating the display name for FR (only one server)
        let displayName = sut.getDisplayName(for: Fixture.france, amongst: fixture.allServers)
        // THEN the title is the server name
        XCTAssertEqual(displayName.title, Fixture.france.name)
        // AND the subtitle is 'Default'
        XCTAssertEqual(displayName.subtitle, "Default Location")
    }
    
    func test_displayNameForNonDefaultServer_containingCountryCodeInName() {
        // GIVEN that we have 5 servers (2 in ES, 2 in CA and 1 in FR)
        instantiateSut()
        
        // WHEN calculating the display name for 'CA Toronto'
        let displayName = sut.getDisplayName(for: Fixture.toronto, amongst: fixture.allServers)
        // THEN the title is the server country code
        XCTAssertEqual(displayName.title, "CA")
        // AND the subtitle is the server name without the country code at the beginning
        XCTAssertEqual(displayName.subtitle, "Toronto")
    }
    
    func test_displayNameForNonDefaultServer_notContainingCountryCodeInName() {
        // GIVEN that we have 5 servers (2 in ES, 2 in CA and 1 in FR)
        instantiateSut()
        
        // WHEN calculating the display name for 'Madrid'
        let displayName = sut.getDisplayName(for: Fixture.madrid, amongst: fixture.allServers)
        // THEN the title is the server country code
        XCTAssertEqual(displayName.title, "ES")
        // AND the subtitle is the server name
        XCTAssertEqual(displayName.subtitle, "Madrid")
    }
    
}
