//
//  SelectableVPNProtocolTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

class SelectableVPNProtocolTests: XCTestCase {

    func test_all_offersAutomaticWireGuardAndOpenVPN() {
        // The PlatformSDK tunnel runs these three on tvOS; IKEv2 is not connectable here.
        XCTAssertEqual(SelectableVPNProtocol.all, [.automatic, .wireGuard, .openVPN])
        XCTAssertFalse(SelectableVPNProtocol.all.contains(.iKEv2))
    }

    // MARK: resolved(fromStored:)

    func test_resolved_keepsASelectableStoredProtocol() {
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "PIAAutomatic"), .automatic)
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "PIAWG"), .wireGuard)
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "PIA"), .openVPN)
    }

    func test_resolved_mapsLegacyIKEv2ToAutomatic() {
        // GIVEN a pre-PlatformSDK install that persisted the legacy IKEv2 protocol
        // THEN the Protocol screen shows Automatic rather than an unselectable entry
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "IKEv2"), .automatic)
    }

    func test_resolved_mapsUnknownValuesToAutomatic() {
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: ""), .automatic)
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "IPsec"), .automatic)
        XCTAssertEqual(SelectableVPNProtocol.resolved(fromStored: "something-from-a-newer-build"), .automatic)
    }

    func test_storedRawValues_matchWhatTheTunnelReads() {
        // These strings are persisted in `Client.preferences.vpnType` and read by the PlatformSDK
        // tunnel; changing them would silently strand existing installs.
        XCTAssertEqual(KapePlatformSDKVPNType.automatic.rawValue, "PIAAutomatic")
        XCTAssertEqual(KapePlatformSDKVPNType.wireGuard.rawValue, "PIAWG")
        XCTAssertEqual(KapePlatformSDKVPNType.openVPN.rawValue, "PIA")
        XCTAssertEqual(KapePlatformSDKVPNType.iKEv2.rawValue, "IKEv2")
    }
}
