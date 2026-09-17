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
    private func makeSut() -> AvailableSettingsViewModel {
        let action = AppRouter.Actions.goBackToRoot(router: AppRouterSpy())
        return AvailableSettingsViewModel(
            onAccountSelectedAction: action,
            onDedicatedIpSectionSelectedAction: action,
            onProtocolSectionSelectedAction: action)
    }

    func test_sections_offersProtocolSelection() {
        // WHEN the settings list is built (tvOS always runs the PlatformSDK tunnel, so WireGuard /
        // OpenVPN are always selectable)
        let sut = makeSut()

        // THEN the Protocols section is offered alongside Account and Dedicated IP
        XCTAssertEqual(sut.sections, [.account, .protocols, .dedicatedIp])
    }
}
