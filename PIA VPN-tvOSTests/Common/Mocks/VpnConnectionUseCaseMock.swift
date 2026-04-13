//
//  VpnConnectionUseCaseTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/14/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIADashboard

@testable import PIA_VPN_tvOS

class VpnConnectionUseCaseMock: VpnConnectionUseCaseType {

    var getConnectionIntentCalled = false
    var getConnectionIntentCalledAttempt = 0
    var getConnectionIntentResult = CurrentValueSubject<VpnConnectionIntent, Error>(VpnConnectionIntent.none)
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Error> {
        return getConnectionIntentResult.eraseToAnyPublisher()
    }

    var connectionAction: (() -> Void)?
    var connectCalled: Bool = false
    var connectCalledAttempt: Int = 0
    var connectError: Error?

    func connect() throws {
        connectCalled = true
        connectCalledAttempt += 1
        if let error = connectError { throw error }
        connectionAction?()
    }

    var disconnectCalled: Bool = false
    var disconnectCalledAttempt: Int = 0
    var disconnectionAction: (() -> Void)?
    var disconnectError: Error?

    func disconnect() throws {
        disconnectCalled = true
        disconnectCalledAttempt += 1
        if let error = disconnectError { throw error }
        disconnectionAction?()
    }

}
