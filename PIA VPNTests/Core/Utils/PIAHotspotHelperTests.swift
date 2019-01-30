//
//  PIAHotspotHelperTests.swift
//  PIA VPNTests
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
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
}
