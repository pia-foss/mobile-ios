//
//  Paywall+Reducer.swift
//  PIAPaywall
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
import PIALocalizations

extension Paywall {

    /// The only place `Paywall.State` mutates.
    ///
    /// Pure: it captures its dependencies at init and every side effect leaves as an `Effect`. No
    /// `Client.providers`, no networking, no `Task`, no clock — which is what makes the purchase rules
    /// here provable in a unit test rather than only observable on a device with a sandbox account.
    ///
    /// `reduce` is a routing table — read it for the whole action surface, then the handler for the
    /// transition you care about.
    public struct Reducer {

        /// The state this reducer moves.
        public typealias State = Paywall.State

        /// The events this reducer accepts.
        public typealias Action = Paywall.Action

        /// One id per kind of work. Starting a new effect under an id cancels whatever was already
        /// in flight under it, which is what makes a double tap harmless even before the guards.
        fileprivate enum EffectID: Hashable {
            case offers
            case purchase
            case purchaseIntents
            case restore
        }

        /// The injected collaborators.
        public let dependencies: Dependencies

        /// Creates a reducer bound to `dependencies`.
        ///
        /// - Parameter dependencies: The collaborators every effect runs through.
        public init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }

        /// Applies `action` to `state` and returns any work that should follow.
        ///
        /// - Parameters:
        ///   - state: The state to mutate in place.
        ///   - action: The event to apply.
        /// - Returns: Work to perform, or `nil` when the action needs none.
        public func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {

            // MARK: Lifecycle

            case .onAppear: return appear()
            case .disappeared: return disappear()
            case .retryTapped: return retry(in: &state)
            case .layoutChanged(let layout): return apply(layout, in: &state)
            case .offersResponse(let result): return receiveOffers(result, in: &state)

            // MARK: Plan sheet

            case .seeOtherPlansTapped: return openPlanSheet(in: &state)
            case .planSheetDismissed: return dismissPlanSheet(in: &state)
            case .planSelected(let plan): return select(plan, in: &state)

            // MARK: Purchase

            case .purchaseTapped(let source): return beginPurchase(from: source, in: &state)
            case .purchaseIntentReceived(let product): return beginPurchase(.product(product), in: &state)
            case .existingEntitlementFound: return offerRestoreInstead(in: &state)
            case .purchaseSucceeded(let transaction): return completePurchase(transaction, in: &state)
            case .purchaseFailed(let error): return failPurchase(error, in: &state)

            // MARK: Restore

            case .restoreTapped: return beginRestore(in: &state)
            case .alertRestoreConfirmed: return confirmRestore(in: &state)
            case .restoreSucceeded(let account): return completeRestore(account, in: &state)
            case .restoreFailedNothingToRestore: return failRestore(with: .nothingToRestore, in: &state)
            case .restoreFailedBadReceipt: return failRestore(with: .restoreFailed, in: &state)

            // MARK: Misc

            case .alertDismissed: return dismissAlert(in: &state)
            case .loginTapped: return requestLogin(in: state)
            case .closeTapped: return requestDismissal()
            }
        }
    }
}

extension Paywall.Reducer {

    // MARK: - Lifecycle

    /// Subscribes to external purchases and fetches the catalogue.
    ///
    /// Safe to run again on every appearance: the intent stream is restarted under its own id, and
    /// `loadOffers` returns cached offers.
    private func appear() -> Effect<Action>? {
        .merge(observePurchaseIntents, loadOffers)
    }

    /// Stops watching for purchases started outside the app, and nothing else.
    ///
    /// A purchase or a restore already in flight is deliberately left running: those are what report
    /// `didPurchase` and `didAuthenticate`, and the paywall disappears when it is merely covered — by
    /// a pushed login screen — as well as when it is torn down. Cancelling everything here would drop
    /// an outcome the customer has already paid for. Teardown proper needs no help: releasing the
    /// store cancels whatever it still had running.
    private func disappear() -> Effect<Action>? {
        .cancel(id: EffectID.purchaseIntents)
    }

