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
    }

    func test_purchase_completes_with_uncreditedTransaction_error_when_store_has_uncredited_transactions() throws {
        // GIVEN store has uncredited transactions
        fixture.storeSpy.hasUncreditedTransactions = true
        
        let transactionStub = InAppTransactionMock.makeStub()
        let error: Error? = nil
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))

        let expectation = expectation(description: "Waiting for purchase to finish")
        var capturedResult: Result<InAppTransaction, Error>?
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with an hasUncreditedTransactions error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        let purchaseProductsError = try XCTUnwrap(capturedError as? PurchaseProductsError)
        XCTAssertEqual(purchaseProductsError, .uncreditedTransaction)
    }
    
    func test_purchase_completes_with_transaction_when_store_has_no_uncredited_transactions_and_purchaseProvider_completes_with_transaction_and_no_error() throws {
        // GIVEN store has no uncredited transactions
        fixture.storeSpy.hasUncreditedTransactions = false
        
        // AND purchaseProvider completes with transaction and no error
        let transactionStub = InAppTransactionMock.makeStub()
        let error: Error? = nil
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))

        let expectation = expectation(description: "Waiting for purchase to finish")
        var capturedResult: Result<InAppTransaction, Error>?
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { result in
            capturedResult = result
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
    
    func test_purchase_completes_with_error_when_store_has_no_uncredited_transactions_and_purchaseProvider_completes_with_no_transaction_and_an_error() throws {
        // GIVEN store has no uncredited transactions
        fixture.storeSpy.hasUncreditedTransactions = false
        
        // AND purchaseProvider completes with no transaction an error
        let transactionStub: InAppTransactionMock? = nil
        let error = NSError(domain: "anError", code: 0)
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))

        let expectation = expectation(description: "Waiting for purchase to finish")
        var capturedResult: Result<InAppTransaction, Error>?
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        let purchaseProductsError = try XCTUnwrap(capturedError as? PurchaseProductsError)
        XCTAssertEqual(purchaseProductsError, .generic)
    }
    
    func test_purchase_completes_with_error_when_store_has_no_uncredited_transactions_and_purchaseProvider_completes_with_no_transaction_and_no_error() throws {
        // GIVEN store has no uncredited transactions
        fixture.storeSpy.hasUncreditedTransactions = false
        
        // AND purchaseProvider completes with no transaction and no error
        let transactionStub: InAppTransactionMock? = nil
        let error: Error? = nil
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))

        let expectation = expectation(description: "Waiting for purchase to finish")
        var capturedResult: Result<InAppTransaction, Error>?
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        let purchaseProductsError = try XCTUnwrap(capturedError as? PurchaseProductsError)
        XCTAssertEqual(purchaseProductsError, .generic)
    }
    
    func test_purchase_completes_with_error_when_store_has_no_uncredited_transactions_and_purchaseProvider_completes_with_a_transaction_and_an_error() throws {
        // GIVEN store has no uncredited transactions
        fixture.storeSpy.hasUncreditedTransactions = false
        
        // AND purchaseProvider completes with a transaction and an error
        let transactionStub = InAppTransactionMock.makeStub()
        let error = NSError(domain: "anError", code: 0)
        
        instantiateSut(purchaseProductsAccountProviderResult: (transactionStub, error))

        let expectation = expectation(description: "Waiting for purchase to finish")
        var capturedResult: Result<InAppTransaction, Error>?
        
        // WHEN purchase is executed
        sut.purchase(subscriptionOption: .monthly) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // THEN completes with a generic error
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let capturedError) = capturedResult else {
            XCTFail("Expected failure, got success")
            return
        }
        
        let purchaseProductsError = try XCTUnwrap(capturedError as? PurchaseProductsError)
        XCTAssertEqual(purchaseProductsError, .generic)
    }

}
