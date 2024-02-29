//
//  SelectedServerViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import PIA_VPN_tvOS

class SelectedServerViewModelTests: XCTestCase {
    class Fixture {
        let selectedServerUseCaseMock = SelectedServerUseCaseMock()
        let optimalLocationUseCaseMock = OptimalLocationUseCaseMock()
        let regionsDisplayNameUseCaseMock = RegionsDisplayNameUseCaseMock()
        var getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: nil)
        let routerSpy = AppRouterSpy()
        var routerActionMock: AppRouter.Actions!
        
        static let barcelona = ServerMock(name: "Barcelona-1", identifier: "es-server-barcelona", regionIdentifier: "es-region", country: "ES", geo: false, pingTime: 25)
        
        static let optimaLocation = ServerMock(isAutomatic: true)
        
        static let dipServer = ServerMock(name: "US New York", identifier: "us-ny", regionIdentifier: "us", country: "us", geo: false)
        
        init() {
            self.routerActionMock = .goBackToRoot(router: self.routerSpy)
        }
        
        func stubGetDedicatedIpServer(_ server: ServerType) {
            self.getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: server)
        }
    }
    
    var fixture: Fixture!
    var sut: SelectedServerViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        sut = SelectedServerViewModel(useCase: fixture.selectedServerUseCaseMock, 
                                      optimalLocationUseCase: fixture.optimalLocationUseCaseMock,
                                      regionsDisplayNameUseCase: fixture.regionsDisplayNameUseCaseMock,
                                      getDedicatedIpUseCase: fixture.getDedicatedIpUseCaseMock,
                                      routerAction: fixture.routerActionMock)
        
    }
    
    
    func test_selectedServerTitle_forOptimalLocation() {
        // GIVEN that the selected location is the Optimal Location
        instantiateSut()
        sut.selectedServer = Fixture.optimaLocation
        
        // THEN the selected server titl is "Optimal Location"
        XCTAssertEqual(sut.selectedSeverTitle, "Optimal Location")
    }
    
    func test_selectedServerTitle_forNonOptimalLocation() {
        // GIVEN that the selected location is Barcelona
        instantiateSut()
        sut.selectedServer = Fixture.barcelona
        
        // THEN the selected server titl is "Selected Location"
        XCTAssertEqual(sut.selectedSeverTitle, "Selected Location")
    }
    
    
    func test_iconImageForOptimalLocation() {
        // GIVEN that the selected location is the Optimal Location
        instantiateSut()
        sut.selectedServer = Fixture.optimaLocation
        
        let iconImageNameWhenFocused = sut.iconImageNameFor(focused: true)
        
        // THEN the icon image for focused state name is
        XCTAssertEqual(iconImageNameWhenFocused, .smart_location_icon_highlighted_name)
        
        let iconImageNameWhenNotFocused = sut.iconImageNameFor(focused: false)
        
        // AND the icon image for not focused state name is
        XCTAssertEqual(iconImageNameWhenNotFocused, .smart_location_icon_name)
        
    }
    
    func test_iconImageForDipLocation() {
        // GIVEN that the selected location is the dip location
        fixture.stubGetDedicatedIpServer(Fixture.dipServer)
        instantiateSut()
        sut.selectedServer = Fixture.dipServer
        
        let iconImageNameWhenFocused = sut.iconImageNameFor(focused: true)
        
        // THEN the icon image for focused state name is
        XCTAssertEqual(iconImageNameWhenFocused, .icon_dip_location)
        
        let iconImageNameWhenNotFocused = sut.iconImageNameFor(focused: false)
        
        // AND the icon image for not focused state name is
        XCTAssertEqual(iconImageNameWhenNotFocused, .icon_dip_location)
        
    }
    
    func test_iconImageForNonOptimalAndNonDipLocation() {
        // GIVEN that the selected location is Barcelona and is Not the Optimal Location or a dip location
        instantiateSut()
        sut.selectedServer = Fixture.barcelona
        
        let iconImageNameWhenFocused = sut.iconImageNameFor(focused: true)
        
        // THEN the icon image for focused state name is
        XCTAssertEqual(iconImageNameWhenFocused, "flag-es")
        
        let iconImageNameWhenNotFocused = sut.iconImageNameFor(focused: false)
        
        // AND the icon image for not focused state name is
        XCTAssertEqual(iconImageNameWhenNotFocused, "flag-es")
        
    }
    
}
