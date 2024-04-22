//
//  AppStoreInformation.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 18/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

public struct Product {
    public let identifier: String
    public let plan: Plan
    public let price: String
    public let legacy: Bool
}

public struct AppStoreInformation {
    public let products: [Product]
    public let eligibleForTrial: Bool
}
