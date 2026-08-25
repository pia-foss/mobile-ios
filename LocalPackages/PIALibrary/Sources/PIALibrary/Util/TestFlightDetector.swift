//
//  TestFlightDetector.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 01/12/25.
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

import Foundation

public protocol TestFlightDetectorProtocol {
    var isTestFlight: Bool { get }
}

public struct TestFlightDetector: TestFlightDetectorProtocol {
    public static let shared = TestFlightDetector()

    public init() {}

    /// Checks if app is running in TestFlight
    public var isTestFlight: Bool {
        #if targetEnvironment(macCatalyst)
            return hasStoreReceipt && hasProvisioningProfile
        #else
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }

    #if targetEnvironment(macCatalyst)
        private var hasStoreReceipt: Bool {
            bundleContentsContain("_MASReceipt/receipt")
        }

        private var hasProvisioningProfile: Bool {
            bundleContentsContain("embedded.provisionprofile")
        }

        private func bundleContentsContain(_ relativePath: String) -> Bool {
            let url = Bundle.main.bundleURL
                .appendingPathComponent("Contents", isDirectory: true)
                .appendingPathComponent(relativePath)
            return FileManager.default.fileExists(atPath: url.path)
        }
    #endif
}
