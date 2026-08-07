//
//  AvailableSettingsViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest

@testable import PIA_VPN_tvOS

class AvailableSettingsViewModelTests: XCTestCase {
    private func makeSut(usePlatformSDKVPN: Bool) -> AvailableSettingsViewModel {
        let action = AppRouter.Actions.goBackToRoot(router: AppRouterSpy())
        return AvailableSettingsViewModel(
            onAccountSelectedAction: action,
            onDedicatedIpSectionSelectedAction: action,
            onProtocolSectionSelectedAction: action,
            usePlatformSDKVPN: usePlatformSDKVPN)
    }

    func test_sections_includesProtocols_whenPlatformSDKVPNEnabled() {
        // WHEN the PlatformSDK tunnel is enabled (WireGuard / OpenVPN are selectable)
        let sut = makeSut(usePlatformSDKVPN: true)

        // THEN the Protocols section is offered alongside Account and Dedicated IP
        XCTAssertEqual(sut.sections, [.account, .protocols, .dedicatedIp])
    }

    func test_sections_hidesProtocols_whenPlatformSDKVPNDisabled() {
        // WHEN VPN falls back to the legacy IKEv2 profile (no protocol choice)
        let sut = makeSut(usePlatformSDKVPN: false)

        // THEN the Protocols section is hidden
        XCTAssertEqual(sut.sections, [.account, .dedicatedIp])
        XCTAssertFalse(sut.sections.contains(.protocols))
    }
}
