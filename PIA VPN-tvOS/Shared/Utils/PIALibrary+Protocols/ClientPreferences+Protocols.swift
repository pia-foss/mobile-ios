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
