//
//  DipServerProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS
import PIALibrary

class DipServerProviderMock: DipServerProviderType {
    private let server: Server?
    private let error: Error?
    
    init(server: Server?, error: Error?) {
        self.server = server
        self.error = error
    }
    
    func activateDIPToken(_ token: String, _ callback: LibraryCallback<Server?>?) {
        callback?(server, error)
    }
    
    func removeDIPToken(_ dipToken: String) {}
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {}
    func getDIPTokens() -> [String] { [] }
}
