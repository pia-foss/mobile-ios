//
//  ClientPreferences+Protocols.swift
//  PIALibrary
//
//  Created by Mario on 24/03/2026.
//  Copyright © 2026 Private Internet Access, Inc.
//

import Combine
import Foundation

public protocol ClientPreferencesType {
    var selectedServer: ServerType { get set }
    var lastConnectedServer: ServerType? { get set }
    func getSelectedServer() -> AnyPublisher<ServerType, Never>
}
