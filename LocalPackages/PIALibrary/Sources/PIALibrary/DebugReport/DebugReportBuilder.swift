//
//  DebugReportBuilder.swift
//  PIALibrary
//
//  Copyright © 2026 Private Internet Access, Inc.
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

/// Assembles the sections that make up a `DebugReport`.
///
/// Shared by submission and the review screen, so the report that is previewed is the report that
/// is sent. Each section is tagged with its `DebugReport.SectionKind` so a review screen can drive
/// its include/exclude toggles.
enum DebugReportBuilder {

    /// Pairs a data provider with the category it belongs to.
    ///
    /// `assemble` only needs the section name, content and kind, so a plain value keeps the
    /// mapping testable without a live `CSIDataProvider`.
    struct Component {
        let sectionName: String
        let content: String?
        let kind: DebugReport.SectionKind

        init(sectionName: String, content: String?, kind: DebugReport.SectionKind) {
            self.sectionName = sectionName
            self.content = content
            self.kind = kind
        }

        init(_ provider: any CSIDataProvider, _ kind: DebugReport.SectionKind) {
            self.init(sectionName: provider.sectionName, content: provider.content, kind: kind)
        }
    }

    static func build(
        includeDebug: Bool,
        redactIPs: Bool,
        includeTunnelLog: Bool,
        vpnConnection: VPNConnectionInformation?
    ) async -> DebugReport {
        var components: [Component] = [
            Component(PIACSIProtocolInformationProvider(), .mandatory),
            Component(PIACSIDeviceInformationProvider(), .mandatory),
            Component(PIACSILogInformationProvider(includeDebug: includeDebug, redactIPs: redactIPs), .debugLog),
            Component(PIACSISubscriptionInformationProvider(), .mandatory),
            Component(PIACSIRegionInformationProvider(redactIPs: redactIPs), .mandatory),
            Component(PIACSIUserInformationProvider(redactIPs: redactIPs), .mandatory),
            Component(PIACSILastKnownExceptionProvider(), .mandatory)
        ]

        if includeTunnelLog {
            components.append(Component(await tunnelLogProvider(includeDebug: includeDebug, redactIPs: redactIPs), .tunnelLog))
        }

        if let vpnConnection {
            components.append(
                Component(
                    PIACSIVPNStatusInformationProvider(connection: vpnConnection, redactIPs: redactIPs),
                    .mandatory
                )
            )
        }

        return assemble(components)
    }

    /// Pure: turns components into sections, dropping any provider that produced no content.
    static func assemble(_ components: [Component]) -> DebugReport {
        let sections = components.compactMap { component -> DebugReport.Section? in
            guard let content = component.content else { return nil }
            return DebugReport.Section(
                id: component.sectionName,
                name: component.sectionName,
                content: content,
                kind: component.kind
            )
        }
        return DebugReport(sections: sections)
    }

    /// The running tunnel's log when it answers, otherwise the copy it persisted last — the tunnel
    /// is usually down when a user reports a failed connection, and its in-memory log went with it.
    ///
    /// Decided by the VPN status, not by whether the extension replies: iOS keeps the provider
    /// process around after a disconnect, or relaunches it to deliver the message, so a stopped
    /// tunnel still answers — and asking it would only append a restore marker and the request to
    /// its log.
    private static func tunnelLogProvider(
        includeDebug: Bool,
        redactIPs: Bool
    ) async -> PIACSITunnelLogInformationProvider {
        let vpnProvider = Client.providers.vpnProvider
        let isTunnelUp: Bool
        switch vpnProvider.vpnStatus {
        case .connecting, .connected, .disconnecting: isTunnelUp = true
        case .disconnected, .unknown: isTunnelUp = false
        }

        if isTunnelUp, let live = await vpnProvider.tunnelLog(), !live.isEmpty {
            return PIACSITunnelLogInformationProvider(log: live, includeDebug: includeDebug, redactIPs: redactIPs)
        }

        return PIACSITunnelLogInformationProvider(
            sectionName: PIACSITunnelLogInformationProvider.lastSessionSectionName,
            log: PIATunnelSharedState.readLastTunnelLog(),
            includeDebug: includeDebug,
            redactIPs: redactIPs
        )
    }
}
