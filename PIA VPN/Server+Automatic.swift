//
//  Server+Automatic.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/15/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension Server {
    static let automatic = Server(
        name: L10n.Global.automatic,
        country: "universal",
        hostname: "auto.bogus.domain",
        bestOpenVPNAddressForTCP: nil,
        bestOpenVPNAddressForUDP: nil,
        pingAddress: nil
    )
    
    var isAutomatic: Bool {
        return (identifier == Server.automatic.identifier)
    }
}
