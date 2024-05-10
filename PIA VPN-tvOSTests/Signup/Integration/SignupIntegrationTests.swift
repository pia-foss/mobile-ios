//
//  SignupIntegrationTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 09/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary
import Combine
import StoreKit

final class SignupIntegrationTests: XCTestCase {
    class Fixture {
        let inAppProviderSpy = InAppProviderSpy()
    }
    
    var fixture: Fixture!
    var sut: SignupViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedLoadingState: [Bool]!
    var capturedTransaction: InAppTransaction?
    
    func instantiateSut(resultGetAvailableProductsUseCase: ([Plan : InAppProduct]?, Error?), resultPurchaseProductUseCase: (InAppTransaction?, Error?), appStoreInformationResult: PIALibrary.AppStoreInformation?, onSuccessAction: @escaping (InAppTransaction?) -> Void) {
        let accountProviderMock = AccountProviderMock(userResult: PIALibrary.UserAccount.makeStub(),
                                                      errorResult: nil,
                                                      appStoreInformationResult: appStoreInformationResult)
        
        let productsProviderMock = ProductsProviderMock(result: (resultGetAvailableProductsUseCase.0, resultGetAvailableProductsUseCase.1))
        let subscriptionInformationProvider = SubscriptionInformationProvider(accountProvider: accountProviderMock)
        let decoratorProductsProvider = DecoratorProductsProvider(subscriptionInformationProvider: subscriptionInformationProvider,
                                                                  decoratee: productsProviderMock,
                                                                  store: fixture.inAppProviderSpy,
                                                                  productConfiguration: ProductConfigurationSpy())
        let getAvailableProductsUseCase = GetAvailableProductsUseCase(productsProvider: decoratorProductsProvider)
        
        let purchaseProductsAccountProviderMock = PurchaseProductsAccountProviderMock(result: (resultPurchaseProductUseCase.0, resultPurchaseProductUseCase.1))
        let decoratorPurchaseProductsProvider = DecoratorPurchaseProductsProvider(purchaseProductsProvider: purchaseProductsAccountProviderMock,
                                                                                  errorMapper: PurchaseProductDomainErrorMapper(),
                                                                                  store: fixture.inAppProviderSpy)
        let purchaseProductUseCase = PurchaseProductUseCase(purchaseProductsProvider: decoratorPurchaseProductsProvider)
        
        let optionButtons = [
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.privacy, action: {}),
            OnboardingComponentButton(title: L10n.Welcome.Agreement.Message.tos, action: {})
        ]
        
