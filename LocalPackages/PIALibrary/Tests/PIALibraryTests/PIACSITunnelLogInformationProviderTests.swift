//
//  PIACSITunnelLogInformationProviderTests.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 07.08.26.
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Testing

@testable import PIALibrary

@Suite("PIACSITunnelLogInformationProvider Tests")
struct PIACSITunnelLogInformationProviderTests {

    private static let placeholder = "No tunnel logs available"

    @Test("Section name matches the CSI report contract")
    func sectionName() {
        let provider = PIACSITunnelLogInformationProvider(log: "anything", includeDebug: true, redactIPs: false)
        #expect(provider.sectionName == "tunnel.log")
    }

    @Test("The persisted fallback is reported under its own section")
    func lastSessionSectionName() {
        let provider = PIACSITunnelLogInformationProvider(
            sectionName: PIACSITunnelLogInformationProvider.lastSessionSectionName,
            log: "anything",
            includeDebug: true,
            redactIPs: false
        )
        #expect(provider.sectionName == "last_tunnel.log", "support must tell a live log from a stale one")
    }

    @Test("Missing log yields a placeholder", arguments: [nil, ""] as [String?])
    func missingLog(log: String?) {
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: true, redactIPs: false)
        #expect(provider.content == Self.placeholder, "an empty section is ambiguous for support")
    }

    @Test("A populated log is passed through untouched")
    func populatedLogIsUntouched() {
        let log = "first\nsecond\nthird"
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: true, redactIPs: false)
        #expect(provider.content == log)
    }

    @Test("IPv4 addresses are redacted when requested")
    func redactsIPs() {
        let log = "handshake with 10.0.12.34:1337 completed"
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: true, redactIPs: true)
        #expect(provider.content == "handshake with REDACTED:1337 completed")
    }

    @Test("IPv4 addresses are preserved when redaction is off")
    func preservesIPs() {
        let log = "handshake with 10.0.12.34:1337 completed"
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: true, redactIPs: false)
        #expect(provider.content == log)
    }

    private static let mixedLevelLog = """
        2026-10-14T09:00:00Z [INFO] Session: connecting
        2026-10-14T09:00:01Z [DEBUG] Endpoints: built 3 endpoints
        2026-10-14T09:00:01Z [TRACE] OpenVPN: packet
        2026-10-14T09:00:02Z [WARNING] DNS: lookup failed
        2026-10-14T09:00:03Z [ERROR] Session: authentication failed
        """

    @Test("Debug and trace entries are kept when debug logging is on")
    func keepsDebugEntries() {
        let provider = PIACSITunnelLogInformationProvider(
            log: Self.mixedLevelLog,
            includeDebug: true,
            redactIPs: false
        )
        #expect(provider.content == Self.mixedLevelLog)
    }

    @Test("Debug and trace entries are dropped when debug logging is off")
    func dropsDebugEntries() {
        let provider = PIACSITunnelLogInformationProvider(
            log: Self.mixedLevelLog,
            includeDebug: false,
            redactIPs: false
        )
        #expect(
            provider.content == """
                2026-10-14T09:00:00Z [INFO] Session: connecting
                2026-10-14T09:00:02Z [WARNING] DNS: lookup failed
                2026-10-14T09:00:03Z [ERROR] Session: authentication failed
                """
        )
    }

    @Test("A multi-line entry is kept or dropped as a whole")
    func multiLineEntriesFollowTheirLevel() {
        let log = """
            2026-10-14T09:00:00Z [DEBUG] Config: endpoint
            remote 10.0.0.1 1194
            2026-10-14T09:00:01Z [INFO] Session: connected
            tunnel is up
            """
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: false, redactIPs: false)
        #expect(
            provider.content == """
                2026-10-14T09:00:01Z [INFO] Session: connected
                tunnel is up
                """
        )
    }

    @Test("The restore marker and unprefixed lines survive the filter")
    func keepsUnprefixedLines() {
        let log = """
            restored line without prefix
            2026-10-14T09:00:00Z [INFO] PIATunnelLogStore: new tunnel process
            """
        let provider = PIACSITunnelLogInformationProvider(log: log, includeDebug: false, redactIPs: false)
        #expect(provider.content == log)
    }
}
