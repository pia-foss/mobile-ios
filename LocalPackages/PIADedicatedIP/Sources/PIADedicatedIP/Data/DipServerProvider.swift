//
//  DipServerProvider.swift
//  PIADedicatedIP
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

public protocol DipServerProviderType: Sendable {
    func activateDIPToken(_ token: String, _ callback: @escaping ClientCallback<Server>)
    func removeDIPToken(_ dipToken: String)
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?)
    func getDIPTokens() -> [String]
}

extension DefaultServerProvider: DipServerProviderType {
    public func getDIPTokens() -> [String] {
        dipTokens ?? []
    }
}
