//
//  PurchaseProductUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class PurchaseProductUseCaseMock: PurchaseProductUseCaseType {
    func callAsFunction(productId: String) async throws {}
}
