//
//  ProtocolSelectionViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import XCTest

@testable import PIA_VPN_tvOS

class ProtocolSelectionViewModelTests: XCTestCase {
    class ProtocolSelectionUseCaseMock: ProtocolSelectionUseCaseType {
        var availableProtocols: [TvOSVPNProtocol]
        var selected: TvOSVPNProtocol
        private(set) var selectedProtocolCalls: [TvOSVPNProtocol] = []

        init(available: [TvOSVPNProtocol] = TvOSVPNProtocol.allCases, selected: TvOSVPNProtocol = .wireGuard) {
            self.availableProtocols = available
            self.selected = selected
        }

        func selectedProtocol() -> TvOSVPNProtocol { selected }

        func select(_ vpnProtocol: TvOSVPNProtocol) {
            selectedProtocolCalls.append(vpnProtocol)
            selected = vpnProtocol
        }
    }

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

        // THEN it exposes both protocols and the current selection
        XCTAssertEqual(sut.availableProtocols, [.wireGuard, .openVPN])
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
        XCTAssertEqual(TvOSVPNProtocol.wireGuard.rawValue, "PIAWG")
        XCTAssertEqual(TvOSVPNProtocol.openVPN.rawValue, "PIA")
    }
}
