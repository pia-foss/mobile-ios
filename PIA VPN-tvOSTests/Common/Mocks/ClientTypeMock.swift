//
//  ClientTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class ClientTypeMock: ClientType {

    var pingServersCalled = false
    var pingServersCalledAttempt = 0
    var pingServersCalledWithServers:[ServerType] = []
    func ping(servers: [ServerType]) {
        pingServersCalled = true
        pingServersCalledAttempt += 1
        pingServersCalledWithServers = servers
    }
    
    
}
