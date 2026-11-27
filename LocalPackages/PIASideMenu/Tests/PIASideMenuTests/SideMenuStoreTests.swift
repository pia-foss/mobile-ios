//
//  SideMenuStoreTests.swift
//  PIASideMenuTests
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

@testable import PIASideMenu

@MainActor
struct SideMenuStoreTests {

    private let spy = SideMenuDependencySpy()

    private func makeStore(
        state: SideMenu.State = SideMenu.State(account: .stub())
    ) -> TestStore<SideMenu.State, SideMenu.Action> {
        TestStore(initial: state, reduce: SideMenu.Reducer(dependencies: spy.makeDependencies()).reduce)
    }

    // MARK: Account

    @Test("Appearing reloads the account, then every update does again")
    func appearingObservesAccount() async throws {
        let sut = makeStore()
        spy.account = .stub(username: "p7654321")

        sut.send(.onAppear)
        #expect(try #require(await sut.receive()) == .accountUpdated(.stub(username: "p7654321")))

        spy.account = .stub(expiration: .days(2))
        spy.updates.yield()
        _ = try #require(await sut.receive())
        spy.updates.finish()
        await sut.finish()

        #expect(sut.state.account == .stub(expiration: .days(2)))
    }

    // MARK: Items

    @Test(
        "Screens and websites go to the host",
        arguments: [
            (SideMenu.Item.destination(.regionSelection), SideMenu.Output.show(.regionSelection)),
            (.destination(.dedicatedIP), .show(.dedicatedIP)),
            (.destination(.about), .show(.about)),
            (.website(.support), .open(.support)),
            (.website(.privacy), .open(.privacy))
        ])
    func itemsEmit(item: SideMenu.Item, output: SideMenu.Output) async {
        let sut = makeStore()

        sut.send(.itemTapped(item))
        await sut.finish()

        #expect(spy.emittedOutputs == [output])
        #expect(sut.state.alert == nil)
    }

    @Test("Managing the subscription goes to the host")
    func manageSubscription() async {
        let sut = makeStore()

        sut.send(.manageSubscriptionTapped)
        await sut.finish()

        #expect(spy.emittedOutputs == [.manageSubscription])
    }

    // MARK: Logout

    @Test("Logging out asks for confirmation first")
    func logoutAsksFirst() async {
        let sut = makeStore()

        sut.send(.itemTapped(.logout))
        await sut.finish()

        #expect(sut.state.alert == .logoutConfirmation)
        #expect(spy.logoutCallCount == 0)
    }

    @Test("Confirming logs out while the menu is blocked")
    func logoutConfirmed() async throws {
        let sut = makeStore(state: .init(account: .stub(), alert: .logoutConfirmation))

        sut.send(.logoutConfirmed)
        #expect(sut.state.isLoading)
        #expect(sut.state.alert == nil)

        #expect(try #require(await sut.receive()) == .logoutFinished)
        #expect(spy.logoutCallCount == 1)
        #expect(!sut.state.isLoading)
    }

    // MARK: Renewal

    @Test(
        "Each renewal outcome shows its alert",
        arguments: [
            (SideMenu.RenewalResult.renewed, SideMenu.Alert?.some(.renewalSucceeded)),
            (.cancelled, nil),
            (.trial, .renewingTrial),
            (.nonRenewable, .renewingNonRenewable),
            (.failed(message: "Nope"), .failure(message: "Nope"))
        ])
    func renewalOutcome(result: SideMenu.RenewalResult, alert: SideMenu.Alert?) async throws {
        spy.renewalResult = result
        let sut = makeStore(state: .init(account: .stub(expiration: .hours(5))))

        sut.send(.expirationTapped)
        #expect(sut.state.isLoading)

        #expect(try #require(await sut.receive()) == .renewalFinished(result))
        #expect(!sut.state.isLoading)
        #expect(sut.state.alert == alert)
    }

    @Test("A second tap while renewing is ignored")
    func renewalIgnoresDoubleTap() async throws {
        let sut = makeStore(state: .init(account: .stub(), isLoading: true))

        sut.send(.expirationTapped)
        await sut.finish()

        #expect(spy.renewCallCount == 0)
    }

    @Test("A trial upgrades instead of renewing")
    func upgradeTrial() async {
        let sut = makeStore(state: .init(account: .stub(), alert: .renewingTrial))

        sut.send(.upgradeTrialConfirmed)
        await sut.finish()

        #expect(sut.state.alert == nil)
        #expect(spy.emittedOutputs == [.upgradeTrial])
    }

    @Test("A non-renewable subscription renews on the website")
    func renewOnWebsite() async {
        let sut = makeStore(state: .init(account: .stub(), alert: .renewingNonRenewable))

        sut.send(.renewOnWebsiteConfirmed)
        await sut.finish()

        #expect(sut.state.alert == nil)
        #expect(spy.emittedOutputs == [.open(.home)])
    }
}
