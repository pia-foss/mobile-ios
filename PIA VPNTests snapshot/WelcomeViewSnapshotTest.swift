//
//  WelcomeViewSnapshotTest.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 6/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import PIA_VPN_tvOS

final class WelcomeViewSnapshotTest: XCTestCase {
    private let snapshotPrecision: Float = 0.99

    func test_Welcome() {
        let view = WelcomeFactory.makeWelcomeView()
        let vc = UIHostingController(rootView: view)

        assertSnapshot(matching: vc, as: .image(precision: snapshotPrecision), record: false)
    }
}
