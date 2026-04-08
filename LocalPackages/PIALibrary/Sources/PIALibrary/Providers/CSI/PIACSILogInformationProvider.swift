//
//  PIACSILogInformationProvider.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 18.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PIACSI

struct PIACSILogInformationProvider: CSIDataProvider {
    var sectionName: String { "application.log" }
    var content: String? { getApplicationLogs() }

    private func getApplicationLogs() -> String {
        #if os(tvOS)
        // Force includeDebug on tvOS since logs submission is only accessible for internal use
        let logs = PIALogHandler.logStorage.getAllLogs(includeDebug: true)
        #else
        let logs = PIALogHandler.logStorage.getAllLogs(includeDebug: Client.preferences.debugLogging)
        #endif
        return logs.isEmpty ? "No logs available" : logs.redactIPs()
    }
}
