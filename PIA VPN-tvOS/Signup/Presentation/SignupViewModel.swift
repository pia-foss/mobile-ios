//
//  SignupViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class SignupViewModel: ObservableObject {
    let title: String = L10n.Localizable.Tvos.Signup.Subscription.Paywall.title
    let optionButtons: [OnboardingComponentButton]
    let subscribeButtonTitle = L10n.Localizable.Tvos.Signup.Subscription.Paywall.Button.subscribe
    @Published var subtitle: String = L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle("")
    @Published var selectedSubscription: SubscriptionOption = .yearly
    @Published var isLoading: Bool = false
    @Published var shouldShowErrorMessage = false
    @Published var subscriptionOptions: [SubscriptionOptionViewModel] = []
    
    private let getAvailableProducts: GetAvailableProductsUseCaseType
    private let purchaseProduct: PurchaseProductUseCaseType
    private let viewModelMapper: SubscriptionOptionViewModelMapper
    
    init(optionButtons: [OnboardingComponentButton], getAvailableProducts: GetAvailableProductsUseCaseType, purchaseProduct: PurchaseProductUseCaseType, viewModelMapper: SubscriptionOptionViewModelMapper) {
        self.optionButtons = optionButtons
        self.getAvailableProducts = getAvailableProducts
        self.purchaseProduct = purchaseProduct
        self.viewModelMapper = viewModelMapper
    }
    
    func getproducts() {
        isLoading = true
        Task {
            do {
                let products = try await getAvailableProducts.getAllProducts()
                let subscriptionOptionViewModels = products.map { viewModelMapper.map(product: $0) }.sorted { $0.option.rawValue < $1.option.rawValue }
                Task { @MainActor in
                    subscriptionOptions = subscriptionOptionViewModels
                    isLoading = false
                }
            } catch {
                Task { @MainActor in
                    isLoading = false
                    shouldShowErrorMessage = true
                }
            }
        }
    }
    
    func subscribe() {
        Task {
            do {
                guard let productId = subscriptionOptions.first(where: { $0.option == selectedSubscription })?.productId else {
                    return
                }
                try await purchaseProduct(productId: productId)
                Task { @MainActor in
                    isLoading = false
                }
            } catch {
                Task { @MainActor in
                    isLoading = false
                }
            }
        }
    }
    
    func selectSubscription(_ subscription: SubscriptionOption) {
        selectedSubscription = subscription
    }
}
