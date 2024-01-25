//
//  InstallVPNConfigurationUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/12/23.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class InstallVPNConfigurationUseCaseMock: InstallVPNConfigurationUseCaseType {
    private let error: InstallVPNConfigurationError?
    var onSuccessAction: (() -> Void)?
    
    init(error: InstallVPNConfigurationError?, onSuccessAction: (() -> Void)? = nil) {
        self.error = error
        self.onSuccessAction = onSuccessAction
    }
    
    func callAsFunction() async throws {
        guard let error = error else {
            onSuccessAction?()
            return
        }
        
        throw error
    }
}
