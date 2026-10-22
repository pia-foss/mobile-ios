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

    func connectivityCheck() async -> Result<ConnectivityStatus, Error> {
        do {
            let information = try await nativeAccountAPI.geo(requestTimeoutMillis: 3_000)
            return .success(
                ConnectivityStatus(
                    ipAddress: information.ip,
                    countryCode: information.countryCode,
                    isVPN: information.usingPIAServer ?? false
                )
            )
        } catch {
            return .failure(error)
        }
    }

    func submitDebugReport() async throws -> String {
        try await submitDebugReport(
            includeDebug: Client.preferences.debugLogging,
            redactIPs: true,
            includeTunnelLog: true
        )
    }

    func submitDebugReport(
        includeDebug: Bool,
        redactIPs: Bool,
        includeTunnelLog: Bool = false,
        vpnConnection: VPNConnectionInformation? = nil
    ) async throws -> String {
        let report = await buildDebugReport(
            includeDebug: includeDebug,
            redactIPs: redactIPs,
            includeTunnelLog: includeTunnelLog,
            vpnConnection: vpnConnection
        )
        return try await submit(report: report)
    }

    /// Builds the report that would be submitted, without sending it, so a review screen can show
    /// exactly what is about to leave the device.
    func buildDebugReport(
        includeDebug: Bool,
        redactIPs: Bool,
        includeTunnelLog: Bool = false,
        vpnConnection: VPNConnectionInformation? = nil
    ) async -> DebugReport {
        await DebugReportBuilder.build(
            includeDebug: includeDebug,
            redactIPs: redactIPs,
            includeTunnelLog: includeTunnelLog,
            vpnConnection: vpnConnection
        )
    }

    /// Submits a report that has already been built (and possibly reviewed).
    func submit(report: DebugReport) async throws -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        do {
            return try await csiClient.submit(
                data: report.text,
                team: Client.Configuration.teamIdentifierCSI,
                appVersion: "\(appVersion) (\(appBuild))"
            )
        } catch {
            log.error("CSI submission failed: \(error)")
            throw ClientError.internetUnreachable
        }
    }
}