    private func retry(in state: inout State) -> Effect<Action>? {
        guard state.phase == .productsUnavailable, state.activity == .idle else { return nil }
        state.phase = .loadingProducts
        return loadOffers
    }

    private func apply(_ layout: PaywallLayout, in state: inout State) -> Effect<Action>? {
        state.layout = layout
        return nil
    }

    /// Renders the catalogue, or reports that there is nothing to sell.
    ///
    /// An empty success is a failure like any other: `listPlanProducts()` can succeed with no
    /// products, and treating that as "loaded" renders a paywall with no prices and a dead button.
    /// Either way the failure is inline rather than a banner — the customer did nothing wrong, and
    /// the screen offers a retry.
    private func receiveOffers(
        _ result: Result<OffersPayload, PaywallError>,
        in state: inout State
    ) -> Effect<Action>? {
        guard case .success(let payload) = result, !payload.offers.isEmpty else {
            state.phase = .productsUnavailable
            return nil
        }
        state.offers = payload.offers
        state.trialOffer = payload.trialOffer
        state.defaultPlan = payload.offers[.yearly] != nil ? .yearly : .monthly
        state.sheetSelection = state.defaultPlan
        state.phase = .ready
        return nil
    }

    // MARK: - Plan sheet

    private func openPlanSheet(in state: inout State) -> Effect<Action>? {
        guard state.canPurchase else { return nil }
        state.sheetSelection = state.defaultPlan
        state.isPlanSheetPresented = true
        return nil
    }

    /// Closes the sheet and throws its selection away.
    ///
    /// "Maybe Later", the close button, the backdrop and the swipe all land here. The main screen
    /// keeps selling `defaultPlan`.
    private func dismissPlanSheet(in state: inout State) -> Effect<Action>? {
        state.isPlanSheetPresented = false
        state.sheetSelection = state.defaultPlan
        return nil
    }

    private func select(_ plan: PaywallPlanID, in state: inout State) -> Effect<Action>? {
        guard state.offers[plan] != nil else { return nil }
        state.sheetSelection = plan
        return nil
    }

    // MARK: - Purchase

    /// Buys the plan the tapped surface was selling: the sheet's selection, or the main screen's default.
    private func beginPurchase(
        from source: Action.PurchaseSource,
        in state: inout State
    ) -> Effect<Action>? {
        guard state.canPurchase else { return nil }
        let plan = source == .planSheet ? state.sheetSelection : state.defaultPlan
        guard state.offers[plan] != nil else { return nil }
        return beginPurchase(.plan(plan), in: &state)
    }

    /// The sheet is closed on the way in, because a banner or alert would otherwise be hidden behind it.
    private func beginPurchase(_ request: PurchaseRequest, in state: inout State) -> Effect<Action>? {
        guard state.canPurchase else { return nil }
        state.activity = .purchasing
        state.isPlanSheetPresented = false
        return checkEntitlementThenPurchase(request)
    }

    /// Charging a customer who already owns a subscription is the worst failure this screen has, so
    /// the purchase stops here and a restore is offered instead.
    private func offerRestoreInstead(in state: inout State) -> Effect<Action>? {
        state.activity = .idle
        state.alert = .existingEntitlement
        return nil
    }

    /// Hands the transaction to the host, unless it arrived already expired.
    ///
    /// An unfinished, already-expired transaction is finished so the App Store stops redelivering it,
    /// and no account is created from it.
    private func completePurchase(
        _ transaction: Action.Transaction,
        in state: inout State
    ) -> Effect<Action>? {
        state.activity = .idle
        guard transaction.isExpired else {
            return emit(.didPurchase(transaction: transaction.value))
        }
        return .fireAndForget { [dependencies] in
            await dependencies.finishTransaction(transaction.value)
            dependencies.emit(.showWarning(message: L10n.Signup.Paywall.Error.expiredTransaction))
        }
    }

