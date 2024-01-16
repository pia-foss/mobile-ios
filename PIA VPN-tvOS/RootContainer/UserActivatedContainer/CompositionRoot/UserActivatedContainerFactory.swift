//
//  UserActivatedContainerFactory.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/12/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class UserActivatedContainerFactory {
    static func makeUSerActivatedContainerView() -> UserActivatedContainerView {
        return UserActivatedContainerView(router: AppRouterFactory.makeAppRouter())
    }
}
