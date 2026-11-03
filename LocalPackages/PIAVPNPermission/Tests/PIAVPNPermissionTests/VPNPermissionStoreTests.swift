//
//  VPNPermissionStoreTests.swift
//  PIAVPNPermissionTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
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

import CoreArchitecture
import Foundation
import Testing

@testable import PIAVPNPermission

@MainActor
struct VPNPermissionStoreTests {

    private let spy = VPNPermissionDependencySpy()

    private func makeStore(
        state: VPNPermission.State = VPNPermission.State()
    ) -> TestStore<VPNPermission.State, VPNPermission.Action> {
        TestStore(
            initial: state,
            reduce: VPNPermission.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    @Test("Appearing reads whether support can be emailed", arguments: [true, false])
    func appearingReadsMailAvailability(canSendMail: Bool) async throws {
        spy.canSendMail = canSendMail
        let sut = makeStore(state: .init(canContactSupport: !canSendMail))

        sut.send(.onAppear)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.canContactSupport == canSendMail)
    }

    @Test("Granting the permission closes the screen once")
    func grantingClosesTheScreen() async throws {
        let sut = makeStore()

        sut.send(.submitTapped)
        #expect(sut.state.phase == .requesting)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.phase == .finished)
        #expect(spy.requestCallCount == 1)
        #expect(spy.emittedOutputs == [.granted])
    }

    @Test("Taps while the prompt is up are ignored")
    func tapsWhileRequestingAreIgnored() async throws {
        let sut = makeStore()

        sut.send(.submitTapped)
        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.requestCallCount == 1)
    }

    @Test("A failed install shows the denied dialog")
    func failureShowsDeniedDialog() async throws {
        spy.requestResult = .failure(VPNPermissionTestError())
        let sut = makeStore()

        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.phase == .denied)
        #expect(spy.emittedOutputs.isEmpty)
    }

    @Test("Acknowledging the denied dialog doesn't retry (KM-17461)")
    func acknowledgingDoesNotRetry() async {
        let sut = makeStore(state: .init(phase: .denied))

        sut.send(.deniedAcknowledged)
        await sut.finish()

        #expect(sut.state.phase == .idle)
        #expect(spy.requestCallCount == 0)
        #expect(spy.emittedOutputs.isEmpty)
    }

    @Test("The person can retry after acknowledging")
    func retryAfterAcknowledging() async throws {
        let sut = makeStore(state: .init(phase: .denied))

        sut.send(.deniedAcknowledged)
        sut.send(.submitTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.requestCallCount == 1)
        #expect(sut.state.phase == .finished)
    }

    @Test("Contacting support closes the dialog and asks the host for the composer")
    func contactingSupport() async {
        let sut = makeStore(state: .init(phase: .denied, canContactSupport: true))

        sut.send(.contactSupportTapped)
        await sut.finish()

        #expect(sut.state.phase == .idle)
        #expect(spy.emittedOutputs == [.contactSupport])
        #expect(spy.requestCallCount == 0)
    }

    @Test("The live dependency maps the provider callback", arguments: [true, false])
    func liveMapsCallback(succeeds: Bool) async {
        let dependencies = VPNPermission.Dependencies.live(
            obtainPermission: { callback in
                DispatchQueue.global().async {
                    callback(succeeds ? nil : VPNPermissionTestError())
                }
            },
            canSendMail: { false },
            emit: { _ in }
        )

        let result = await dependencies.requestPermission()

        switch result {
        case .success: #expect(succeeds)
        case .failure: #expect(!succeeds)
        }
    }
}
