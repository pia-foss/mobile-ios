//
//  ClientPreferences+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/18/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import Combine

protocol ClientPreferencesType {
    var selectedServer: ServerType { get set }
    func getSelectedServer() -> AnyPublisher<ServerType, Never>
}

class ClientPreferences: ClientPreferencesType {
    private let clientPrefs: Client.Preferences
    
    var selectedServer: ServerType {
        get {
            return clientPrefs.displayedServer
        }
        set {
            guard let newServer = newValue as? Server else { return }
            clientPrefs.displayedServer = newServer
            
            selectedServerPublisher.send(newServer)
            
            // TODO: Verify whether this is necessary
            let pendingPreferences = clientPrefs.editable()
            pendingPreferences.commit()
        }
    }
    
    private var selectedServerPublisher: CurrentValueSubject<ServerType, Never>
    
    func getSelectedServer() -> AnyPublisher<ServerType, Never> {
        return selectedServerPublisher.eraseToAnyPublisher()
    }
    
    init(clientPrefs: Client.Preferences) {
        self.clientPrefs = clientPrefs
        self.selectedServerPublisher = CurrentValueSubject(clientPrefs.displayedServer)
    }
    
}

