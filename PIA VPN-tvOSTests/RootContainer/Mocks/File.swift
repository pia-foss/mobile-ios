//
//  File.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine

@testable import PIA_VPN_tvOS

class RefreshServersLatencyUseCaseMock: RefreshServersLatencyUseCaseType {
    
    @Published var state: RefreshServersLatencyUseCase.State = .none
    
    var statePublisher: Published<RefreshServersLatencyUseCase.State>.Publisher { $state }
    
    
    var callAsFunctionCalled = false
    var callAsFunctionCalledAttempt = 0
    func callAsFunction() {
        callAsFunctionCalled = true
        callAsFunctionCalledAttempt += 1
    }
    
    
}
