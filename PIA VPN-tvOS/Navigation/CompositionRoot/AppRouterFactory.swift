//
//  AppRouterFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class AppRouterFactory {
    static func makeAppRouter() -> AppRouter {
        return AppRouter.shared
    }
}
