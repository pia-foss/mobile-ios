//
//  NMTTests.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 27/07/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import XCTest
import PIALibrary
@testable import PIA_VPN

class NMTTests: XCTestCase {

    func testMigration() throws {

        resetMigration()
        
        AppPreferences.shared.migrateNMT()
        
        XCTAssertTrue(Client.preferences.nmtRulesEnabled == false, "NMT are disabled by default")
        
        resetMigration()
        var preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = true
        preferences.commit()

        AppPreferences.shared.migrateNMT()

        XCTAssertTrue(Client.preferences.nmtRulesEnabled == true, "NMT are enabled after the migration")

        resetMigration()
        preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = true
        preferences.trustCellularData = true
        preferences.useWiFiProtection = false
        preferences.commit()

        AppPreferences.shared.migrateNMT()

        XCTAssertTrue(Client.preferences.nmtRulesEnabled == true, "NMT are enabled after the migration")
        XCTAssertTrue(Client.preferences.nmtGenericRules[NMTType.cellular.rawValue] == NMTRules.alwaysDisconnect.rawValue, "NMT for cellular is alwaysDisconnect.")
        XCTAssertTrue(Client.preferences.nmtGenericRules[NMTType.protectedWiFi.rawValue] == NMTRules.alwaysConnect.rawValue, "NMT for protected wifi is alwaysConnect.")

        resetMigration()
        preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = true
        preferences.trustedNetworks = ["WIFI1", "WIFI2"]
        preferences.commit()

        AppPreferences.shared.migrateNMT()

        XCTAssertTrue(Client.preferences.nmtRulesEnabled == true, "NMT are enabled after the migration")
        XCTAssertTrue(Client.preferences.nmtTrustedNetworkRules["WIFI1"] == NMTRules.alwaysDisconnect.rawValue, "NMT for WIFI1 is alwaysDisconnect")
        XCTAssertTrue(Client.preferences.nmtTrustedNetworkRules["WIFI2"] == NMTRules.alwaysDisconnect.rawValue, "NMT for WIFI2 is alwaysDisconnect")

    }

    private func resetMigration() {
        let preferences = Client.preferences.editable()
        preferences.reset()
        preferences.nmtMigrationSuccess = false
        preferences.commit()
    }

}
