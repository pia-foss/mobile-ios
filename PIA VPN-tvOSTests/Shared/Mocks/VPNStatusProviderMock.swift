//
//  VPNStatusProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 21/1/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class VPNStatusProviderMock: VPNStatusProviderType {

    var vpnStatus: VPNStatus
    
    init(vpnStatus: VPNStatus) {
        self.vpnStatus = vpnStatus
    }
    
    func changeStatus(vpnStatus: VPNStatus) {
        self.vpnStatus = vpnStatus
    }
    
    var connectCalled = false
    var connectCalledAttempt = 0
    var connectCalledWithCallbackError: Error?
    func connect(_ callback: SuccessLibraryCallback?) {
        
        connectCalled = true
        connectCalledAttempt += 1
        callback?(connectCalledWithCallbackError)
    }
    
    var disconnectCalled = false
    var disconnectCalledAttempt = 0
    var disconnectCalledWithCallbackError: Error?
    func disconnect(_ callback: SuccessLibraryCallback?) {
        
        disconnectCalled = true
        disconnectCalledAttempt += 1
        callback?(disconnectCalledWithCallbackError)
    }
    
}
