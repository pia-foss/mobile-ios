//
//  SignupFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 23/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import PIALocalizations
import PIAPaywall

private let log = PIALogger.logger(for: SignUpFactory.self)

class SignUpFactory {
    /// Opens the paywall, with welcome-back already on top of it when this Apple ID holds a live
    /// subscription, so a returning customer signs in instead of buying a second account.
    ///
    /// The check runs before navigating, so the paywall never shows before welcome-back covers it.
    /// Both screens are pushed together: Menu on welcome-back lands on the paywall.
    @MainActor
    static func openSignup(
        router: AppRouterType = AppRouter.shared,
        hasActiveSubscription: () async -> Bool = { await WelcomeBackFactory.makeHasActiveSubscriptionUseCase()() }
    ) async {
        let stackCount = router.stackCount
        let isSubscribed = await hasActiveSubscription()
        log.info("Welcome back: active subscription on this Apple ID: \(isSubscribed)")

        // The user may have moved on, or tapped twice, while StoreKit was read.
        guard router.stackCount == stackCount else { return }

        router.navigate(to: AuthenticationDestinations.signup)
        if isSubscribed {
            router.navigate(to: AuthenticationDestinations.welcomeBack)
        }
    }

    static func makeSignupQRView() -> SignupQRView {
        let url = URL(string: "https://apps.apple.com/us/app/vpn-by-private-internet-access/id955626407")!
        return SignupQRView(signUpURL: url)
    }

    static func makeSignUpView() -> SignupView {
        let optionButtons = [
            OnboardingComponentButton(
                title: L10n.Welcome.Agreement.Message.privacy,
                action: {
                    AppRouter.navigateToPrivacyPolicyDestinationAction()
                }),
            OnboardingComponentButton(
                title: L10n.Welcome.Agreement.Message.tos,
                action: {
                    AppRouter.navigateToTermsAndConditionsDestinationAction()
                })
        ]

        return SignupView(
            viewModel: SignupViewModel(
                optionButtons: optionButtons,
                getAvailableProducts: makeGetAvailableProductsUseCase(),
                purchaseProduct: makePurchaseProductUseCase(),
                viewModelMapper: SubscriptionOptionViewModelMapper(), signupPresentableMapper: SignupPresentableErrorMapper(),
                onSuccessAction: { transaction in
                    SignupEmailFactory.transaction = transaction
                    AppRouter.navigateToSignUpEmailDestinationAction()
                }))
    }

    private static func makeGetAvailableProductsUseCase() -> GetAvailableProductsUseCaseType {
        return GetAvailableProductsUseCase(productsProvider: makeDecoratorProductsProvider())
    }

    private static func makePurchaseProductUseCase() -> PurchaseProductUseCaseType {
        PurchaseProductUseCase(purchaseProductsProvider: makeDecoratorPurchaseProductsProvider())
    }

    private static func makeDecoratorProductsProvider() -> ProductsProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }

        return DecoratorProductsProvider(
            subscriptionInformationProvider: SubscriptionInformationProvider(accountProvider: defaultAccountProvider),
            decoratee: defaultAccountProvider,
            store: Client.store,
            productConfiguration: Client.configuration)
    }

    private static func makeDecoratorPurchaseProductsProvider() -> PurchaseProductsProviderType {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }

        return DecoratorPurchaseProductsProvider(
            purchaseProductsProvider: defaultAccountProvider,
            errorMapper: PurchaseProductDomainErrorMapper(),
            store: Client.store)
    }

    static func makePrivacySignupTermsView() -> SignupTermsView {
        SignupTermsView(
            url: URL(string: "https://www.privateinternetaccess.com/privacy-policy")!,
            title: L10n.HelpMenu.AboutOptions.PrivacyPolicy.title,
            description: L10n.HelpMenu.AboutSection.PrivacyPolicy.description,
            qrCodeMessage: L10n.HelpMenu.AboutSection.PrivacyPolicy.QrCode.message)
    }

    static func makeTermsConditionsSignupTermsView() -> SignupTermsView {
        SignupTermsView(
            url: URL(string: "https://www.privateinternetaccess.com/terms-of-service")!,
            title: L10n.Tvos.Signup.TermsConditions.title,
            description: L10n.Tvos.Signup.TermsConditions.description,
            qrCodeMessage: L10n.Tvos.Signup.TermsConditions.QrCode.message)
    }
}

// Bridge the library's async `AccountProvider` API to the tvOS callback-based protocols.
extension DefaultAccountProvider: ProductsProviderType {
    func listPlanProducts(_ callback: (([Plan: InAppProduct]?, Error?) -> Void)?) {
        Task {
            let result = await listPlanProducts()
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    callback?(products, nil)
                case .failure(let error):
                    callback?(nil, error)
                }
            }
        }
    }
}

extension Client.Configuration: ProductConfigurationType {
}

extension DefaultAccountProvider: PurchaseProductsAccountProviderType {
    func purchase(plan: Plan, _ callback: LibraryCallback<InAppTransaction>?) {
        Task {
            let result = await purchase(plan: plan)
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    callback?(transaction, nil)
                case .failure(let error):
                    callback?(nil, error)
                }
            }
        }
    }
}
