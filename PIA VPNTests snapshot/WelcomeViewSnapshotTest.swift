//
//  WelcomeViewSnapshotTest.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 6/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest
@testable import PIA_VPN_tvOS
import SwiftUI
import SnapshotTesting

final class WelcomeViewSnapshotTest: XCTestCase {
    func test_Welcome() {
        let view = WelcomeFactory.makeWelcomeView()
        let vc = UIHostingController(rootView: view)
        
        assertSnapshot(matching: vc, as: .image, record: false)
    }
}
