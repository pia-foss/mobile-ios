//
//  SwitchToAutomaticPromptViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

// Posts to the real NotificationCenter, which is synchronous and pins the actual signal name —
// NotificationCenterMock ignores the name it is asked for.
@MainActor
class SwitchToAutomaticPromptViewModelTests: XCTestCase {

    @MainActor
    class ProtocolSelectionUseCaseMock: ProtocolSelectionUseCaseType {
        var availableProtocols: [KapePlatformSDKVPNType] = [.automatic, .wireGuard, .openVPN]
        var selected: KapePlatformSDKVPNType
        private(set) var selectedProtocolCalls: [KapePlatformSDKVPNType] = []

        init(selected: KapePlatformSDKVPNType = .wireGuard) {
            self.selected = selected
        }

        func selectedProtocol() -> KapePlatformSDKVPNType { selected }

        func select(_ vpnProtocol: KapePlatformSDKVPNType) {
            selectedProtocolCalls.append(vpnProtocol)
            selected = vpnProtocol
        }
    }

    private var useCaseMock: ProtocolSelectionUseCaseMock!
    private var sut: SwitchToAutomaticPromptViewModel!

    override func tearDown() {
        useCaseMock = nil
        sut = nil
    }

    private func instantiateSut(selected: KapePlatformSDKVPNType = .wireGuard) {
        useCaseMock = ProtocolSelectionUseCaseMock(selected: selected)
        sut = SwitchToAutomaticPromptViewModel(protocolSelection: useCaseMock, nudgeHistory: { .init() })
        // The view seeds the live scene phase via `.onChange(initial: true)`; the VM starts
        // fail-closed, so mirror that startup state here.
        sut.sceneDidBecomeActive()
    }

    private func postSignal() {
        NotificationCenter.default.post(
            name: PIATunnelSignal.switchToAutomaticSuggested.notificationName, object: nil)
    }

    func testPresentsThePromptWhenPinnedToAProtocol() {
        instantiateSut()

        postSignal()

        XCTAssertTrue(sut.isPresented)
    }

    func testDoesNotPresentThePromptWhenAlreadyOnAutomatic() {
        instantiateSut(selected: .automatic)

        postSignal()

        XCTAssertFalse(sut.isPresented)
    }

    func testDoesNotPresentThePromptWhileBackgrounded() {
        instantiateSut()
        sut.sceneDidBecomeInactive()

        postSignal()

        XCTAssertFalse(sut.isPresented)
    }

    func testPresentsThePromptAfterReturningToTheForeground() {
        instantiateSut()
        sut.sceneDidBecomeInactive()
        sut.sceneDidBecomeActive()

        postSignal()

        XCTAssertTrue(sut.isPresented)
    }

    func testStaysPresentedWhenTheSignalRepeats() {
        instantiateSut()

        postSignal()
        postSignal()

        XCTAssertTrue(sut.isPresented)
    }

    func testAcceptingSelectsAutomatic() {
        instantiateSut()

        sut.switchToAutomaticWasTapped()

        XCTAssertEqual(useCaseMock.selectedProtocolCalls, [.automatic])
    }

    func testDismissingLeavesTheProtocolUnchanged() {
        instantiateSut()

        sut.promptWasDismissed()

        XCTAssertTrue(useCaseMock.selectedProtocolCalls.isEmpty)
    }
}
