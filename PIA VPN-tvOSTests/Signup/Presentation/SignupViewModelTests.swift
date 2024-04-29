//
//  SignupViewModelTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import Combine
@testable import PIA_VPN_tvOS
import PIALibrary

final class SignupViewModelTests: XCTestCase {
    class Fixture {
        var purchaseProductUseCaseMock: PurchaseProductUseCaseMock!
        var getAvailableProductsUseCaseMock: GetAvailableProductsUseCaseMock!
    }
    
    var fixture: Fixture!
    var sut: SignupViewModel!
    var cancellables: Set<AnyCancellable>!
    var capturedLoadingState: [Bool]!
    var capturedTransaction: InAppTransaction?
    var capturedSubscriptions: [SubscriptionOptionViewModel]!
    
    func instantiateSut(allProductsResult: Result<[SubscriptionProduct], Error>, purchaseProductResult: Result<InAppTransaction, Error>, onSuccessAction: @escaping (InAppTransaction?) -> Void) {
        fixture.getAvailableProductsUseCaseMock = GetAvailableProductsUseCaseMock(result: allProductsResult)
        fixture.purchaseProductUseCaseMock = PurchaseProductUseCaseMock(result: purchaseProductResult)
        sut = SignupViewModel(optionButtons: [],
                              getAvailableProducts: fixture.getAvailableProductsUseCaseMock,
                              purchaseProduct: fixture.purchaseProductUseCaseMock,
                              viewModelMapper: SubscriptionOptionViewModelMapper(), 
                              signupPresentableMapper: SignupPresentableErrorMapper(),
                              onSuccessAction: onSuccessAction)
    }
    
    override func setUp() {
        fixture = Fixture()
        cancellables = Set<AnyCancellable>()
        capturedLoadingState = []
        capturedSubscriptions = []
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        cancellables = nil
        capturedLoadingState = nil
        capturedSubscriptions = nil
        capturedTransaction = nil
    }
    
    func test_getproducts_presents_products_when_getAvailableProductsUseCase_returns_valid_products() {
        // GIVEN getAvailableProductsUseCase completes with valid SubscriptionProduct array
        let subscriptionProductStubs = SubscriptionProduct.makeStubs()
        instantiateSut(allProductsResult: .success(subscriptionProductStubs),
                       purchaseProductResult: .failure(NSError(domain: "anError", code: 0)),
                       onSuccessAction: { _ in })
        
        let expectation = expectation(description: "Waiting for subscriptionOptions to update")
        
        sut.$subscriptionOptions.dropFirst().sink(receiveValue: { [weak self] subscriptions in
            self?.capturedSubscriptions = subscriptions
            expectation.fulfill()
        }).store(in: &cancellables)
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN getproducts is executed
        sut.getproducts()
        
        // THEN subscriptionOptions is populated by a UI friendly array of subscriptions
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedSubscriptions.count, 2)
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
        XCTAssertEqual(sut.subtitle, "Start your 7 days free trial then 100.99$ per year.")
        XCTAssertFalse(sut.shouldShowErrorMessage)
    }
    
    func test_getproducts_presents_error_when_getAvailableProductsUseCase_returns_an_error() {
        // GIVEN getAvailableProductsUseCase completes with an error
        instantiateSut(allProductsResult: .failure(SubscriptionProductsError.generic),
                       purchaseProductResult: .failure(NSError(domain: "anError", code: 0)),
                       onSuccessAction: { _ in })
        let expectation = expectation(description: "Waiting for subscriptionOptions to update")
        
        sut.$subscriptionOptions.dropFirst().sink(receiveValue: { [weak self] subscriptions in
            self?.capturedSubscriptions = subscriptions
        }).store(in: &cancellables)
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN getproducts is executed
        sut.getproducts()
        
        // THEN shouldShowErrorMessage is true
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedSubscriptions.count, 0)
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertEqual(sut.subtitle, "Start your 7 days free trial then  per year.")
        //XCTAssertEqual(sut.errorMessage, "")
        XCTAssertTrue(sut.shouldShowErrorMessage)
    }
    
    func test_subscribe_executes_onSuccessAction_when_purchaseProductUseCase_returns_a_transaction() {
        // GIVEN purchaseProductUseCase returns a transaction
        let expectedTransaction = InAppTransactionMock.makeStub()
        let subscriptionProductStubs = SubscriptionProduct.makeStubs()
        
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(allProductsResult: .success(subscriptionProductStubs),
                       purchaseProductResult: .success(InAppTransactionMock.makeStub()),
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN capturedTransaction is the provided transaction
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(capturedTransaction?.identifier, expectedTransaction.identifier)
        XCTAssertEqual(capturedTransaction?.description, expectedTransaction.description)
        XCTAssertNil(capturedTransaction?.native)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertFalse(sut.shouldShowErrorMessage)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_subscribe_presents_an_error_alert_when_purchaseProductUseCase_throws_a_generic_PurchaseProductsError() {
        // GIVEN purchaseProductUseCase throws a generic PurchaseProductsError
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(allProductsResult: .success([]),
                       purchaseProductResult: .failure(PurchaseProductsError.generic),
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN error alert is presented with the text
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedTransaction)
        
        XCTAssertEqual(capturedLoadingState, [true, false])
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, "generic")
    }
    
    func test_subscribe_presents_an_error_alert_when_purchaseProductUseCase_throws_a_productNotFound_PurchaseProductsError() {
        // GIVEN purchaseProductUseCase throws a productNotFound PurchaseProductsError
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(allProductsResult: .success([]),
                       purchaseProductResult: .failure(PurchaseProductsError.productNotFound),
                       onSuccessAction: { _ in })
        
        sut.$shouldShowErrorMessage.dropFirst().sink(receiveValue: { value in
            expectation.fulfill()
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN error alert is presented with the text
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, "productNotFound")
    }
    
    func test_subscribe_presents_an_error_alert_when_purchaseProductUseCase_throws_an_uncreditedTransaction_PurchaseProductsError() {
        // GIVEN purchaseProductUseCase throws a generic PurchaseProductsError
        let expectation = expectation(description: "Waiting for subscribe to update")
        
        instantiateSut(allProductsResult: .success([]),
                       purchaseProductResult: .failure(PurchaseProductsError.uncreditedTransaction),
                       onSuccessAction: { [weak self] transaction in
            self?.capturedTransaction = transaction
            expectation.fulfill()
        })
        
        sut.$isLoading.dropFirst().sink(receiveValue: { [weak self] value in
            self?.capturedLoadingState.append(value)
        }).store(in: &cancellables)
        
        // WHEN subscribe is executed
        sut.subscribe()
        
        // THEN error alert is presented with the text "" and onSuccessAction is executed
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedTransaction)
        XCTAssertTrue(sut.shouldShowErrorMessage)
        XCTAssertEqual(sut.errorMessage, "uncreditedTransaction")
    }
}
