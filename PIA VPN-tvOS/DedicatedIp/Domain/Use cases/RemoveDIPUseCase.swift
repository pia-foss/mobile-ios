//
//  RemoveDIPUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol RemoveDIPUseCaseType {
    func callAsFunction()
}

class RemoveDIPUseCase: RemoveDIPUseCaseType {
    private let serverProvider: ServerProviderType
    private let dedicatedIpProvider: DedicatedIPProviderType
    
    init(serverProvider: ServerProviderType, dedicatedIpProvider: DedicatedIPProviderType) {
        self.serverProvider = serverProvider
        self.dedicatedIpProvider = dedicatedIpProvider
    }
    
    func callAsFunction() {
        guard let dipToken = dedicatedIpProvider.getDIPTokens().first else { return }
        dedicatedIpProvider.removeDIPToken(dipToken)
    }
}
