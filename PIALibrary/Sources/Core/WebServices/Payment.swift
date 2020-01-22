//
//  Payment.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct Payment {
    let receipt: Data
    
    var marketing: [String: Any]?

    var debug: [String: Any]?
    
    init(receipt: Data) {
        self.receipt = receipt
    }
}

#if os(iOS)
extension RenewRequest {
    func payment(withStore store: InAppProvider) -> Payment? {
        guard let receipt = store.paymentReceipt else {
            return nil
        }
        var object = Payment(receipt: receipt)
        object.marketing = marketing
        if let txid = transaction?.identifier {
            object.debug = ["txid": txid]
        }
        return object
    }
}
#endif
