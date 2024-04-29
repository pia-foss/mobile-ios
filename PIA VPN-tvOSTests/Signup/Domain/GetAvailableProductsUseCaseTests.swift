//
//  GetAvailableProductsUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 18/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class GetAvailableProductsUseCaseTests: XCTestCase {
    class Fixture {
        var productsProviderMock: ProductsProviderMock!
    }
    
    var fixture: Fixture!
    var sut: GetAvailableProductsUseCase!
    
    func instantiateSut(productsProviderResult: ([Plan : InAppProduct]?, Error?)) {
        fixture.productsProviderMock = ProductsProviderMock(result: productsProviderResult)
        sut = GetAvailableProductsUseCase(productsProvider: fixture.productsProviderMock)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    func test_getAllProducts_returns_monthly_and_yearly_subscriptions_when_productsProvider_returns_monthly_and_yearly_subscriptions() async throws {
        // GIVEN productsProvider completes with valid products
        let stub = InAppProductMock.makeStubs()
        instantiateSut(productsProviderResult: (stub, nil))
        
        // WHEN getAllProducts is executed
        let result = try await sut.getAllProducts()
        
        // THEN getAllProducts returns the provided mohtly and yearly products
        XCTAssertEqual(result.count, stub.count)
        let monthlyProduct: InAppProduct = result[0].type == .monthly ? result[0].product : result[1].product
        let yearlyProduct: InAppProduct = result[1].type == .yearly ? result[1].product : result[0].product
        
        XCTAssertEqual(monthlyProduct.identifier, stub[.monthly]?.identifier)
        XCTAssertEqual(monthlyProduct.price, stub[.monthly]?.price)
        XCTAssertEqual(monthlyProduct.priceLocale, stub[.monthly]?.priceLocale)
        XCTAssertEqual(monthlyProduct.description, stub[.monthly]?.description)
        XCTAssertNil(monthlyProduct.native)
        
        XCTAssertEqual(yearlyProduct.identifier, stub[.yearly]?.identifier)
        XCTAssertEqual(yearlyProduct.price, stub[.yearly]?.price)
        XCTAssertEqual(yearlyProduct.priceLocale, stub[.yearly]?.priceLocale)
        XCTAssertEqual(yearlyProduct.description, stub[.yearly]?.description)
        XCTAssertNil(yearlyProduct.native)
    }

    func test_getAllProducts_throws_error_when_productsProvider_returns_an_error() async throws {
        // GIVEN productsProvider completes completes with an error
        let stub: [Plan : InAppProduct]? = nil
        let error = NSError(domain: "any error", code: 0)
        instantiateSut(productsProviderResult: (stub, error))
        
        var capturedError: Error?
        
        // WHEN getAllProducts is executed
        do {
            _ = try await sut.getAllProducts()
            XCTFail("Expected to throw an error")
        } catch {
            capturedError = error
        }
        
        // THEN getAllProducts throws an generic error
        let subscriptionProductsError = try XCTUnwrap(capturedError as? SubscriptionProductsError)
        XCTAssertEqual(subscriptionProductsError, .generic)
    }
}
