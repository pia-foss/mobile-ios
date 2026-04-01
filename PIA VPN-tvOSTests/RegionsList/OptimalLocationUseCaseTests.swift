//
//  OptimalLocationUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/20/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
import PIALibrary
import Combine
@testable import PIA_VPN_tvOS

class OptimalLocationUseCaseTests: XCTestCase {
    class Fixture {
        let serverProviderMock = ServerProviderMock()
        let vpnStatusMonitorMock = VPNStatusMonitorMock()
        let selectedServerUseCaseMock = SelectedServerUseCaseMock()
        
        static let madrid = ServerMock(name: "Madrid", identifier: "es-server-madrid", regionIdentifier: "es-region2", country: "ES", geo: false, pingTime: 12)
    }
    
    var fixture: Fixture!
    var sut: OptimalLocationUseCase!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = Set<AnyCancellable>()
    }
    
    private func instantiateSut() {
        sut = OptimalLocationUseCase(serverProvider: fixture.serverProviderMock, vpnStatusMonitor: fixture.vpnStatusMonitorMock, selectedServerUseCase: fixture.selectedServerUseCaseMock)
    }
    
    func test_targetLocation_whenOptimalSelected_andVpnConnected() {
        instantiateSut()
        
        // GIVEN that the target location on the server provider is 'Madrid'
        fixture.serverProviderMock.targetServerTypeResult = Fixture.madrid
       
        // AND GIVEN that the selected location is 'Automatic'
        fixture.selectedServerUseCaseMock.getSelectedServerResult.send(Server.automatic)
        
        // AND GIVEN that the vpn is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)
        
        
        var targetLocationForOptimalLocationValues: [ServerType?] = []
        let expectation = expectation(description: "")
        sut.getTargetLocaionForOptimalLocation()
            .sink { newValue in
                targetLocationForOptimalLocationValues.append(newValue)
                if let newValue,
                   newValue.identifier == Fixture.madrid.identifier
                 {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let currentTargetLocationForOptimalLocation = targetLocationForOptimalLocationValues.last
        
        // THEN the target location for the  Optimal Location is 'Madrid'
        XCTAssertNotNil(currentTargetLocationForOptimalLocation!)
        XCTAssertEqual(currentTargetLocationForOptimalLocation!?.name, Fixture.madrid.name)
        
    }
    
    func test_targetLocation_whenOptimalSelected_andVpnDisconnected() {
        instantiateSut()
        
        // GIVEN that the target location on the server provider is 'Madrid'
        fixture.serverProviderMock.targetServerTypeResult = Fixture.madrid
       
        // AND GIVEN that the selected location is 'Automatic'
        fixture.selectedServerUseCaseMock.getSelectedServerResult.send(Server.automatic)
        
        // AND GIVEN that the vpn is disconnected
        fixture.vpnStatusMonitorMock.status.send(.disconnected)
        
        var targetLocationForOptimalLocationValues: [ServerType?] = []
        let expectation = expectation(description: "")
        sut.getTargetLocaionForOptimalLocation()
            .sink { newValue in
                targetLocationForOptimalLocationValues.append(newValue)
                if newValue == nil {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let currentTargetLocationForOptimalLocation = targetLocationForOptimalLocationValues.last
        // THEN the target location for the  Optimal Location is nil
        XCTAssertNil(currentTargetLocationForOptimalLocation!)
        
    }
    
    func test_targetLocation_whenOptimalIsNotSelected_andVpnDisconnected() {
        instantiateSut()
       
        // GIVEN that the selected location is 'Madrid'
        fixture.selectedServerUseCaseMock.getSelectedServerResult.send(Fixture.madrid)
        
        // AND GIVEN that the vpn is disconnected
        fixture.vpnStatusMonitorMock.status.send(.disconnected)
        
        var targetLocationForOptimalLocationValues: [ServerType?] = []
        let expectation = expectation(description: "")
        sut.getTargetLocaionForOptimalLocation()
            .sink { newValue in
                targetLocationForOptimalLocationValues.append(newValue)
                if newValue == nil {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let currentTargetLocationForOptimalLocation = targetLocationForOptimalLocationValues.last
        // THEN the target location for the  Optimal Location is nil
        XCTAssertNil(currentTargetLocationForOptimalLocation!)
        
    }
    
    func test_targetLocation_whenOptimalIsNotSelected_andVpnConnected() {
        instantiateSut()
       
        // GIVEN that the selected location is 'Madrid'
        fixture.selectedServerUseCaseMock.getSelectedServerResult.send(Fixture.madrid)
        
        // AND GIVEN that the vpn is connected
        fixture.vpnStatusMonitorMock.status.send(.connected)
        
        var targetLocationForOptimalLocationValues: [ServerType?] = []
        let expectation = expectation(description: "")
        sut.getTargetLocaionForOptimalLocation()
            .sink { newValue in
                targetLocationForOptimalLocationValues.append(newValue)
                if newValue == nil {
                    expectation.fulfill()
                }
            }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let currentTargetLocationForOptimalLocation = targetLocationForOptimalLocationValues.last
        // THEN the target location for the  Optimal Location is nil
        XCTAssertNil(currentTargetLocationForOptimalLocation!)
        
    }
    
}
