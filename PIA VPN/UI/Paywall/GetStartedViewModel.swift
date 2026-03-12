//
//  GetStartedViewModel.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 05.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import SwiftUI
import Observation
import PIALibrary
import Combine

enum GetStartedViewEvent {
    case navigateToLogin
    case showUncreditedAlert
    case showPurchaseErrorAlert(Error)
    case showLoading(Bool)
    case completePurchase(String, InAppTransaction)
}

@MainActor
protocol GetStartedViewModelProtocol: ObservableObject {
    var plans: LoadableContent<[PurchasePlan], Error> { get }
    var selectedPlan: PurchasePlan? { get set }

    func confirmPlan()
    func navigateToLoginView()
}

@MainActor
final class GetStartedViewModel: GetStartedViewModelProtocol {
    @Published var plans: LoadableContent<[PurchasePlan], any Error> = .loading
    @Published var selectedPlan: PurchasePlan?

    /// Publisher for UIKit actions (navigation, alerts) that can't be handled in SwiftUI yet.
    /// Subscribed to by GetStartedHostingController.
    let events = PassthroughSubject<GetStartedViewEvent, Never>()

    private let accountProvider: AccountProvider
    private var cancellables = Set<AnyCancellable>()

    init(accountProvider: AccountProvider) {
        self.accountProvider = accountProvider

        // TODO: Instead implement a MockGetStartedViewModel for SwiftUI previews
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        setupObservers()
        Client.refreshProducts()
    }

    func confirmPlan() {
        guard let selectedPlan else { return }
        startPurchaseProcess(plan: selectedPlan)
    }

    func navigateToLoginView() {
        events.send(.navigateToLogin)
    }

    private func startPurchaseProcess(
        email: String = "",
        plan: PurchasePlan
    ) {
//        isPurchasing = true
//        disableInteractions(fully: true)
        events.send(.showLoading(true))

        accountProvider.purchase(plan: plan.plan) { [weak self] (transaction, error) in
            guard let self else { return }

//            self.isPurchasing = false
//            self.enableInteractions()
            events.send(.showLoading(false))
//
            guard let transaction = transaction else {
                if let error {
                    events.send(.showPurchaseErrorAlert(error))
                }
                return
            }

            events.send(.completePurchase(email, transaction))
        }
    }

    private func setupObservers() {
        NotificationCenter
            .default
            .publisher(for: .__InAppDidFetchProducts)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: productsDidFetch)
            .store(in: &cancellables)
    }

    private func productsDidFetch(_ notification: Notification) {
        let products: [Plan: InAppProduct] = notification.userInfo(for: .products)
        var allPlans: [PurchasePlan] = []

        if let yearlyProduct = products[.yearly] {
            let purchase = PurchasePlan(
                plan: .yearly,
                product: yearlyProduct,
                monthlyFactor: 12.0
            )

            purchase.title = L10n.Welcome.Plan.Yearly.title
            purchase.bestValue = true
            
            let currencySymbol = purchase.product.priceLocale.currencySymbol ?? ""
            purchase.detail = L10n.Welcome.Plan.Yearly.detailFormat(currencySymbol, purchase.product.price.description)
            purchase.secondaryDetail = calculateWeeklyPrice(
                price: purchase.product.price.doubleValue,
                monthlyFactor: 12,
                currencySymbol: currencySymbol
            )

            allPlans.append(purchase)
        }

        if let monthlyProduct = products[.monthly] {
            let purchase = PurchasePlan(
                plan: .monthly,
                product: monthlyProduct,
                monthlyFactor: 1.0
            )

            purchase.title = L10n.Welcome.Plan.Monthly.title
            purchase.bestValue = false

            let currencySymbol = purchase.product.priceLocale.currencySymbol ?? ""
            purchase.detail = L10n.Welcome.Plan.Monthly.detailFormat(currencySymbol, purchase.product.price.description)
            purchase.secondaryDetail = calculateWeeklyPrice(
                price: purchase.product.price.doubleValue,
                monthlyFactor: 1,
                currencySymbol: currencySymbol
            )

            allPlans.append(purchase)
        }

        selectedPlan = allPlans.first
        plans = .loaded(allPlans)
    }

    private func calculateWeeklyPrice(
        price: Double,
        monthlyFactor: Double,
        currencySymbol: String
    ) -> String? {
        let weeklyPrice = (price / monthlyFactor) / 4.0
        return L10n.Welcome.Plan.Weekly.detailFormat(currencySymbol, String(format: "%.2f", weeklyPrice))
    }
}
