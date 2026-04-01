//
//  InAppTransactionMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 30/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class InAppTransactionMock: InAppTransaction {
    var identifier: String?
    var native: Any?
    var description: String
    
    init(identifier: String? = nil, native: Any? = nil, description: String) {
        self.identifier = identifier
        self.native = native
        self.description = description
    }
}
