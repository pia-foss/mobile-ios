//
//  ServiceQualityConsentTests.swift
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

class ServiceQualityConsentTests: XCTestCase {
    private let mock = MockProviders()

    override func setUp() {
        super.setUp()

        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
        Client.bootstrap()
        Client.providers.accountProvider.cleanDatabase()
    }

    func testCleanDatabasePreservesServiceQualityConsentDecision() {
        let preferences = Client.preferences.editable()
        preferences.hasRespondedToServiceQualityConsent = true
        preferences.shareServiceQualityData = true
        preferences.versionWhenServiceQualityOpted = "1.2.3"
        preferences.debugLogging = true
        preferences.commit()

        mock.accountProvider.cleanDatabase()

        XCTAssertTrue(
            Client.preferences.hasRespondedToServiceQualityConsent,
            "Logging out must not re-trigger the consent screen for a user who already answered it"
        )
        XCTAssertTrue(
            Client.preferences.shareServiceQualityData,
            "The consent decision itself must survive too, or an accepted user is silently flipped to opted-out"
        )
        XCTAssertEqual(Client.preferences.versionWhenServiceQualityOpted, "1.2.3")
        XCTAssertFalse(
            Client.preferences.debugLogging,
            "Sanity check: cleanDatabase() should still reset unrelated preferences"
        )
    }
}
