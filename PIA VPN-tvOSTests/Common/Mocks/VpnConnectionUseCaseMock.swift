//
//  VpnConnectionUseCaseTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/14/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import Combine

class VpnConnectionUseCaseMock: VpnConnectionUseCaseType {
    
    var getConnectionIntentCalled = false
    var getConnectionIntentCalledAttempt = 0
    var getConnectionIntentResult = CurrentValueSubject<VpnConnectionIntent, Error>(VpnConnectionIntent.none)
    func getConnectionIntent() -> AnyPublisher<PIA_VPN_tvOS.VpnConnectionIntent, Error> {
        return getConnectionIntentResult.eraseToAnyPublisher()
    }
    
    var connectionAction: (() -> Void)?
    var connectCalled: Bool = false
    var connectCalledAttempt: Int = 0
    
    func connect() {
        connectCalled = true
        connectCalledAttempt += 1
        connectionAction?()
    }
    
    var disconnectCalled: Bool = false
    var disconnectCalledAttempt: Int = 0
    var disconnectionAction: (() -> Void)?
    
    func disconnect() {
        disconnectCalled = true
        disconnectCalledAttempt += 1
        disconnectionAction?()
    }
    
    
}
