//
//  DipServerProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class DedicatedIPProviderMock: DedicatedIPProviderType {
    private let result: Result<Void, DedicatedIPError>
    
    init(result: Result<Void, DedicatedIPError>) {
        self.result = result
    }
    
    func activateDIPToken(_ token: String, completion: @escaping (Result<Void, DedicatedIPError>) -> Void) {
        completion(result)
    }
    
    func removeDIPToken(_ token: String) {}
    func renewDIPToken(_ token: String) {}
    func getDIPTokens() -> [String] { [] }
}
