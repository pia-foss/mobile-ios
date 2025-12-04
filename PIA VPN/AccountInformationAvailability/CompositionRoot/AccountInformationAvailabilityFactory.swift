//
//  AccountInformationAvailabilityFactory.swift
//  PIA VPN
//
//  Created by Laura S on 4/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class AccountInformationAvailabilityFactory {
    private static var accountInformationAvailabilityVerifierShared: AccountInformationAvailabilityVerifierType = {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Account provider is not the expected type")
        }
        
        return AccountInformationAvailabilityVerifier(accountProvider: defaultAccountProvider, notificationCenter: NotificationCenter.default, userDefaults: UserDefaults.standard)
    }()
    
    static func makeAccountInformationAvailabilityVerifier() -> AccountInformationAvailabilityVerifierType {
        return accountInformationAvailabilityVerifierShared
    }
}
