//
//  Client+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 3/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol ClientType {
    func ping(servers: [ServerType])
}

final class ClientAdapter: ClientType {
    func ping(servers: [ServerType]) {
        guard let serversToPing = servers as? [Server] else { return }
        Client.ping(servers: serversToPing)
    }
}



