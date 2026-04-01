//
//  RegionsFilterUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

import XCTest
@testable import PIA_VPN_tvOS

class RegionsFilterUseCaseTests: XCTestCase {
    class Fixture {
        let serversUseCaseMock = RegionsListUseCaseMock()
        let favoritesUseCaseMock = FavoriteRegionUseCaseMock()
        let searchedRegionAvailabilityMock = SearchedRegionsAvailabilityMock()
        var getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: nil)
        
        static let barcelona = ServerMock(name: "Barcelona-1", identifier: "es-server-barcelona", regionIdentifier: "es-region", country: "ES", geo: false, pingTime: 25)
        static let madrid = ServerMock(name: "Madrid", identifier: "es-server-madrid", regionIdentifier: "es-region2", country: "ES", geo: false, pingTime: 12)
        static let toronto = ServerMock(name: "Toronto", identifier: "ca-server", regionIdentifier: "canada", country: "CA", geo: false, pingTime: 30)
        static let montreal = ServerMock(name: "Montreal", identifier: "ca-server2", regionIdentifier: "canada2", country: "CA", geo: false, pingTime: 42)
        
        static let dipServer = ServerMock(name: "US New York", identifier: "us-ny", regionIdentifier: "us", country: "us", geo: false)
        
        var allServers: [ServerMock] = [
            toronto,
            montreal,
            barcelona,
            madrid
        ]
        
        var allServersWithDipServer: [ServerMock] = [
            toronto,
            montreal,
            barcelona,
            madrid,
            dipServer
        ]
        
