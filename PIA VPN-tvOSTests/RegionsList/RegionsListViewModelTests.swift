//
//  RegionsListViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 1/18/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS

class RegionsListViewModelTests: XCTestCase {
    class Fixture {
        let regionsListUseCaseMock = RegionsListUseCaseMock()
        let appRouterSpy = AppRouterSpy()
    }
    
    var fixture: Fixture!
    var sut: RegionsListViewModel!
    
    func instantiateSut(with routerAction: AppRouter.Actions) {
        sut = RegionsListViewModel(useCase: fixture.regionsListUseCaseMock, onServerSelectedRouterAction: routerAction)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    

    func test_regionServer_didSelect() {
        // GIVEN that the Regions list is created
        instantiateSut(with: .pop(router: fixture.appRouterSpy))
        
        // THEN the useCase is called once to fetch the current servers
        XCTAssertTrue(fixture.regionsListUseCaseMock.getCurrentServersCalled)
        XCTAssertEqual(fixture.regionsListUseCaseMock.getCurrentServersCalledAttempt, 1)
        
        // AND the useCase is NOT called to select any server
        XCTAssertFalse(fixture.regionsListUseCaseMock.selectServerCalled)
        
        // AND the AppRouter does not contain any request
        XCTAssertEqual(fixture.appRouterSpy.requests, [])
        
        let selectedServer = ServerMock(name: "server-name", identifier: "server-id", regionIdentifier: "region-id", country: "ES", geo: false)
        
        // WHEN a server is selected
        sut.didSelectRegionServer(selectedServer)
        
        // THEN the RegionsListUseCase is called once to select the expected server
        XCTAssertTrue(fixture.regionsListUseCaseMock.selectServerCalled)
        XCTAssertEqual(fixture.regionsListUseCaseMock.selectServerCalledAttempt, 1)
        XCTAssertEqual(fixture.regionsListUseCaseMock.selectServerCalledWithArgument!.identifier, selectedServer.identifier)
        
        // AND the AppRouter is called to pop the current view
        XCTAssertEqual(fixture.appRouterSpy.requests, [.pop])
        
    }
    
}
