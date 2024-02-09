//
//  RegionsDisplayNameUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/9/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

class RegionsDisplayNameUseCaseMock: RegionsDisplayNameUseCaseType {
   
    var getDisplayNameResult: (title: String, subtitle: String) = (title: "", subtitle: "")
    var getDisplayNameCalled = false
    var getDisplayNameCalledWithParamerters: (server: ServerType, servers: [ServerType])!
    
    func getDisplayName(for server: ServerType, amongst servers: [ServerType]) -> (title: String, subtitle: String) {
        getDisplayNameCalled = true
        getDisplayNameCalledWithParamerters = (server: server, servers: servers)
        return getDisplayNameResult
        
    }
}
