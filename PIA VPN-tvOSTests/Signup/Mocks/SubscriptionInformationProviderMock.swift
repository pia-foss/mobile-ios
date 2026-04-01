//
//  SubscriptionInformationProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class SubscriptionInformationProviderMock: SubscriptionInformationProviderType {
    private let result: (AppStoreInformation?, Error?)
    
    init(result: (AppStoreInformation?, Error?)) {
        self.result = result
    }
    
    func subscriptionInformation(_ callback: @escaping (AppStoreInformation?, Error?) -> Void) {
        callback(result.0, result.1)
    }
}
