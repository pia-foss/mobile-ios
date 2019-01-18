//
//  MockProviders.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

let MockProviders: () -> Client.Providers = {
    Client.useMockAccountProvider()
    Client.useMockServerProvider()
    Client.useMockVPNProvider()
    Client.useMockTileProvider()
    #if os(iOS)
    Client.useMockInAppProvider()
    #endif
    return Client.providers
}
