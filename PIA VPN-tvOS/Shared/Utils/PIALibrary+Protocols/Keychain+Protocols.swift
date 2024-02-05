//
//  Keychain+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol KeychainType {
   func getFavorites() throws -> [String]
    func set(favorites: [String]) throws
    
    // Add methods from `Keychain` class as needed
}


extension Keychain: KeychainType {}
