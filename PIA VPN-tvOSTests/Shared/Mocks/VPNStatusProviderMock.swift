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
}
