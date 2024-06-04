//
//  PIATestSample.swift
//  PIA VPN
//
//  Created by Geneva Parayno on 30/5/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
import SnapshotTesting
import SnapshotTesting
import XCTest
@testable import PIA_VPN_tvOS

class YourUITests: XCTestCase {
    func testExample() {
        let view = WelcomeFactory.makeWelcomeView()
        let vc = UIHostingController(rootView: view)

        assertSnapshot(matching: vc, as: .image, record: true)
    }
}
