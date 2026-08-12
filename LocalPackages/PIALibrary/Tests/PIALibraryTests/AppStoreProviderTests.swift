//
//  AppStoreProviderTests.swift
//  PIALibraryTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest

@testable import PIALibrary

#if os(iOS) || os(tvOS)

    class AppStoreProviderTests: XCTestCase {

        private var sut: AppStoreProvider!

        override func setUp() {
            super.setUp()
            sut = AppStoreProvider()
        }

        override func tearDown() {
            sut = nil
            super.tearDown()
        }

        func testCacheAvailableProducts_WHEN_productsAreEmptyAndCacheIsUnset_THEN_cacheStaysUnset() {
            // GIVEN a provider that has never successfully fetched
            XCTAssertNil(sut.availableProducts)

            // WHEN the store returns no products
            sut.cacheAvailableProducts([])

            // THEN the cache stays nil, so the next `listPlanProducts()` re-requests from the store
            // instead of serving a non-nil empty dictionary as a cache hit forever.
            XCTAssertNil(sut.availableProducts)
        }

        func testCacheAvailableProducts_WHEN_productsAreEmptyAndCacheIsPopulated_THEN_cacheIsKept() {
            // GIVEN a previously cached product
            sut.cacheAvailableProducts([MockProduct("com.privateinternetaccess.subscription.1year", 50)])

            // WHEN a later fetch returns nothing
            sut.cacheAvailableProducts([])

            // THEN the good cache survives the transient failure
            XCTAssertEqual(sut.availableProducts?.count, 1)
            XCTAssertEqual(sut.availableProducts?.first?.identifier, "com.privateinternetaccess.subscription.1year")
        }

        func testCacheAvailableProducts_WHEN_productsAreNotEmpty_THEN_cacheIsReplaced() {
            // GIVEN a previously cached product
            sut.cacheAvailableProducts([MockProduct("com.privateinternetaccess.subscription.1month", 10)])

            // WHEN a fresh fetch returns products
            sut.cacheAvailableProducts([
                MockProduct("com.privateinternetaccess.subscription.1year", 50),
                MockProduct("com.privateinternetaccess.subscription.1month", 10)
            ])

            // THEN they replace the previous cache
            XCTAssertEqual(sut.availableProducts?.count, 2)
        }
    }

#endif
