//
//  RemoveDIPUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 20/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

final class RemoveDIPUseCaseMock: RemoveDIPUseCaseType {
    var useCaseWasCalled = 0
    
    func callAsFunction() async -> Result<Void, DedicatedIPError> {
        useCaseWasCalled += 1
        return .success(())
    }
}
