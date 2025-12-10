//
//  PIACSIUserInformationProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 05.05.22.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import csi

@available(tvOS 17.0, *)
class PIACSIUserInformationProvider: ICSIProvider {
    
    var filename: String? { return "user_settings" }
    
    var isPersistedData: Bool { return true }
    
    var providerType: ProviderType { return ProviderType.userSettings }
    
    var reportType: ReportType { return ReportType.diagnostic }
    
    var value: String? { return getUserInformation() }
    
    func getUserInformation() -> String {
        var userSettings = ""
        guard let defaults = UserDefaults(suiteName: Client.Configuration.appGroup) else {
            return userSettings
        }
        let filteredPreferences = WhitelistUtil.filter(preferences: defaults.dictionaryRepresentation())
        return filteredPreferences.map{ "\($0): \($1)" }.joined(separator: "\n").redactIPs()
    }
}
