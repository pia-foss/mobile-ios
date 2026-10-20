//
//  AccountDetailsStoreTests.swift
//  PIAAccountDetailsTests
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
import PIALibrary
import Testing

@testable import PIAAccountDetails

@MainActor
struct AccountDetailsStoreTests {

    private let spy = AccountDetailsDependencySpy()

    private func makeStore(
        state: AccountDetails.State = AccountDetails.State(account: .stub())
    ) -> TestStore<AccountDetails.State, AccountDetails.Action> {
        TestStore(
            initial: state,
            reduce: AccountDetails.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    // MARK: Account

    @Test("Appearing refreshes the account")
    func appearingRefreshes() async {
        let sut = makeStore()

        sut.send(.onAppear)
        spy.updates.finish()
        await sut.finish()

        #expect(spy.refreshCallCount == 1)
    }

    @Test("An account update reloads what the screen shows")
    func updateReloadsAccount() async throws {
        let sut = makeStore()
        sut.send(.onAppear)

        let expired = AccountDetails.Account.stub(expiry: .expired)
        spy.account = expired
        spy.updates.yield()
        let action = try #require(await sut.receive())
        spy.updates.finish()
        await sut.finish()

        #expect(action == .accountUpdated(expired))
        #expect(sut.state.account == expired)
    }

    @Test("Logging out elsewhere clears the account")
    func updateToNoAccount() async throws {
        let sut = makeStore()
        sut.send(.onAppear)

        spy.account = nil
        spy.updates.yield()
        _ = try #require(await sut.receive())
        spy.updates.finish()
        await sut.finish()

        #expect(sut.state.account == nil)
    }

    // MARK: Restore

    @Test("A successful restore thanks the user and reloads the account")
    func restoreSucceeds() async throws {
        let sut = makeStore(state: .init(account: .stub(isRenewable: true)))
        let renewed = AccountDetails.Account.stub(isRenewable: false)
        spy.account = renewed

        sut.send(.restoreTapped)
        #expect(sut.state.isRestoring)
        #expect(try #require(await sut.receive()) == .restoreFinished(.renewed))
        #expect(try #require(await sut.receive()) == .accountUpdated(renewed))
        await sut.finish()

        #expect(!sut.state.isRestoring)
        #expect(sut.state.alert == .restoreSucceeded)
        #expect(sut.state.account == renewed)
    }

    @Test(
        "A failed restore explains why",
        arguments: [
            (AccountDetails.RestoreResult.badReceipt, AccountDetails.Alert.noRedeemablePurchase),
            (.failed(message: "Offline"), .failure(message: "Offline"))
        ])
    func restoreFails(result: AccountDetails.RestoreResult, alert: AccountDetails.Alert) async throws {
        spy.restoreResult = result
        let sut = makeStore(state: .init(account: .stub(isRenewable: true)))

        sut.send(.restoreTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(!sut.state.isRestoring)
        #expect(sut.state.alert == alert)
        #expect(sut.unconsumedActionCount == 0)
    }

    @Test("Taps while restoring are ignored")
    func tapsWhileRestoringAreIgnored() async throws {
        spy.restoreResult = .badReceipt
        let sut = makeStore(state: .init(account: .stub(isRenewable: true)))

        sut.send(.restoreTapped)
        sut.send(.restoreTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.restoreCallCount == 1)
    }

    @Test("Dismissing the alert clears it")
    func dismissingAlert() async {
        let sut = makeStore(state: .init(account: .stub(), alert: .restoreSucceeded))

        sut.send(.alertDismissed)
        await sut.finish()

        #expect(sut.state.alert == nil)
    }

    // MARK: Outputs

    @Test("Links ask the host to open them")
    func linksEmitOutputs() async {
        let sut = makeStore()

        sut.send(.manageSubscriptionTapped)
        sut.send(.deleteAccountTapped)
        await sut.finish()

        #expect(spy.emittedOutputs == [.manageSubscription, .deleteAccount])
    }

    // MARK: Live

    @Test("Restoring renews when both steps succeed")
    func liveRestoreRenews() async {
        var renewCalled = false

        let result = await AccountDetails.Dependencies.renew(
            after: .success(()),
            renew: { completion in
                renewCalled = true
                DispatchQueue.global().async { completion(nil) }
            }
        )

        #expect(result == .renewed)
        #expect(renewCalled)
    }

    @Test("A failed App Store sync doesn't try to renew")
    func liveRestoreFailureSkipsRenew() async {
        var renewCalled = false

        let result = await AccountDetails.Dependencies.renew(
            after: .failure(AccountDetailsTestError()),
            renew: { _ in renewCalled = true }
        )

        #expect(result == .failed(message: "Something failed"))
        #expect(!renewCalled)
    }

    @Test("A bad receipt is told apart from other renew errors")
    func liveRenewErrors() async {
        let badReceipt = await AccountDetails.Dependencies.renew(
            after: .success(()),
            renew: { completion in completion(ClientError.badReceipt) }
        )
        let other = await AccountDetails.Dependencies.renew(
            after: .success(()),
            renew: { completion in completion(AccountDetailsTestError()) }
        )

        #expect(badReceipt == .badReceipt)
        #expect(other == .failed(message: "Something failed"))
    }
}