        sut = SignupViewModel(optionButtons: optionButtons,
                              getAvailableProducts: getAvailableProductsUseCase,
                              purchaseProduct: purchaseProductUseCase,
                              viewModelMapper: SubscriptionOptionViewModelMapper(),
                              signupPresentableMapper: SignupPresentableErrorMapper(),
                              onSuccessAction: onSuccessAction)
    }
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedLoadingState = []
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedLoadingState = nil
        capturedTransaction = nil
    }

    func test_getproducts_successfully_presents_products_when_it_succeeded_retrieving_products() throws {
        // GIVEN
        let productsProviderError: Error? = nil
        let purchaseProductsAccountProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for getproducts to finish")
        
        instantiateSut(resultGetAvailableProductsUseCase: (InAppProductMock.makeStubs(), productsProviderError),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), purchaseProductsAccountProviderError),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { _ in })
        
        sut.$subscriptionOptions.dropFirst().sink(receiveValue: { _ in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN getproducts is executed
        sut.getproducts()
        
        // THEN subscriptionOptions is populated by a UI friendly array of subscriptions
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.subscriptionOptions.count, 2)
        XCTAssertEqual(sut.subscriptionOptions[0].productId, "002")
        XCTAssertEqual(sut.subscriptionOptions[0].option, .yearly)
        XCTAssertEqual(sut.subscriptionOptions[0].optionString, "Yearly")
        XCTAssertEqual(sut.subscriptionOptions[0].price, "100.99$ per year")
        XCTAssertEqual(sut.subscriptionOptions[0].monthlyPrice, "8.42$/mo")
        XCTAssertEqual(sut.subscriptionOptions[0].freeTrial, "BEST VALUE - FREE TRIAL")
        
        XCTAssertEqual(sut.subscriptionOptions[1].productId, "001")
        XCTAssertEqual(sut.subscriptionOptions[1].option, .monthly)
        XCTAssertEqual(sut.subscriptionOptions[1].optionString, "Monthly")
        XCTAssertEqual(sut.subscriptionOptions[1].price, "10.99$ per month")
        XCTAssertNil(sut.subscriptionOptions[1].monthlyPrice)
        XCTAssertNil(sut.subscriptionOptions[1].freeTrial)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertEqual(sut.subtitle, L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle("100.99$"))
        
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_getproducts_shows_a_generic_error_when_there_is_a_unexpectedReply_error() throws {
        // GIVEN
        let inAppProductStub: [Plan : any InAppProduct]? = nil
        let purchaseProductsAccountProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for getproducts to finish")
        
        instantiateSut(resultGetAvailableProductsUseCase: (inAppProductStub, ClientError.unexpectedReply),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), purchaseProductsAccountProviderError),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { _ in })
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { _ in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN getproducts is executed
        sut.getproducts()
        
        // THEN a generic error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.subscriptionOptions.count, 0)
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertEqual(sut.subtitle, L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle(""))
        
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic)
    }
    
    func test_getproducts_shows_a_generic_error_when_there_is_no_retrieved_products() throws {
        // GIVEN
        let inAppProductStub: [Plan : any InAppProduct]? = nil
        let productsProviderError: Error? = nil
        let purchaseProductsAccountProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for getproducts to finish")
        
        instantiateSut(resultGetAvailableProductsUseCase: (inAppProductStub, productsProviderError),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), purchaseProductsAccountProviderError),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { _ in })
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { _ in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN getproducts is executed
        sut.getproducts()
        
        // THEN a generic error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.subscriptionOptions.count, 0)
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertEqual(sut.subtitle, L10n.Localizable.Tvos.Signup.Subscription.Paywall.subtitle(""))
        
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic)
    }
    
    func test_subscribe_succeeds_when_a_product_was_purchased() throws {
        // GIVEN
        let productsProviderError: Error? = nil
        let inAppTransactionStub = InAppTransactionMock.makeStub()
        let purchaseProductsAccountProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(resultGetAvailableProductsUseCase: (InAppProductMock.makeStubs(), productsProviderError),
                       resultPurchaseProductUseCase: (inAppTransactionStub, purchaseProductsAccountProviderError),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN a valid transaction is captured
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedTransaction?.identifier, inAppTransactionStub.identifier)
        XCTAssertEqual(capturedTransaction?.description, inAppTransactionStub.description)
        XCTAssertNil(capturedTransaction?.native)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_subscribe_shows_a_payment_cancelled_error_when_the_payment_was_cancelled() throws {
        // GIVEN payment is cancelled
        let productsProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(resultGetAvailableProductsUseCase: (InAppProductMock.makeStubs(), productsProviderError),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), SKError(SKError.Code.paymentCancelled, userInfo: [:])),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN a payment cancelled error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedTransaction)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Subscription.Error.Message.paymentCancelled)
    }
    
    func test_subscribe_shows_an_uncreditedTransactions_error_when_the_is_uncreditedTransactions() throws {
        // GIVEN there uncredited transactions
        let productsProviderError: Error? = nil
        let purchaseProductsAccountProviderError = SKError(SKError.Code.paymentCancelled, userInfo: [:])
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        fixture.inAppProviderSpy.hasUncreditedTransactions = true
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(resultGetAvailableProductsUseCase: (InAppProductMock.makeStubs(), productsProviderError),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), purchaseProductsAccountProviderError),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN a uncredited transactions error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedTransaction)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Signup.Purchase.Uncredited.Alert.message)
    }
    
    func test_subscribe_shows_a_generic_error_when_the_product_is_not_available() throws {
        // GIVEN the product is not available
        let productsProviderError: Error? = nil
        let appStoreInformation: PIALibrary.AppStoreInformation? = nil
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(resultGetAvailableProductsUseCase: (InAppProductMock.makeStubs(), productsProviderError),
                       resultPurchaseProductUseCase: (InAppTransactionMock.makeStub(), ClientError.productUnavailable),
                       appStoreInformationResult: appStoreInformation,
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN a generic error is presented
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedTransaction)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
    
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, L10n.Localizable.Tvos.Signup.Subscription.Error.Message.generic)
    }
}
