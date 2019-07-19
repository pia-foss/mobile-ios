//
//  ServerTests.swift
//  PIALibraryTests
//
//  Created by Davide De Rosa on 12/10/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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

    //    func testWebDownload() {
//        __testProviderDownload(factory: Client.Providers())
//    }

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
    
//    func testSelection() {
//        let cached = Client.providers.serverProvider.currentServers
//        guard !cached.isEmpty else {
//            return
//        }
//
//        let selected = cached[Int(arc4random()) % cached.count]
//        Client.preferences.editable().preferredServer = selected
//    }
}
