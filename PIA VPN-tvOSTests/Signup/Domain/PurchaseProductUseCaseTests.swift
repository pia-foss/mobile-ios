//
//  PurchaseProductUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 28/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import PIALibrary

final class PurchaseProductUseCaseTests: XCTestCase {
    class Fixture {
        var purchaseProductsProviderMock: PurchaseProductsProviderMock!
    }
    
    var fixture: Fixture!
    var sut: PurchaseProductUseCase!
    
    func instantiateSut(purchaseProductsProviderResult: Result<InAppTransaction, PurchaseProductsError>) {
        fixture.purchaseProductsProviderMock = PurchaseProductsProviderMock(result: purchaseProductsProviderResult)
        sut = PurchaseProductUseCase(purchaseProductsProvider: fixture.purchaseProductsProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_purchaseProduct_returns_a_transaction_when_purchaseProductsProvider_completes_with_a_transaction() async throws {
        // GIVEN purchaseProductsProvider completes with a transaction
        let stub = InAppTransactionMock.makeStub()
        instantiateSut(purchaseProductsProviderResult: .success(stub))
        
        // WHEN purchaseProduct is executed
        let result = try await sut(subscriptionOption: .monthly)
        
        // THEN purchaseProduct returns the provided transaction
        XCTAssertEqual(result.identifier, stub.identifier)
        XCTAssertEqual(result.description, stub.description)
        XCTAssertNil(result.native)
    }

    func test_purchaseProduct_throws_an_error_when_purchaseProductsProvider_completes_with_an_error() async throws {
        // GIVEN productsProvider completes with an generic error
        let expectedError = NSError(domain: "any error", code: 0)
        instantiateSut(purchaseProductsProviderResult: .failure(.generic))
        
        do {
            // WHEN signup is executed
            _ = try await sut(subscriptionOption: .monthly)
            XCTFail("Expected to throw an error")
        } catch {
            // THEN signup throws an generic error
            let purchaseProductsError = try XCTUnwrap(error as? PurchaseProductsError)
            XCTAssertEqual(purchaseProductsError, .generic)
        }
    }
}
