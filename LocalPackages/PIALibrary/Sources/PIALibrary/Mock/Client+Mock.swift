//
//  Client+Mock.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
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

extension Client {

    /**
     Uses a mock `AccountProvider`.

     - Parameter provider: The `MockAccountProvider` to use (optional).
     */
    public static func useMockAccountProvider(_ provider: MockAccountProvider = MockAccountProvider()) {
        providers.accountProvider = provider
    }

    /**
     Uses a mock `ServerProvider`.
     
     - Parameter provider: The `MockServerProvider` to use (optional).
     */
    public static func useMockServerProvider(_ provider: MockServerProvider = MockServerProvider()) {
        providers.serverProvider = provider
    }
    
    /**
     Uses a mock `VPNProvider`.
     
     - Parameter provider: The `MockVPNProvider` to use (optional).
     */
    public static func useMockVPNProvider(_ provider: MockVPNProvider = MockVPNProvider()) {
        providers.vpnProvider = provider
    }

    /**
     Uses a mock `TileProvider`.
     
     - Parameter provider: The `TileProvider` to use (optional).
     */
    public static func useMockTileProvider(_ provider: TileProvider = MockTileProvider()) {
        providers.tileProvider = provider
    }
    
    #if os(iOS) || os(tvOS)
    /**
     Uses a mock in-app provider for testing purchases.
     */
    public static func useMockInAppProvider() {
        store = MockInAppProvider(with: Data())
    }
    
    public static func useMockInAppProviderWithoutReceipt() {
        store = MockInAppProvider(with: nil)
    }
    
    public static func useMockInAppProviderWithReceipt() {
        store = MockInAppProvider(with: "abcdefg".data(using: .utf8))
    }
    #endif
}
