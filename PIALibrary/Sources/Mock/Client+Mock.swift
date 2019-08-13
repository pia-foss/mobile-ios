//
//  Client+Mock.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    
    #if os(iOS)
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
