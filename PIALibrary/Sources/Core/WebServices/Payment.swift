//
//  Payment.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
