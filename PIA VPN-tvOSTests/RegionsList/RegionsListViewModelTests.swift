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
        
        var allServers: [ServerMock] = [
            ServerMock(name: "Toronto", identifier: "ca-server", regionIdentifier: "ca-region", country: "CA", geo: false),
            ServerMock(name: "Montreal", identifier: "ca-server2", regionIdentifier: "ca-region2", country: "CA", geo: false),
            ServerMock(name: "Barcelona-1", identifier: "es-server", regionIdentifier: "es-region", country: "ES", geo: false),
            ServerMock(name: "Madrid", identifier: "es-server2", regionIdentifier: "es-region2", country: "ES", geo: false)
            
        ]
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
    
    func test_regionsDidSearch() {
        // GIVEN THAT we have 4 servers available (2 in CA and 2 in ES)
        fixture.regionsListUseCaseMock.getCurrentServersResult = fixture.allServers
        instantiateSut(with: .pop(router: fixture.appRouterSpy))
        XCTAssertEqual(sut.servers.count, 4)
        
        // WHEN we search for 'Canada'
        sut.search = "Canada"
        
        // THEN the displayed servers are only 2 (The ones in 'CA')
        XCTAssertEqual(sut.servers.count, 2)
        XCTAssertEqual(sut.servers.first!.country, "CA")
        XCTAssertEqual(sut.servers.last!.country, "CA")
    }
    
}
