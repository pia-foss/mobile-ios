//
//  PIA_VPN_tvOSApp.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 22/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

@main
struct PIA_VPN_tvOSApp: App {
    var body: some Scene {
        WindowGroup {
            RootContainerFactory.makeRootContainerView()
        }
    }
}
