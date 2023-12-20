//
//  VPNConfigurationInstallingStatus.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 28/12/23.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum VPNConfigurationInstallingStatus {
    case none
    case isInstalling
    case failed(errorMessage: String?)
    case succeeded
}

extension VPNConfigurationInstallingStatus: Equatable {
    public static func == (lhs: VPNConfigurationInstallingStatus, rhs: VPNConfigurationInstallingStatus) -> Bool {
        switch (lhs, rhs) {
            case (.none, .none), (.isInstalling, .isInstalling), (.succeeded, .succeeded):
                return true
            case let (.failed(lhsErrorMessage), .failed(rhsErrorMessage)):
                return lhsErrorMessage == rhsErrorMessage
            default:
                return false
        }
    }
}
