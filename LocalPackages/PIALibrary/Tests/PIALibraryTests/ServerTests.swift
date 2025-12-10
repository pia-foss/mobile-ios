//
//  ServerTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 12/10/17.
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
import SwiftyBeaver

class ServerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        SwiftyBeaver.addDestination(ConsoleDestination())

        Client.providers.vpnProvider = MockVPNProvider()
        Client.configuration.enablesServerUpdates = false
        Client.configuration.verifiesServersSignature = true
        Client.bootstrap()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//    func testRawDownload() {
//        let exp = expectation(description: "download")
//
//        PIAWebServices().downloadServers { (bundle, error) in
//            guard let _ = bundle else {
//                print("Download error: \(error!)")
//                XCTAssert(error as? ClientError != .badServersSignature, "Bad signature")
//                XCTAssert(false)
//                exp.fulfill()
//                return
//            }
//            XCTAssertNotNil(bundle)
//            print("Downloaded server bundle: \(bundle!)")
//            exp.fulfill()
//        }
//        waitForExpectations(timeout: 5.0, handler: nil)
//    }

    func testMockDownload() {
        __testProviderDownload(factory: MockProviders())
    }
    
    func testOfflineServers() {
        __testProviderDownload(factory: MockProviders())
        XCTAssertTrue(Client.providers.serverProvider.currentServers.filter({$0.offline == true}).count == 1)
    }

    private func __testProviderDownload(factory: Client.Providers) {
        let exp = expectation(description: "download")
        
        factory.serverProvider.download { (servers, error) in
            guard let _ = servers else {
                print("Download error: \(error!)")
                XCTAssert(error as? ClientError != .badServersSignature, "Bad signature")
                XCTAssert(false)
                exp.fulfill()
                return
            }
            XCTAssertNotNil(servers)
            print("Downloaded servers: \(servers!)")
            XCTAssertEqual(servers?.count, factory.serverProvider.currentServers.count) // soft
            exp.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}
