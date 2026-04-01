//
//  EndpointManagerTests.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 15/09/2020.
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
@testable import PIALibrary

class EndpointManagerTests: XCTestCase {
    
    private var servers: [Server]!
    
    override func setUpWithError() throws {
        
        let bundle = Bundle(for: EndpointManagerTests.self)
        guard let bundledRegionsURL = bundle.url(forResource: "server", withExtension: "json") else {
            fatalError("Could not find bundled regions file")
        }
        let bundledServersJSON: Data
        do {
            try bundledServersJSON = Data(contentsOf: bundledRegionsURL)
        } catch let e {
            fatalError("Could not parse bundled regions file: \(e)")
        }

        Client.providers.serverProvider.loadLocalJSON(fromJSON: bundledServersJSON)

    }

    func testGEN4Endpoints() throws {
        
        ServersPinger.shared.ping(withDestinations: Client.providers.serverProvider.currentServers)
        
        eventually(timeout: 10.0) {
            let endpoints = EndpointManager.shared.availableEndpoints()
            XCTAssertTrue(endpoints.count == 4)
        }

    }

}

extension XCTestCase {

    /// Simple helper for asynchronous testing.
    /// Usage in XCTestCase method:
    ///   func testSomething() {
    ///       doAsyncThings()
    ///       eventually {
    ///           /* XCTAssert goes here... */
    ///       }
    ///   }
    /// Cloure won't execute until timeout is met. You need to pass in an
    /// timeout long enough for your asynchronous process to finish, if it's
    /// expected to take more than the default 0.01 second.
    ///
    /// - Parameters:
    ///   - timeout: amout of time in seconds to wait before executing the
    ///              closure.
    ///   - closure: a closure to execute when `timeout` seconds has passed
    func eventually(timeout: TimeInterval = 0.01, closure: @escaping () -> Void) {
        let expectation = self.expectation(description: "")
        expectation.fulfillAfter(timeout)
        self.waitForExpectations(timeout: 60) { _ in
            closure()
        }
    }
}

extension XCTestExpectation {

    /// Call `fulfill()` after some time.
    ///
    /// - Parameter time: amout of time after which `fulfill()` will be called.
    func fulfillAfter(_ time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.fulfill()
        }
    }
}
