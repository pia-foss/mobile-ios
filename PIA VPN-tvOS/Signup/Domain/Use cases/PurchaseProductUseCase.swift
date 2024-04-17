//
//  PurchaseProductUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 8/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol PurchaseProductUseCaseType {
    func callAsFunction(productId: String) async throws
}

class PurchaseProductUseCase: PurchaseProductUseCaseType {
    func callAsFunction(productId: String) async throws {}
}