        func stubGetDedicatedIpServer(_ server: ServerType) {
            self.getDedicatedIpUseCaseMock = GetDedicatedIpUseCaseMock(result: server)
        }
    }
    
    var fixture: Fixture!
    var sut: RegionsFilterUseCase!
    
    func instantiateSut() {
        sut = RegionsFilterUseCase(serversUseCase: fixture.serversUseCaseMock, favoritesUseCase: fixture.favoritesUseCaseMock, searchedRegionsAvailability: fixture.searchedRegionAvailabilityMock, getDedicatedIpUseCase: fixture.getDedicatedIpUseCaseMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_getServers_withAllFilter_WhenNoDipServer() {
        // GIVEN that we have 4 servers
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServers
        instantiateSut()
        
        // WHEN getting the list of the servers filtered by 'all'
        let servers = sut.getServers(with: .all)
        
        // THEN all the servers are returned sorted alphabetically by name
        XCTAssertEqual(servers.count, 4)
        XCTAssertEqual(servers[0].identifier, Fixture.barcelona.identifier)
        XCTAssertEqual(servers[1].identifier, Fixture.madrid.identifier)
        XCTAssertEqual(servers[2].identifier, Fixture.montreal.identifier)
        XCTAssertEqual(servers[3].identifier, Fixture.toronto.identifier)
    }
    
    func test_getServers_withAllFilter_whenThereIsADipServer() {
        // GIVEN that we have 5 servers (4 Servers + 1 DIP server)
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServersWithDipServer
        fixture.stubGetDedicatedIpServer(Fixture.dipServer)
        instantiateSut()
        
        // WHEN getting the list of the servers filtered by 'all'
        let servers = sut.getServers(with: .all)
        
        // THEN all the servers are returned sorted alphabetically by name except the DIP server
        XCTAssertEqual(servers.count, 4)
        XCTAssertEqual(servers[0].identifier, Fixture.barcelona.identifier)
        XCTAssertEqual(servers[1].identifier, Fixture.madrid.identifier)
        XCTAssertEqual(servers[2].identifier, Fixture.montreal.identifier)
        XCTAssertEqual(servers[3].identifier, Fixture.toronto.identifier)
    }
    
    func test_getServers_withFavoriteFilter() {
        // GIVEN that we have 4 servers available
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServers
        // AND GIVEN that we have 2 servers in favorites (Madrid and Barcelona)
        fixture.favoritesUseCaseMock.favoriteIdentifiers = [Fixture.madrid.identifier, Fixture.barcelona.identifier]
        
        instantiateSut()
        
        // WHEN getting the list of the servers filtered by 'favorites'
        let servers = sut.getServers(with: .favorites)
        
        // THEN only te favorites servers are returned sorted alphabetically by name
        XCTAssertEqual(servers.count, 2)
        XCTAssertEqual(servers[0].identifier, Fixture.barcelona.identifier)
        XCTAssertEqual(servers[1].identifier, Fixture.madrid.identifier)

    }
    
    func test_getServers_withRecommendedFilter() {
        // GIVEN that we have 4 servers available
        // AND GIVEN that the least latency server is Madrid
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServers
        
        instantiateSut()
        
        // WHEN getting the list of the servers filtered by 'recommended'
        let servers = sut.getServers(with: .recommended)
        
        // THEN the Servers are listed sorted by ping time (Madrid first)
        XCTAssertEqual(servers.count, 4)
        XCTAssertEqual(servers[0].identifier, Fixture.madrid.identifier)
        XCTAssertEqual(servers[1].identifier, Fixture.barcelona.identifier)
        XCTAssertEqual(servers[2].identifier, Fixture.toronto.identifier)
        XCTAssertEqual(servers[3].identifier, Fixture.montreal.identifier)
        
    }
    
    func test_getServers_withSearchResultsFilter_whenSearchTermHasOneWord() {
        // GIVEN that we have 5 servers
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServersWithDipServer
        instantiateSut()
        
        // WHEN getting the list of servers filtered by "Canada"
        let servers = sut.getServers(with: .searchResults("Canada"))
        
        // THEN only Montreal and Toronto servers are returned
        XCTAssertEqual(servers.count, 2)
        XCTAssertEqual(servers[0].identifier, Fixture.montreal.identifier)
        XCTAssertEqual(servers[1].identifier, Fixture.toronto.identifier)
    }
    
    func test_getServers_withSearchResultsFilter_whenSearchTermHasMoreThanOneWord() {
        // GIVEN that we have 5 servers
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServersWithDipServer
        instantiateSut()
        
        // WHEN getting the list of servers filtered by "New Yo"
        let servers = sut.getServers(with: .searchResults("New Yo"))
        
        // THEN only server returned is the New York Server (the dip Server)
        XCTAssertEqual(servers.count, 1)
        XCTAssertEqual(servers[0].identifier, Fixture.dipServer.identifier)
        XCTAssertEqual(servers[0].name, "US New York")
    }
    
    func test_getServers_withPreviouslySearchedFilter() {
        // GIVEN that we have 4 servers
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServers
        // AND GIVEN that only Barcelona has been searched before
        fixture.searchedRegionAvailabilityMock.getResult = [Fixture.barcelona.identifier]
        instantiateSut()
        
        // WHEN getting the list of servers filtered by "previously searched"
        let servers = sut.getServers(with: .previouslySearched)
        
        // THEN only Barcelona is returned
        XCTAssertEqual(servers.count, 1)
        XCTAssertEqual(servers[0].identifier, Fixture.barcelona.identifier)
    }
    
    
    func test_saveToPreiouslySearched() {
        // GIVEN that we have 4 servers (2 in Spain and 2 in Canada)
        fixture.serversUseCaseMock.getCurrentServersResult = fixture.allServers
        instantiateSut()
        
        // WHEN trying to set all servers to the previously searched
        let allServers = sut.getServers(with: .all)
        sut.saveToPreviouslySearched(servers: allServers)
        // THEN none of them is stored as previously searched (Because they belong to different countries)
        XCTAssertFalse(fixture.searchedRegionAvailabilityMock.setCalled)
        
        // AND WHEN we try to save only the servers that belong to Canada
        let servers = sut.getServers(with: .searchResults("Canada"))
        sut.saveToPreviouslySearched(servers: servers)
        
        // THEN Montreal and Toronto are stored in the previously searched list
        XCTAssertTrue(fixture.searchedRegionAvailabilityMock.setCalled)
        XCTAssertEqual(fixture.searchedRegionAvailabilityMock.setCalledWithArgument,  [Fixture.montreal.identifier, Fixture.toronto.identifier])
    }
    
}
