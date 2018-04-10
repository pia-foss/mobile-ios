//
//  GlossConnectivityStatus.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

class GlossConnectivityStatus: GlossParser {
    var parsed: ConnectivityStatus
    
    required init?(json: JSON) {
        guard let ipAddress: String = "ip" <~~ json else {
            return nil
        }
        guard let isVPN: Bool = "connected" <~~ json else {
            return nil
        }
        parsed = ConnectivityStatus(ipAddress: ipAddress, isVPN: isVPN)
    }
}
