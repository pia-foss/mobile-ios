//
//  GetDedicatedIpUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 20/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class GetDedicatedIpUseCaseMock: GetDedicatedIpUseCaseType {
    private let result: ServerType?
    
    init(result: ServerType?) {
        self.result = result
    }
    
    func callAsFunction() -> ServerType? {
        result
    }
}
