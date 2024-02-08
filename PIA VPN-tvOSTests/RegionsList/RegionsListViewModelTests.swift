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
        let favoriteRegionsUseCaseMock = FavoriteRegionUseCaseMock()
        let regionsFilterUseCaseMock = RegionsFilterUseCaseMock()
        let regionsDisplayNameUseCaseMock = RegionsDisplayNameUseCaseMock()
        let appRouterSpy = AppRouterSpy()
        static let barcelona = ServerMock(name: "Barcelona-1", identifier: "es-server-barcelona", regionIdentifier: "es-region", country: "ES", geo: false, pingTime: 25)
        static let madrid = ServerMock(name: "Madrid", identifier: "es-server-madrid", regionIdentifier: "es-region2", country: "ES", geo: false, pingTime: 12)
        static let toronto = ServerMock(name: "CA-Toronto", identifier: "ca-server", regionIdentifier: "canada", country: "CA", geo: false, pingTime: 30)
        static let montreal = ServerMock(name: "CA-Montreal", identifier: "ca-server2", regionIdentifier: "canada2", country: "CA", geo: false, pingTime: 42)
        
        var allServers: [ServerMock] = [
            toronto,
            montreal,
            barcelona,
            madrid
        ]
        
        func stubGetServers(for filter: RegionsListFilter, result: [ServerType]) {
            regionsFilterUseCaseMock.getServersWithFilterResult[filter] = result
        }
    }
    
    var fixture: Fixture!
    var sut: RegionsListViewModel!
    
    func instantiateSut(with filter: RegionsListFilter = .all,  routerAction: AppRouter.Actions? = nil) {
        let routerAction = routerAction ?? AppRouter.Actions.pop(router: fixture.appRouterSpy)
        sut = RegionsListViewModel(filter: filter, listUseCase: fixture.regionsListUseCaseMock, favoriteUseCase: fixture.favoriteRegionsUseCaseMock, regionsFilterUseCase: fixture.regionsFilterUseCaseMock, regionsDisplayNameUseCase: fixture.regionsDisplayNameUseCaseMock, onServerSelectedRouterAction: routerAction)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    func test_displayName_forServer() {
        // GIVEN that we have 4 servers (2 in ES and 2 in CA)
        fixture.stubGetServers(for: .all, result: fixture.allServers)
        // AND GIVEN that the regions display use case for Barcelona returns the country(as the title) and the server name(as the subtitle)
        fixture.regionsDisplayNameUseCaseMock.getDisplayNameResult = (title: Fixture.barcelona.country, subtitle: Fixture.barcelona.name)
        instantiateSut()
        
        // WHEN asking for the display name for the server Barcelona
        let displayName = sut.getDisplayName(for: Fixture.barcelona)
        // THEN the title of the display name is 'ES' (country) and the subtitle is 'Barcelona-1' (server name)
        XCTAssertEqual(displayName.title, "ES")
        XCTAssertEqual(displayName.subtitle, "Barcelona-1")
    }
    

    func test_regionServer_didSelect() {
        // GIVEN that the Regions list is created
        fixture.stubGetServers(for: .all, result: fixture.allServers)
        instantiateSut(routerAction: .pop(router: fixture.appRouterSpy))
        
        // THEN the regionsFilter is called once to fetch 'all' the servers
        XCTAssertTrue(fixture.regionsFilterUseCaseMock.getServersWithFilterCalled)
        XCTAssertEqual(fixture.regionsFilterUseCaseMock.getServersWithFilterCalledAttempt, 1)
        XCTAssertEqual(fixture.regionsFilterUseCaseMock.getServersWithFilterArgument, .all)
        
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
        // GIVEN THAT we are in the Search screen
        // AND we have 4 servers available (2 in CA and 2 in ES)
        fixture.stubGetServers(for: .all, result: fixture.allServers)
        fixture.stubGetServers(for: .searchResults("Canada"), result: [Fixture.toronto, Fixture.montreal])
        fixture.stubGetServers(for: .recommended, result: fixture.allServers)
        instantiateSut(with: .searchResults(""))

        
        // WHEN we search for 'Canada'
        sut.performSearch(with: "Canada")
        
        // THEN the displayed servers are only 2 (The ones in 'CA')
        XCTAssertEqual(sut.servers.count, 2)
        XCTAssertEqual(sut.servers.first?.country, "CA")
        XCTAssertEqual(sut.servers.last?.country, "CA")
        // AND the regions list title shows the results
        XCTAssertEqual(sut.regionsListTitle, "Search Results")
        
        // AND WHEN the search term becomes empty again
        sut.performSearch(with: "")
        // THEN the recommended locations are displayed
        XCTAssertEqual(sut.servers.count, 4)
        XCTAssertEqual(sut.regionsListTitle, "Recommended Locations")
    }
    
    func test_filterByAllRegions() {
        // GIVEN that the selected filter for the regions is 'All'
        fixture.stubGetServers(for: .all, result: fixture.allServers)
        instantiateSut(with: .all)
        
        // THEN all the locations are displayed
        XCTAssertEqual(sut.servers.count, 4)
    }
    
    func test_filterServersByRecommended() {
        // GIVEN that the selected filter for the regions is 'Recommended'
        // AND GIVEN that the servers with the least latency are Madrid and Barcelona
        fixture.stubGetServers(for: .all, result: fixture.allServers)
        fixture.stubGetServers(for: .recommended, result: [Fixture.madrid, Fixture.barcelona, Fixture.toronto, Fixture.montreal])
        instantiateSut(with: .recommended)
        
        // THEN the recommended locations are displayed in the following order
        XCTAssertEqual(sut.regionsListTitle, "Recommended Locations")
        XCTAssertEqual(sut.servers.count, 4)
        XCTAssertEqual(sut.servers[0].name, "Madrid")
        XCTAssertEqual(sut.servers[1].name, "Barcelona-1")
        XCTAssertEqual(sut.servers[2].name, "CA-Toronto")
        XCTAssertEqual(sut.servers[3].name, "CA-Montreal")
    }
    
    func test_previouslySearchedRegions_whenEmpty() {
        // GIVEN that the selected filter for the regions is 'previouslySearched'
        // AND no previous search has been performed
        fixture.stubGetServers(for: .previouslySearched, result: [])
        fixture.stubGetServers(for: .recommended, result: [Fixture.madrid, Fixture.barcelona, Fixture.toronto, Fixture.montreal])
        instantiateSut(with: .previouslySearched)
        
        // THEN the 'Recommended' locations are displayed in the following order
        XCTAssertEqual(sut.regionsListTitle, "Recommended Locations")
        XCTAssertEqual(sut.servers.count, 4)
        XCTAssertEqual(sut.servers[0].name, "Madrid")
        XCTAssertEqual(sut.servers[1].name, "Barcelona-1")
        XCTAssertEqual(sut.servers[2].name, "CA-Toronto")
        XCTAssertEqual(sut.servers[3].name, "CA-Montreal")
    }
    
    func test_previouslySearchedRegions_whenNotEmpty() {
        // GIVEN that the selected filter for the regions is 'previouslySearched'
        // AND a previous search has been performed with 'Barcelona'
        fixture.stubGetServers(for: .previouslySearched, result: [Fixture.barcelona])
        instantiateSut(with: .previouslySearched)
        
        // THEN the 'Last Searched Locations' locations are displayed
        XCTAssertEqual(sut.regionsListTitle, "Last Searched Locations")
        XCTAssertEqual(sut.servers.count, 1)
        XCTAssertEqual(sut.servers[0].name, "Barcelona-1")
        
    }
    
    
    func test_toggleRecommendedRegions_whenPerformingNewSearch() {
        // GIVEN that the selected filter for the regions is 'Recommended'
        fixture.stubGetServers(for: .recommended, result: fixture.allServers)
        fixture.stubGetServers(for: .searchResults("Canada"), result: [Fixture.montreal, Fixture.toronto])
        instantiateSut(with: .recommended)
        
        // THEN the 'Recommended Locations' are displayed
        XCTAssertEqual(sut.regionsListTitle, "Recommended Locations")
        XCTAssertEqual(sut.servers.count, 4)
        
        // AND the current filter on the regions list is 'recommended'
        XCTAssertEqual(sut.filter, .recommended)
        
        // AND WHEN a new search is performed
        sut.performSearch(with: "Canada")
        
        // THEN the regions list filter is updated to 'searchResults'
        XCTAssertEqual(sut.filter, .searchResults("Canada"))
        
        // AND the list shows the "Searched Results"
        XCTAssertEqual(sut.regionsListTitle, "Search Results")
        XCTAssertEqual(sut.servers.count, 2)
        XCTAssertEqual(sut.servers.first?.country, "CA")
        XCTAssertEqual(sut.servers.last?.country, "CA")
        
    }
    
    func test_filterRegionsListByFavorites() {
        
        fixture.regionsListUseCaseMock.getCurrentServersResult = fixture.allServers
        // GIVEN that the selected filter for the regions is 'Favorites'
        // AND GIVEN that the favorites servers are "Madrid" and "Barcelona"
        fixture.stubGetServers(for: .favorites, result: [Fixture.barcelona, Fixture.madrid])

        instantiateSut(with: .favorites)
        
        // THEN the regions list only shows the Favorites servers
        // sorted in alphabetically order
        XCTAssertEqual(sut.servers.count, 2)
        XCTAssertEqual(sut.servers[0].name, "Barcelona-1")
        XCTAssertEqual(sut.servers[1].name, "Madrid")
        
    }
    
    func test_addToFavorites() {
        // GIVEN that "Barcelona is not on the Favorites list"
        fixture.favoriteRegionsUseCaseMock.favoriteIdentifiers = []
        instantiateSut()
        
        // WHEN calling the toggle method on the favorites list with Barcelona
        sut.toggleFavorite(server: Fixture.barcelona)
        
        // THEN the use case is called once to add Barcelona to the Favorites list
        XCTAssertTrue(fixture.favoriteRegionsUseCaseMock.addToFavoritesCalled)
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.addToFavoritesCalledAttempt, 1)
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.addToFavoritesCalledWithArgument, Fixture.barcelona.identifier)
        // AND no error is registered when toggling a region from the favorites
        XCTAssertNil(sut.favoriteToggleError)
        
        // AND the use case is NOT called to remove any server from the favorites list
        XCTAssertFalse(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalled)
    }
    
    func test_removeFromFavorites() {
        // GIVEN that "Barcelona is on the Favorites list"
        fixture.favoriteRegionsUseCaseMock.favoriteIdentifiers = [Fixture.barcelona.identifier]
        instantiateSut()
        
        // WHEN calling the toggle method on the favorites list with Barcelona
        sut.toggleFavorite(server: Fixture.barcelona)
        
        // THEN the use case is called once to remove Barcelona from the Favorites list
        XCTAssertTrue(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalled)
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalledAttempt, 1)
        XCTAssertEqual(fixture.favoriteRegionsUseCaseMock.removeFromFavoritesCalledWithArgument, Fixture.barcelona.identifier)
        // AND no error is registered when toggling a region from the favorites
        XCTAssertNil(sut.favoriteToggleError)
        
        // AND the use case is NOT called to add any server from the favorites list
        XCTAssertFalse(fixture.favoriteRegionsUseCaseMock.addToFavoritesCalled)
    }
    
    
}
