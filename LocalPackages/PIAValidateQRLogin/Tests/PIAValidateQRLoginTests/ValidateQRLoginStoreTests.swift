//
//  ValidateQRLoginStoreTests.swift
//  PIAValidateQRLoginTests
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
import Testing

@testable import PIAValidateQRLogin

@MainActor
struct ValidateQRLoginStoreTests {

    private let spy = ValidateQRLoginDependencySpy()

    private func makeStore(
        state: ValidateQRLogin.State = ValidateQRLogin.State()
    ) -> TestStore<ValidateQRLogin.State, ValidateQRLogin.Action> {
        TestStore(
            initial: state,
            reduce: ValidateQRLogin.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    @Test("Appearing asks for confirmation once")
    func appearingAsksForConfirmationOnce() async {
        let sut = makeStore()

        sut.send(.onAppear)
        #expect(sut.state.phase == .confirming)

        sut.send(.confirmTapped)
        sut.send(.onAppear)
        #expect(sut.state.phase == .validating)
        await sut.finish()
    }

    @Test("A successful validation discards the token and dismisses")
    func successfulValidationDismisses() async throws {
        let sut = makeStore(state: .init(phase: .confirming))

        sut.send(.confirmTapped)
        #expect(sut.state.phase == .validating)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.phase == .finished)
        #expect(spy.validateCallCount == 1)
        #expect(spy.discardCallCount == 1)
        #expect(spy.emittedOutputs == [.dismiss])
    }

    @Test("A failed validation shows the error and keeps the token until acknowledged")
    func failedValidationShowsError() async throws {
        spy.validateResult = .failure(ValidateQRLoginTestError())
        let sut = makeStore(state: .init(phase: .confirming))

        sut.send(.confirmTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.phase == .failed)
        #expect(spy.discardCallCount == 0)
        #expect(spy.emittedOutputs.isEmpty)
    }

    @Test("Acknowledging the error discards the token and dismisses once")
    func acknowledgingErrorDismisses() async {
        let sut = makeStore(state: .init(phase: .failed))

        sut.send(.errorAcknowledged)
        #expect(sut.state.phase == .finished)
        sut.send(.errorAcknowledged)
        await sut.finish()

        #expect(spy.discardCallCount == 1)
        #expect(spy.emittedOutputs == [.dismiss])
    }

    @Test("Cancelling discards the token and dismisses once")
    func cancellingClearsTokenAndDismisses() async {
        let sut = makeStore(state: .init(phase: .confirming))

        sut.send(.cancelTapped)
        #expect(sut.state.phase == .finished)
        sut.send(.cancelTapped)
        await sut.finish()

        #expect(spy.discardCallCount == 1)
        #expect(spy.validateCallCount == 0)
        #expect(spy.emittedOutputs == [.dismiss])
    }
}
