//
//  VpnConnectionUseCaseTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/14/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class VpnConnectionUseCaseMock: VpnConnectionUseCaseType {
    
    var connectToServerCalled: Bool = false
    var connectCalledToServerAttempt: Int = 0
    var connectToServerCalledWithArgument: ServerType?
    
    var connectionAction: (() -> Void)?
    var disconnectionAction: (() -> Void)?
    
    func connect(to server: ServerType) {
        connectToServerCalled = true
        connectCalledToServerAttempt += 1
        connectToServerCalledWithArgument = server
        connectionAction?()
    }
    
    var connectCalled: Bool = false
    var connectCalledAttempt: Int = 0
    
    func connect() {
        connectCalled = true
        connectCalledAttempt += 1
        connectionAction?()
    }
    
    var disconnectCalled: Bool = false
    var disconnectCalledAttempt: Int = 0
    
    func disconnect() {
        disconnectCalled = true
        disconnectCalledAttempt += 1
        disconnectionAction?()
    }
    
    
}
