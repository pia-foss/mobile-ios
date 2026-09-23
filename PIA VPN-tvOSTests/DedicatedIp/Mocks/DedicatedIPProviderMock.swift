//
//  DipServerProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

@testable import PIA_VPN_tvOS

final class DedicatedIPProviderMock: DedicatedIPProviderType {
    enum Request {
        case activateDIPToken
        case removeDIPToken
        case renewDIPToken
        case getDIPTokens
    }

    private let result: Result<ServerType, DedicatedIPError>
    var requests: [Request] = []

    init(result: Result<ServerType, DedicatedIPError>) {
        self.result = result
    }

    func activateDIPToken(_ token: String, completion: @escaping (Result<ServerType, DedicatedIPError>) -> Void) {
        requests.append(.activateDIPToken)
        completion(result)
    }

    func removeDIPToken(_ token: String) { requests.append(.removeDIPToken) }
    func renewDIPToken(_ token: String) { requests.append(.renewDIPToken) }

    func getDIPTokens() -> [String] {
        requests.append(.getDIPTokens)
        return []
    }
}
