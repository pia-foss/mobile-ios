//
//  ProductsProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 19/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class ProductsProviderMock: ProductsProviderType {
    private let result: ([Plan : InAppProduct]?, Error?)
    
    init(result: ([Plan : InAppProduct]?, Error?)) {
        self.result = result
    }
    
    func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        callback?(result.0, result.1)
    }
}
