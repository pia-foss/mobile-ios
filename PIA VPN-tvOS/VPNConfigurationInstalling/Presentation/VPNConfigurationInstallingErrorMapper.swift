//
//  VPNConfigurationInstallingErrorMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALocalizations

class VPNConfigurationInstallingErrorMapper {
    func map(error: Error) -> String? {
        guard let error = error as? InstallVPNConfigurationError else {
            return nil
        }

        switch error {
        case .userCanceled:
            return L10n.VpnPermission.Disallow.Message.basic
        default:
            return nil
        }
    }
}
