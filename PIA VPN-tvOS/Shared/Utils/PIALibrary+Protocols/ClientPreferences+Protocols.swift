//
//  ClientPreferences+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/18/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol ClientPreferencesType {
    var selectedServer: ServerType { get set }
}

extension Client.Preferences: ClientPreferencesType {
    var selectedServer: ServerType {
        get {
            return displayedServer
        }
        set {
            guard let newServer = newValue as? Server else { return }
            displayedServer = newServer
            // TODO: Verify whether this is necessary
            let pendingPreferences = Client.preferences.editable()
            pendingPreferences.commit()
        }
    }
    
}


protocol ClientType {
    func ping(servers: [ServerType])
}

class ClientTypeImpl: ClientType {
    func ping(servers: [ServerType]) {
        guard let castedServers = servers as? [Server] else { return }
        Client.ping(servers: castedServers)
    }
}

extension Client: ClientType {
    func ping(servers: [ServerType]) {
        guard let castedServers = servers as? [Server] else { return }
        Client.ping(servers: castedServers)
    }
}
