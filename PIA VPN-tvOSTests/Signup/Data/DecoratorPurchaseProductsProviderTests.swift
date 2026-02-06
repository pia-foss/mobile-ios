//
//  DecoratorPurchaseProductsProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

final class DecoratorPurchaseProductsProviderTests: XCTestCase {
    class Fixture {
        var storeSpy: InAppProviderSpy = InAppProviderSpy()
        var purchaseProductsAccountProviderMock: PurchaseProductsAccountProviderMock!
    }
    
    var fixture: Fixture!
    var sut: DecoratorPurchaseProductsProvider!
    var capturedResult: Result<InAppTransaction, PurchaseProductsError>!
    
    func instantiateSut(purchaseProductsAccountProviderResult: (InAppTransaction?, Error?)) {
        fixture.purchaseProductsAccountProviderMock = PurchaseProductsAccountProviderMock(result: purchaseProductsAccountProviderResult)
        sut = DecoratorPurchaseProductsProvider(purchaseProductsProvider: fixture.purchaseProductsAccountProviderMock,
                                                errorMapper: PurchaseProductDomainErrorMapper(),
                                                store: fixture.storeSpy)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
        capturedResult = nil
    }

    func test_purchase_succeeds_when_provider_returns_transaction_without_error() throws {
        // GIVEN purchaseProvider completes with transaction and no error
        let transactionStub = InAppTransactionMock.makeStub()
        let error: Error? = nil
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))
        let expectation = expectation(description: "Waiting for purchase to finish")
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a transaction
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let capturedTransaction) = capturedResult else {
            XCTFail("Expected success, got failure")
            return
        }
        
        XCTAssertEqual(capturedTransaction.identifier, transactionStub.identifier)
        XCTAssertEqual(capturedTransaction.description, transactionStub.description)
        XCTAssertNil(capturedTransaction.native)
    }
    
    func test_purchase_fails_with_generic_error_when_provider_returns_error_without_transaction() throws {
        // GIVEN purchaseProvider completes with no transaction an error
        let transactionStub: InAppTransactionMock? = nil
        let error = NSError(domain: "anError", code: 0)
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))
        let expectation = expectation(description: "Waiting for purchase to finish")
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(capturedError, .generic)
    }
    
    func test_purchase_fails_with_generic_error_when_provider_returns_neither_transaction_nor_error() throws {
        // GIVEN purchaseProvider completes with no transaction and no error
        let transactionStub: InAppTransactionMock? = nil
        let error: Error? = nil
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))
        let expectation = expectation(description: "Waiting for purchase to finish")
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(capturedError, .generic)
    }
    
    func test_purchase_fails_with_generic_error_when_provider_returns_both_transaction_and_error() throws {
        // GIVEN purchaseProvider completes with a transaction and an error
        let transactionStub = InAppTransactionMock.makeStub()
        let error = NSError(domain: "anError", code: 0)
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))
        let expectation = expectation(description: "Waiting for purchase to finish")
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { [weak self] result in
            self?.capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        XCTAssertEqual(capturedError, .generic)
    }
}
