//
//  ProtocolSelectionViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

@MainActor
class ProtocolSelectionViewModelTests: XCTestCase {
    @MainActor
    class ProtocolSelectionUseCaseMock: ProtocolSelectionUseCaseType {
        var availableProtocols: [KapePlatformSDKVPNType]
        var selected: KapePlatformSDKVPNType
        private(set) var selectedProtocolCalls: [KapePlatformSDKVPNType] = []

        init(
            available: [KapePlatformSDKVPNType] = [.automatic, .wireGuard, .openVPN],
            selected: KapePlatformSDKVPNType = .wireGuard
        ) {
            self.availableProtocols = available
            self.selected = selected
        }

        func selectedProtocol() -> KapePlatformSDKVPNType { selected }

        func select(_ vpnProtocol: KapePlatformSDKVPNType) {
            selectedProtocolCalls.append(vpnProtocol)
            selected = vpnProtocol
        }
    }

    @MainActor
    class Fixture {
        let useCaseMock = ProtocolSelectionUseCaseMock()
    }

    var fixture: Fixture!
    var sut: ProtocolSelectionViewModel!

    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    private func instantiateSut() {
        sut = ProtocolSelectionViewModel(useCase: fixture.useCaseMock)
    }

    func test_init_exposesAvailableProtocolsAndCurrentSelection() {
        // GIVEN the use case reports OpenVPN as the current protocol
        fixture.useCaseMock.selected = .openVPN

        // WHEN the view model is created
        instantiateSut()

        // THEN it exposes the selectable protocols and the current selection
        XCTAssertEqual(sut.availableProtocols, [.automatic, .wireGuard, .openVPN])
        XCTAssertEqual(sut.selectedProtocol, .openVPN)
        XCTAssertTrue(sut.isSelected(.openVPN))
        XCTAssertFalse(sut.isSelected(.wireGuard))
    }

    func test_select_forwardsToUseCaseAndUpdatesSelection() {
        // GIVEN WireGuard is currently selected
        fixture.useCaseMock.selected = .wireGuard
        instantiateSut()

        // WHEN the user selects OpenVPN
        sut.select(.openVPN)

        // THEN the use case is asked to apply it
        XCTAssertEqual(fixture.useCaseMock.selectedProtocolCalls, [.openVPN])
        // AND the published selection reflects the change
        XCTAssertEqual(sut.selectedProtocol, .openVPN)
        XCTAssertTrue(sut.isSelected(.openVPN))
    }

    func test_vpnTypeRawValues_matchTunnelProfileIdentifiers() {
        // The raw values must match the `vpnType` strings the PlatformSDK tunnel reads.
        XCTAssertEqual(KapePlatformSDKVPNType.wireGuard.rawValue, "PIAWG")
        XCTAssertEqual(KapePlatformSDKVPNType.openVPN.rawValue, "PIA")
    }
}
