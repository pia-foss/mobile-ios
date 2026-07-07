//
//  InAppTransactionMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 30/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase
import PIALibrary

class InAppTransactionMock: InAppTransaction {
    var identifier: String
    var jwsRepresentation: JWS
    var native: Any?
    var description: String

    init(
        identifier: String,
        jwsRepresentation: JWS = JWS("mock-jws-transaction")!,
        native: Any? = nil,
        description: String
    ) {
        self.identifier = identifier
        self.jwsRepresentation = jwsRepresentation
        self.native = native
        self.description = description
    }
}
