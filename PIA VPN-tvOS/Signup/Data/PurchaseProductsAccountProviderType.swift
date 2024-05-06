//
//  PurchaseProductsAccountProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 24/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol PurchaseProductsAccountProviderType {
    func purchase(plan: Plan, _ callback: LibraryCallback<InAppTransaction>?)
}
