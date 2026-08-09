//
//  PaywallStore.swift
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

import Combine
import Foundation
import PIALibrary

/// Holds the paywall's state and runs the effects the reducer asks for.
///
/// State flows down (`state`), actions flow up (`send`), and anything the host must act on leaves
/// through `output`. `ObservableObject` rather than `@Observable` because the deployment target is
/// iOS 15; swapping it later is confined to this file.
@MainActor
public final class PaywallStore: ObservableObject {

    @Published public private(set) var state: PaywallState

    private let dependencies: PaywallDependencies
    private let outputSubject = PassthroughSubject<PaywallOutput, Never>()

    /// Navigation and host-side side effects.
    public var output: AnyPublisher<PaywallOutput, Never> { outputSubject.eraseToAnyPublisher() }

    /// One slot per kind of work. Starting a new one cancels the previous, which is what makes a
    /// double tap harmless even before the reducer's own guards.
    private enum EffectID: Hashable {
        case offers
        case purchase
        case restore
    }

    private var inFlight: [EffectID: Task<Void, Never>] = [:]

    /// Non-`Equatable` payloads parked between producing an effect and emitting its output. The
    /// reducer never sees them, which is what keeps `PaywallAction` comparable in tests.
    private var pendingTransaction: (any InAppTransaction)?
    private var pendingUser: UserAccount?

    public init(initialState: PaywallState = PaywallState(), dependencies: PaywallDependencies) {
        self.state = initialState
        self.dependencies = dependencies
    }

    deinit {
        // `cancelAll()` is main-actor isolated; cancelling the tasks directly is equivalent here.
        inFlight.values.forEach { $0.cancel() }
    }

    public func send(_ action: PaywallAction) {
        let effect = PaywallReducer.reduce(into: &state, action: action)
        run(effect)
    }

    /// Stops any in-flight work. Call when the paywall disappears.
    public func cancelAll() {
        inFlight.values.forEach { $0.cancel() }
        inFlight.removeAll()
    }

    // MARK: - Effects

    private func run(_ effect: PaywallEffect) {
        switch effect {
        case .none:
            break

        case .batch(let effects):
            effects.forEach(run)

        case .emit(let signal):
            emit(signal)

        case .loadOffers:
            start(.offers) { [dependencies] in
                .offersResponse(await dependencies.loadOffers())
            }

        case .checkEntitlementThenPurchase(let plan):
            start(.purchase) { [dependencies, weak self] in
                // Ordering matters: an account that already owns a subscription must be offered a
                // restore rather than being charged a second time.
                if await dependencies.hasExistingEntitlement() {
                    return .existingEntitlementFound
                }
                switch await dependencies.purchase(plan) {
                case .success(let transaction):
                    self?.pendingTransaction = transaction
                    return .purchaseSucceeded(isExpired: transaction.isExpired)
                case .failure(let error):
                    return .purchaseFailed(error)
                }
            }

        case .restore:
            start(.restore) { [dependencies, weak self] in
                switch await dependencies.restore() {
                case .success(let user):
                    self?.pendingUser = user
                    return .restoreSucceeded
                case .failure(.restoreLoginFailed):
                    return .restoreFailedBadReceipt
                case .failure:
                    return .restoreFailedNothingToRestore
                }
            }

        case .finishPendingTransaction:
            guard let transaction = pendingTransaction else { break }
            pendingTransaction = nil
            Task { [dependencies] in
                await dependencies.finishTransaction(transaction)
            }
        }
    }

    private func emit(_ signal: PaywallOutputSignal) {
        switch signal {
        case .didPurchase:
            guard let transaction = pendingTransaction else { return }
            pendingTransaction = nil
            outputSubject.send(.didPurchase(transaction: transaction))

        case .didAuthenticate:
            guard let user = pendingUser else { return }
            pendingUser = nil
            outputSubject.send(.didAuthenticate(user: user))

        case .requestLogin:
            outputSubject.send(.requestLogin)

        case .didCancel:
            outputSubject.send(.didCancel)

        case .showWarning(let message):
            outputSubject.send(.showWarning(message: message))
        }
    }

    private func start(_ id: EffectID, _ work: @escaping () async -> PaywallAction) {
        inFlight[id]?.cancel()
        inFlight[id] = Task { [weak self] in
            let action = await work()
            guard !Task.isCancelled else { return }
            self?.inFlight[id] = nil
            self?.send(action)
        }
    }
}
