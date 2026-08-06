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
    }

    override func tearDown() {
        Client.database.truncate()
        super.tearDown()
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

    func testPreConsentResetCommitDoesNotWipeVersionWhenServiceQualityOptedBeforeLogout() {
        let preferences = Client.preferences.editable()
        preferences.hasRespondedToServiceQualityConsent = true
        preferences.shareServiceQualityData = true
        preferences.versionWhenServiceQualityOpted = "1.2.3"
        preferences.commit()

        // Mirrors `AppPreferences.reset()`, which `DashboardViewController.closeSession()` runs
        // before `accountProvider.logout(nil)` on every real logout — i.e. before cleanDatabase()
        // ever reaches the entries-preserved-across-reset list below.
        Client.preferences.editable().reset().commit()

        mock.accountProvider.cleanDatabase()

        XCTAssertEqual(
            Client.preferences.versionWhenServiceQualityOpted,
            "1.2.3",
            "The pre-logout preferences reset must not silently wipe the opted-in version before cleanDatabase() runs"
        )
    }

    func testHasExplicitShareServiceQualityDataValueDetectsAnExplicitReject() {
        // An explicit reject (shareServiceQualityData = false) must still count as "answered" —
        // it must not collapse to the same signal as never having been asked.
        let preferences = Client.preferences.editable()
        preferences.shareServiceQualityData = false
        preferences.commit()

        XCTAssertTrue(Client.preferences.hasExplicitShareServiceQualityDataValue)
    }

    func testHasExplicitShareServiceQualityDataValueIsFalseBeforeAnyAnswer() {
        // setUp() truncates the suite, so this runs against a genuinely unwritten key.
        XCTAssertFalse(Client.preferences.hasExplicitShareServiceQualityDataValue)
    }
}
