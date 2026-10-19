//
//  HasActiveSubscriptionUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

@testable import PIA_VPN_tvOS

final class HasActiveSubscriptionUseCaseMock: HasActiveSubscriptionUseCaseType {
    private let result: Bool

    init(result: Bool) {
        self.result = result
    }

    func callAsFunction() async -> Bool {
        result
    }
}
