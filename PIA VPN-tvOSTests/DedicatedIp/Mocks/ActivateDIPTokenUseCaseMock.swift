//
//  ActivateDIPTokenUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 20/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

final class ActivateDIPTokenUseCaseMock: ActivateDIPTokenUseCaseType {
    var error: Error?

    func callAsFunction(token: String) async -> Result<Void, DedicatedIPError> {
        switch error {
        case let error as DedicatedIPError:
            return .failure(error)
        case let .some(error):
            return .failure(.generic(error))
        case .none:
            return .success(())
        }
    }
}
