//
//  ValidateLoginQRCodeProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 14/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class ValidateLoginQRCodeProviderMock: ValidateLoginQRCodeProviderType {
    private let result: Result<UserToken, LoginQRCodeError>
    
    init(result: Result<UserToken, LoginQRCodeError>) {
        self.result = result
    }
    
    func validateLoginQRCodeToken(_ qrCodeToken: LoginQRCode) async throws -> UserToken {
        switch result {
            case .success(let user):
                return user
            case .failure(let error):
                throw error
        }
    }
}
