//
//  PIAHotspotHelperTests.swift
//  PIA VPNTests
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
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
import PIALibrary
@testable import PIA_VPN

class PIAHotspotHelperTests: XCTestCase {

    private var hotspotHelper: PIAHotspotHelper!
    
    override func setUp() {
        super.setUp()
        hotspotHelper = PIAHotspotHelper()
    }

    override func tearDown() {
        hotspotHelper = nil
        super.tearDown()
    }
    
    func testRetrieveCurrentNetworkListIsEmpty() {
        XCTAssertTrue(hotspotHelper.retrieveCurrentNetworkList().isEmpty)
    }
    
    func testTrustedNetworkArray() {
        var trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.isEmpty)
        let currentSSID = "WIFI_HOME_5G"
        hotspotHelper.saveTrustedNetwork(currentSSID)
        trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.count == 1)
        hotspotHelper.clearTrustedNetworkList()
        trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.isEmpty)
    }
    
    func testRemoveTrustedNetworkArray() {
        hotspotHelper.clearTrustedNetworkList()
        var trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.isEmpty)
        let currentSSID = "WIFI_HOME_5G"
        hotspotHelper.saveTrustedNetwork(currentSSID)
        trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.count == 1)
        hotspotHelper.removeTrustedNetwork(currentSSID)
        trustedNetworks = hotspotHelper.trustedNetworks()
        XCTAssertTrue(trustedNetworks.isEmpty)

    }
    
    func testConfiguration() {
        var pref = Client.preferences.editable()
        pref.nmtRulesEnabled = true
        pref.commit()
        
        var response = hotspotHelper.configureHotspotHelper()
        XCTAssertTrue(response)
        
        pref = Client.preferences.editable()
        pref.nmtRulesEnabled = false
        pref.commit()
        
        response = hotspotHelper.configureHotspotHelper()
        XCTAssertFalse(response)
    }
}
