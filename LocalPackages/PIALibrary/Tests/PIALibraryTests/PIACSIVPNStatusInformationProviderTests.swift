//
//  PIACSIVPNStatusInformationProviderTests.swift
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

@Suite("PIACSIVPNStatusInformationProvider Tests")
struct PIACSIVPNStatusInformationProviderTests {

    private func makeProvider(
        status: String = "connected",
        connectedVia: String = "PIA",
        vpnType: String = "WireGuard",
        obfuscation: String? = "none",
        publicIP: String? = "10.0.12.34",
        vpnIP: String? = "10.9.8.7",
        redactIPs: Bool = false
    ) -> PIACSIVPNStatusInformationProvider {
        PIACSIVPNStatusInformationProvider(
            status: status,
            connectedVia: connectedVia,
            vpnType: vpnType,
            obfuscation: obfuscation,
            publicIP: publicIP,
            vpnIP: vpnIP,
            redactIPs: redactIPs
        )
    }

    @Test("An AmneziaWG connection is distinguishable from plain WireGuard")
    func reportsAmneziaObfuscation() {
        let content = makeProvider(obfuscation: "amnezia").content
        #expect(content?.contains("Obfuscation: amnezia") == true)
    }

    @Test("An unresolved obfuscation is reported as a placeholder")
    func missingObfuscation() {
        let content = makeProvider(obfuscation: nil).content
        #expect(content?.contains("Obfuscation: ---") == true)
    }

    @Test("Section name matches the CSI report contract")
    func sectionName() {
        #expect(makeProvider().sectionName == "vpn_status")
    }

    @Test("Every row of the debug menu VPN section is reported")
    func reportsAllRows() {
        let content = makeProvider().content
        #expect(
            content
                == "Status: connected\nConnected Via: PIA\nProtocol: WireGuard\nObfuscation: none\nPublic IP: 10.0.12.34\nVPN IP: 10.9.8.7"
        )
    }

    @Test("Unknown IPs are reported as placeholders")
    func missingIPs() {
        let content = makeProvider(publicIP: nil, vpnIP: nil).content
        #expect(
            content
                == "Status: connected\nConnected Via: PIA\nProtocol: WireGuard\nObfuscation: none\nPublic IP: ---\nVPN IP: ---")
    }

    @Test("IP addresses are redacted when requested")
    func redactsIPs() {
        let content = makeProvider(redactIPs: true).content
        #expect(
            content
                == "Status: connected\nConnected Via: PIA\nProtocol: WireGuard\nObfuscation: none\nPublic IP: REDACTED\nVPN IP: REDACTED"
        )
    }

    @Test("A tunnel owned by another app is reported while PIA reads as disconnected")
    func foreignTunnel() {
        let content = makeProvider(status: "disconnected", connectedVia: "Not PIA", vpnIP: nil).content
        #expect(
            content
                == "Status: disconnected\nConnected Via: Not PIA\nProtocol: WireGuard\nObfuscation: none\nPublic IP: 10.0.12.34\nVPN IP: ---"
        )
    }

    @Test("No tunnel at all falls back to the placeholder")
    func noTunnel() {
        let content = makeProvider(status: "disconnected", connectedVia: "---", vpnIP: nil).content
        #expect(
            content
                == "Status: disconnected\nConnected Via: ---\nProtocol: WireGuard\nObfuscation: none\nPublic IP: 10.0.12.34\nVPN IP: ---"
        )
    }
}
