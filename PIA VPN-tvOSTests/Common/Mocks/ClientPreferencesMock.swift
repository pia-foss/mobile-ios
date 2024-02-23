//
//  ClientPreferencesMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/23/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
@testable import PIA_VPN_tvOS

class ClientPreferencesMock: ClientPreferencesType {
    
    var selectedServer: ServerType = ServerMock()
    
    var lastConnectedServer: ServerType?
    
    
    var selectedServerPublisher: CurrentValueSubject<ServerType, Never> = CurrentValueSubject(ServerMock())
    var getSelectedServerCalled = false
    func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        getSelectedServerCalled = true
        return selectedServerPublisher.eraseToAnyPublisher()
    }
    
    
}
