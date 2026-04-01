//
//  ValidateLoginQRCodeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class ValidateLoginQRCodeMock: ValidateLoginQRCodeUseCaseType {
    private let error: ClientError?
    
    init(error: ClientError?) {
        self.error = error
    }
    
    func callAsFunction(qrCodeToken: LoginQRCode) async throws {
        guard let error = error else { return }
        throw error
    }
}
