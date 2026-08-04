//
//  CancelQRLoginUseCase.swift
//  PIA VPN
//
//  Created by Mario on 03/07/26.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol CancelQRLoginUseCaseType {
    func callAsFunction()
}

final class CancelQRLoginUseCase: CancelQRLoginUseCaseType {
    private let tokenProvider: TokenProvider

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    func callAsFunction() {
        tokenProvider.removeTVOSToken()
    }
}
