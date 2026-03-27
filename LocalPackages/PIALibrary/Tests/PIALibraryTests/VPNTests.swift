//
//  VPNTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

class VPNTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        Client.providers.vpnProvider = MockVPNProvider()

        let prefs = Client.preferences.editable()
        prefs.vpnDisconnectsOnSleep = true
        prefs.commit()

        Client.bootstrap()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func _testDebugLogSubmission() async throws {
        let reportIdentifier = try await PIAWebServices().submitDebugReport()
        XCTAssertFalse(reportIdentifier.isEmpty)
    }
}
