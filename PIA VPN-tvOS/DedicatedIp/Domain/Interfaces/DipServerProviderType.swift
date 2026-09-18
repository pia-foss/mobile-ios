//
//  DedicatedIPProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol DedicatedIPProviderType: Sendable {
    func activateDIPToken(_ token: String, completion: @escaping (Result<ServerType, DedicatedIPError>) -> Void)
    func removeDIPToken(_ token: String)
    func renewDIPToken(_ token: String)
    func getDIPTokens() -> [String]
}
