//
//  InstallVPNConfigurationUseCaseMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/12/23.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class InstallVPNConfigurationUseCaseMock: InstallVPNConfigurationUseCaseType {
    private let error: InstallVPNConfigurationError?
    
    init(error: InstallVPNConfigurationError?) {
        self.error = error
    }
    
    func callAsFunction() async throws {
        guard let error = error else {
            return
        }
        
        throw error
    }
}
