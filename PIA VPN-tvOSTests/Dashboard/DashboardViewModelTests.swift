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
        let accountProviderMock = AccountProviderTypeMock()
        let appRouter = AppRouter()
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
        sut = DashboardViewModel(accountProvider: fixture.accountProviderMock, appRouter: fixture.appRouter, navigationDestination: RegionsDestinations.serversList)
    }
    
    
}
