//
//  PIACSIUserInformationProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 05.05.22.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACSI

struct PIACSIUserInformationProvider: CSIDataProvider {
    var sectionName: String { "user_settings" }
    var content: String? { getUserInformation() }

    private func getUserInformation() -> String {
        guard let defaults = UserDefaults(suiteName: Client.Configuration.appGroup) else {
            return ""
        }

        let filteredPreferences = WhitelistUtil.filter(preferences: defaults.dictionaryRepresentation())
        return filteredPreferences.map { "\($0): \($1)" }.joined(separator: "\n").redactIPs()
    }
}
