//
//  VPNStatusMonitorMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 22/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import PIALibrary
@testable import PIA_VPN_tvOS

class VPNStatusMonitorMock: VPNStatusMonitorType {
    var status = PassthroughSubject<VPNStatus, Never>()
    
    func getStatus() -> AnyPublisher<VPNStatus, Never> {
        return status.eraseToAnyPublisher()
    }
}
