//
//  PIAWebServices+Ephemeral.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

private let log = PIALogger.logger(for: PIAWebServices.self)

extension PIAWebServices {

    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) {
        Task { @MainActor in
            do {
                let information = try await nativeAccountAPI.clientStatus(requestTimeoutMillis: 10000)
                callback?(ConnectivityStatus(ipAddress: information.ip, isVPN: information.connected), nil)
            } catch {
                callback?(nil, error)
            }
        }
    }
    
    func submitDebugReport() async throws -> String {
        let providers: [CSIDataProvider] = [
            PIACSIProtocolInformationProvider(),
            PIACSIDeviceInformationProvider(),
            PIACSILogInformationProvider(),
            PIACSISubscriptionInformationProvider(),
            PIACSIRegionInformationProvider(),
            PIACSIUserInformationProvider(),
            PIACSILastKnownExceptionProvider(),
        ]

        let sections = providers.compactMap { provider -> CSIReportSection? in
            guard let content = provider.content else { return nil }
            return CSIReportSection(name: provider.sectionName, content: content)
        }
        let reportData = CSIReportBuilder.build(sections: sections)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        do {
            return try await csiClient.submit(
                data: reportData,
                team: Client.Configuration.teamIdentifierCSI,
                appVersion: "\(appVersion) (\(appBuild))"
            )
        } catch {
            log.error("CSI submission failed: \(error)")
            throw ClientError.internetUnreachable
        }
    }
}
