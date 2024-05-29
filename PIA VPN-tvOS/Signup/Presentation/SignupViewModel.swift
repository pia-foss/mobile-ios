//
//  SignupViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 3/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupViewModel: ObservableObject {
    let title: String = L10n.Signup.Purchase.Trials.region
    let optionButtons: [OnboardingComponentButton]
    let subscribeButtonTitle = L10n.Localizable.Tvos.Signup.Subscription.Paywall.Button.subscribe
    @Published var subtitle: String = L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle("")
    @Published var selectedSubscription: SubscriptionOption = .yearly
    @Published var isLoading: Bool = false
    @Published var shouldShowErrorMessage = false
    @Published var subscriptionOptions: [SubscriptionOptionViewModel] = []
    var errorMessage: String?
    
    private let getAvailableProducts: GetAvailableProductsUseCaseType
    private let purchaseProduct: PurchaseProductUseCaseType
    private let viewModelMapper: SubscriptionOptionViewModelMapper
    private let signupPresentableMapper: SignupPresentableErrorMapper
    private let onSuccessAction: (InAppTransaction?) -> Void
    
    init(optionButtons: [OnboardingComponentButton], getAvailableProducts: GetAvailableProductsUseCaseType, purchaseProduct: PurchaseProductUseCaseType, viewModelMapper: SubscriptionOptionViewModelMapper, signupPresentableMapper: SignupPresentableErrorMapper, onSuccessAction: @escaping (InAppTransaction?) -> Void) {
        self.optionButtons = optionButtons
        self.getAvailableProducts = getAvailableProducts
        self.purchaseProduct = purchaseProduct
        self.viewModelMapper = viewModelMapper
        self.signupPresentableMapper = signupPresentableMapper
        self.onSuccessAction = onSuccessAction
    }
    
    func getproducts() {
        isLoading = true
        Task {
            do {
                let products = try await getAvailableProducts.getAllProducts()
                let subscriptionOptionViewModels = products.map { viewModelMapper.map(product: $0) }.sorted { $0.option.rawValue < $1.option.rawValue }
                Task { @MainActor in
                    subscriptionOptions = subscriptionOptionViewModels
                    if let price = subscriptionOptions.first(where: { $0.option == .yearly })?.rawPrice {
                        subtitle = L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle(price)
                    }
                    
                    isLoading = false
                }
            } catch {
                Task { @MainActor in
                    isLoading = false
                    handleError(error: error)
                }
            }
        }
    }
    
    func subscribe() {
        isLoading = true
        Task {
            do {
                let transaction = try await purchaseProduct(subscriptionOption: selectedSubscription)
                Task { @MainActor in
                    isLoading = false
                    onSuccessAction(transaction)
                }
            } catch {
                Task { @MainActor in
                    isLoading = false
                    handleError(error: error)
                }
            }
        }
    }
    
    func selectSubscription(_ subscription: SubscriptionOption) {
        selectedSubscription = subscription
    }
    
    private func handleError(error: Error) {
        errorMessage = signupPresentableMapper.map(error: error)
        shouldShowErrorMessage = true
        
        if let purchaseProductsError = error as? PurchaseProductsError, purchaseProductsError == .uncreditedTransaction {
            onSuccessAction(nil)
        }
    }
}
