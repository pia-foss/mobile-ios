//
//  DecoratorProductsProviderTests.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import PIALibrary
@testable import PIA_VPN_tvOS

final class DecoratorProductsProviderTests: XCTestCase {
    class Fixture {
        var productsProviderMock: ProductsProviderMock!
        var subscriptionInformationProviderMock: SubscriptionInformationProviderMock!
        var storeSpy: InAppProviderSpy = InAppProviderSpy()
        var productConfigurationSpy = ProductConfigurationSpy()
    }
    
    var fixture: Fixture!
    var sut: DecoratorProductsProvider!
    
    func instantiateSut(productsProviderResult: ([Plan : InAppProduct]?, Error?), subscriptionInformationProviderResult: (PIA_VPN_tvOS.AppStoreInformation?, Error?)) {
        fixture.productsProviderMock = ProductsProviderMock(result: productsProviderResult)
        fixture.subscriptionInformationProviderMock = SubscriptionInformationProviderMock(result: subscriptionInformationProviderResult)
        sut = DecoratorProductsProvider(subscriptionInformationProvider: fixture.subscriptionInformationProviderMock,
                                        decoratee: fixture.productsProviderMock,
                                        store: fixture.storeSpy,
                                        productConfiguration: fixture.productConfigurationSpy)
    }
    
    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    func test_listPlanProducts_adds_nonLegacy_products_to_productConfiguration_when_there_is_valid_appstoreInformation() {
        // GIVEN subscriptionInformationProvider completes with valid AppStoreInformation with legacy products
        let productsStub = Product.makeStubs()
        let appStoreInformation = AppStoreInformation(products: productsStub, eligibleForTrial: false)
        let error: Error? = nil
        
        instantiateSut(productsProviderResult: (InAppProductMock.makeStubs(), error),
                       subscriptionInformationProviderResult: (appStoreInformation, error))

        let expectation = expectation(description: "Waiting for listPlanProducts to finish")
        
        // WHEN listPlanProducts is executed
        sut.listPlanProducts { _,_ in expectation.fulfill() }
       
        // THEN productConfigurationSpy captures non legacy products provided by subscriptionInformationProvider
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fixture.productConfigurationSpy.setPlanCalledAttempt, 2)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts.count, 2)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts[.monthly], productsStub[0].identifier)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts[.yearly], productsStub[1].identifier)
        
        // AND startObservingTransactions method from storeSpy is called
        XCTAssertEqual(fixture.storeSpy.startObservingTransactionsCalledAttempt, 1)
    }
    
    func test_listPlanProducts_adds_default_products_to_productConfiguration_when_there_is_no_valid_appstoreInformation() {
        // GIVEN subscriptionInformationProvider completes with an error
        let appStoreInformation: PIA_VPN_tvOS.AppStoreInformation? = nil
        let error: Error? = NSError(domain: "any error", code: 0)
        
        instantiateSut(productsProviderResult: (InAppProductMock.makeStubs(), error),
                       subscriptionInformationProviderResult: (appStoreInformation, error))
        
        let expectation = expectation(description: "Waiting for listPlanProducts to finish")
        
        // WHEN listPlanProducts is executed
        sut.listPlanProducts { _,_ in expectation.fulfill() }
        
        // THEN productConfigurationSpy captures default products provided
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(fixture.productConfigurationSpy.setPlanCalledAttempt, 2)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts.count, 2)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts[.monthly], AppConstants.InApp.monthlyProductIdentifier)
        XCTAssertEqual(fixture.productConfigurationSpy.capturedProducts[.yearly], AppConstants.InApp.yearlyProductIdentifier)
        
        // AND startObservingTransactions method from storeSpy is called
        XCTAssertEqual(fixture.storeSpy.startObservingTransactionsCalledAttempt, 1)
    }
    
    func test_listPlanProducts_complets_with_valid_products_when_decoratee_complets_with_valid_products() throws {
        // GIVEN subscriptionInformationProvider completes with an error
        // AND decoratee completes with valid products
        let productsStub = InAppProductMock.makeStubs()
        let appStoreInformation: PIA_VPN_tvOS.AppStoreInformation? = nil
        let error: Error? = nil
        let subscriptionInformationProviderResult = (appStoreInformation, NSError(domain: "any error", code: 0))
        
        instantiateSut(productsProviderResult: (productsStub, error),
                       subscriptionInformationProviderResult: subscriptionInformationProviderResult)
        
        var capturedProducts: [Plan : InAppProduct]?
        var capturedError: Error?
        let expectation = expectation(description: "Waiting for listPlanProducts to finish")
        
        // WHEN listPlanProducts is executed
        sut.listPlanProducts { products, error in
            capturedProducts = products
            capturedError = error
            expectation.fulfill()
        }
        
        // THEN listPlanProducts completes with provided products
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(capturedError)
        XCTAssertEqual(capturedProducts?.count, productsStub.count)
        XCTAssertEqual(capturedProducts?[.monthly]?.identifier, productsStub[.monthly]?.identifier)
        XCTAssertEqual(capturedProducts?[.monthly]?.price, productsStub[.monthly]?.price)
        XCTAssertEqual(capturedProducts?[.monthly]?.priceLocale, productsStub[.monthly]?.priceLocale)
        XCTAssertEqual(capturedProducts?[.monthly]?.description, productsStub[.monthly]?.description)
        XCTAssertNil(capturedProducts?[.monthly]?.native)
        
        XCTAssertEqual(capturedProducts?[.yearly]?.identifier, productsStub[.yearly]?.identifier)
        XCTAssertEqual(capturedProducts?[.yearly]?.price, productsStub[.yearly]?.price)
        XCTAssertEqual(capturedProducts?[.yearly]?.priceLocale, productsStub[.yearly]?.priceLocale)
        XCTAssertEqual(capturedProducts?[.yearly]?.description, productsStub[.yearly]?.description)
        XCTAssertNil(capturedProducts?[.yearly]?.native)
    }
    
    func test_listPlanProducts_complets_with_error_when_decoratee_complets_with_error() throws {
        // GIVEN subscriptionInformationProvider completes with an error
        // AND decoratee completes with an error
        let productsStub = InAppProductMock.makeStubs()
        let appStoreInformation: PIA_VPN_tvOS.AppStoreInformation? = nil
        let error = NSError(domain: "any error", code: 0)
        let subscriptionInformationProviderResult = (appStoreInformation, error)
        
        instantiateSut(productsProviderResult: (productsStub, error),
                       subscriptionInformationProviderResult: subscriptionInformationProviderResult)
        
        var capturedError: Error?
        let expectation = expectation(description: "Waiting for listPlanProducts to finish")
        
        // WHEN listPlanProducts is executed
        sut.listPlanProducts { products, error in
            capturedError = error
            expectation.fulfill()
        }
        
        // THEN listPlanProducts completes with an error
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(error, capturedError as? NSError)
    }
}