    private func failPurchase(_ error: PaywallError, in state: inout State) -> Effect<Action>? {
        state.activity = .idle
        guard let message = error.userFacingMessage else { return nil }
        return emit(.showWarning(message: message))
    }

    // MARK: - Restore

    private func beginRestore(in state: inout State) -> Effect<Action>? {
        guard state.canRestore else { return nil }
        state.activity = .restoring
        return restore
    }

    private func confirmRestore(in state: inout State) -> Effect<Action>? {
        state.alert = nil
        return beginRestore(in: &state)
    }

    private func completeRestore(_ account: Action.Account, in state: inout State) -> Effect<Action>? {
        state.activity = .idle
        return emit(.didAuthenticate(user: account.value))
    }

    /// The two restore failures differ only in which alert they raise, so they share a handler.
    private func failRestore(with alert: State.AlertKind, in state: inout State) -> Effect<Action>? {
        state.activity = .idle
        state.alert = alert
        return nil
    }

    // MARK: - Misc

    private func dismissAlert(in state: inout State) -> Effect<Action>? {
        state.alert = nil
        return nil
    }

    /// Reads state without mutating it: navigating away mid-charge is what the guard prevents.
    private func requestLogin(in state: State) -> Effect<Action>? {
        guard state.activity == .idle else { return nil }
        return emit(.requestLogin)
    }

    private func requestDismissal() -> Effect<Action>? {
        emit(.didCancel)
    }
}

extension Paywall.Reducer {

    /// Purchases started outside the app arrive over time, so this is a stream rather than a task.
    fileprivate var observePurchaseIntents: Effect<Action> {
        .stream(id: EffectID.purchaseIntents) { [dependencies] send in
            for await product in dependencies.purchaseIntents() {
                send(.purchaseIntentReceived(product))
            }
        }
    }

    fileprivate var loadOffers: Effect<Action> {
        .cancellableTask(id: EffectID.offers) { [dependencies] in
            .offersResponse(await dependencies.loadOffers())
        }
    }

    /// The entitlement check must happen *before* the purchase: an App Store account that already
    /// owns a subscription is offered a restore instead of being charged twice.
    fileprivate func checkEntitlementThenPurchase(_ request: PurchaseRequest) -> Effect<Action> {
        .cancellableTask(id: EffectID.purchase) { [dependencies] in
            if await dependencies.hasExistingEntitlement() {
                return .existingEntitlementFound
            }
            switch await dependencies.purchase(request) {
            case .success(let transaction):
                return .purchaseSucceeded(.init(transaction))
            case .failure(let error):
                return .purchaseFailed(error)
            }
        }
    }

    fileprivate var restore: Effect<Action> {
        .cancellableTask(id: EffectID.restore) { [dependencies] in
            switch await dependencies.restore() {
            case .success(let user):
                return .restoreSucceeded(.init(user))
            case .failure(.restoreLoginFailed):
                return .restoreFailedBadReceipt
            case .failure:
                return .restoreFailedNothingToRestore
            }
        }
    }

    /// Reporting upward is I/O like any other, so it leaves as an effect rather than an inline call.
    fileprivate func emit(_ output: Paywall.Output) -> Effect<Action> {
        .fireAndForget { [dependencies] in dependencies.emit(output) }
    }
}

extension Effect {

    /// `Effect.task` dispatches its action even when the effect was cancelled while the work was in
    /// flight, because nothing between the `await` and the sink checks. A purchase settling after
    /// the paywall has gone away would then still be reported to a host that stopped listening, so
    /// the action is dropped here instead.
    fileprivate static func cancellableTask(
        id: AnyHashable,
        _ work: @escaping @MainActor () async -> Action?
    ) -> Effect {
        .task(id: id) {
            let action = await work()
            return Task.isCancelled ? nil : action
        }
    }
}
