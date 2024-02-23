//
//  ClientPreferencesMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 22/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import Combine

class ClientPreferencesMock: ClientPreferencesType {
    var selectedServer: ServerType
    
    private var selectedServerPublisher: CurrentValueSubject<ServerType, Never>
    
    init(selectedServer: ServerType) {
        self.selectedServer = selectedServer
        self.selectedServerPublisher = CurrentValueSubject(selectedServer)
    }
    
    func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        return selectedServerPublisher.eraseToAnyPublisher()
    }
}
