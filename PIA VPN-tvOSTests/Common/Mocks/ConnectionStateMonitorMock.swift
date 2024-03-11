//
//  ConnectionStateMonitorMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/13/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class ConnectionStateMonitorMock: ConnectionStateMonitorType {
    
    @Published internal var connectionState: ConnectionState = .unkown
    var connectionStatePublisher: Published<ConnectionState>.Publisher {
        $connectionState
    }
    var currentConnectionState: ConnectionState { connectionState }
    
    var callAsFunctionCalled = false
    var callAsFunctionCalledAttempt = 0
    func callAsFunction() {
        callAsFunctionCalled = true
        callAsFunctionCalledAttempt += 1
    }
    
}
