//
//  SubscriptionInformationProviderType.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol SubscriptionInformationProviderType {
    func subscriptionInformation(_ callback: @escaping (AppStoreInformation?, Error?) -> Void)
}
