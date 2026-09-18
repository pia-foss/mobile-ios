//
//  DipServerProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

@testable import PIA_VPN_tvOS

final class DipServerProviderMock: DipServerProviderType {
    private let server: Server?
    private let error: ClientError?

    init(server: Server?, error: ClientError?) {
        self.server = server
        self.error = error
    }

    func activateDIPToken(_ token: String, _ callback: @escaping ClientCallback<Server>) {
        if let error {
            callback(.failure(error))
        } else if let server {
            callback(.success(server))
        } else {
            precondition(false)
        }
    }

    func removeDIPToken(_ dipToken: String) {}
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {}
    func getDIPTokens() -> [String] { [] }
}
