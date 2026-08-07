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
        let provider = PIACSITunnelLogInformationProvider(log: "anything", redactIPs: false)
        #expect(provider.sectionName == "tunnel.log")
    }

    @Test("Missing log yields a placeholder", arguments: [nil, ""] as [String?])
    func missingLog(log: String?) {
        let provider = PIACSITunnelLogInformationProvider(log: log, redactIPs: false)
        #expect(provider.content == Self.placeholder, "an empty section is ambiguous for support")
    }

    @Test("A populated log is passed through untouched")
    func populatedLogIsUntouched() {
        let log = "first\nsecond\nthird"
        let provider = PIACSITunnelLogInformationProvider(log: log, redactIPs: false)
        #expect(provider.content == log)
    }

    @Test("IPv4 addresses are redacted when requested")
    func redactsIPs() {
        let log = "handshake with 10.0.12.34:1337 completed"
        let provider = PIACSITunnelLogInformationProvider(log: log, redactIPs: true)
        #expect(provider.content == "handshake with REDACTED:1337 completed")
    }

    @Test("IPv4 addresses are preserved when redaction is off")
    func preservesIPs() {
        let log = "handshake with 10.0.12.34:1337 completed"
        let provider = PIACSITunnelLogInformationProvider(log: log, redactIPs: false)
        #expect(provider.content == log)
    }
}
