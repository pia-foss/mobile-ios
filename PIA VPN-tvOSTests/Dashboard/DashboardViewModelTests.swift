//
//  DashboardViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 1/16/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import PIA_VPN_tvOS
import SwiftUI

class DashboardViewModelTests: XCTestCase {
    class Fixture {
        let connectionStateMonitorMock = ConnectionStateMonitorMock()
    }
    
    var fixture: Fixture!
    var sut: DashboardViewModel!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
    }
    
    private func initializeSut() {
        sut = DashboardViewModel(connectionStateMonitor: fixture.connectionStateMonitorMock)
    }
    
    func test_tintColorForConnectionState() {

        initializeSut()
        
        // WHEN calculating the tint color for each connection state
        let connectedStateTintColors = sut.getTintColor(for: .connected)
        
        let disconnectedStateTintColors = sut.getTintColor(for: .disconnected)
        
        let errorStateTintColors = sut.getTintColor(for: .error(NSError(domain: "some-test-error", code: 1)))
        
        let connectingStateTintColors = sut.getTintColor(for: .connecting)
        
        let disconnectingStateTintColors = sut.getTintColor(for: .disconnecting)
        
        // THEN the colors on 'connected' state are
        XCTAssertEqual(Color.pia_primary, connectedStateTintColors.titleTint)
        XCTAssertEqual(Color.pia_primary, connectedStateTintColors.connectionBarTint)
        
        // THEN the colors on 'disconnected' state are
        XCTAssertEqual(Color.pia_on_surface, disconnectedStateTintColors.titleTint)
        XCTAssertEqual(Color.clear, disconnectedStateTintColors.connectionBarTint)
        
        // THEN the colors on 'error' state are
        XCTAssertEqual(Color.pia_red, errorStateTintColors.titleTint)
        XCTAssertEqual(Color.pia_red, errorStateTintColors.connectionBarTint)
        
        // THEN the colors on 'connecting' state are
        XCTAssertEqual(Color.pia_yellow_dark, connectingStateTintColors.titleTint)
        XCTAssertEqual(Color.pia_yellow_dark, connectingStateTintColors.connectionBarTint)
        
        // THEN the colors on 'disconnecting' state are
        XCTAssertEqual(Color.pia_yellow_dark, disconnectingStateTintColors.titleTint)
        XCTAssertEqual(Color.pia_yellow_dark, disconnectingStateTintColors.connectionBarTint)
    }
    
    
}
