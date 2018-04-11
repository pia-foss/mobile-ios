//
//  ServerProvider+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension Client.Preferences {

    // treat nil preferredServer as automatic (app defined)
    var displayedServer: Server {
        get {
            return preferredServer ?? .automatic
        }
        set {
            let ed = editable()
            if newValue.isAutomatic {
                ed.preferredServer = nil
            } else {
                ed.preferredServer = newValue
            }
            let action = ed.requiredVPNAction()
            ed.commit()

            action?.execute { (error) in
                let vpn = Client.providers.vpnProvider
                if (vpn.vpnStatus != .disconnected) {
                    vpn.reconnect(after: nil, nil)
                }
            }
        }
    }
}
