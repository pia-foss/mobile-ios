//
//  ServerProvider+UI.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/11/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
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
            guard newValue != displayedServer else {
                connectToSelectedServerIfNeeded()
                return
            }
            let ed = editable()
            if newValue.isAutomatic {
                ed.preferredServer = nil
                ed.lastConnectedRegion = Client.providers.serverProvider.bestServer
            } else {
                ed.preferredServer = newValue
            }
            let action = ed.requiredVPNAction()
            ed.commit()

            action?.execute { [weak self] (error) in
                self?.connectToSelectedServerIfNeeded(shouldReconnect: true)
            }
        }
    }
    
    private func connectToSelectedServerIfNeeded(shouldReconnect: Bool = false) {
        let vpn = Client.providers.vpnProvider
        
        switch vpn.vpnStatus {
        case .disconnected:
            vpn.connect(nil)
        default:
            if shouldReconnect {
                vpn.reconnect(after: nil, forceDisconnect: true, nil)
            }
        }
    }
}
