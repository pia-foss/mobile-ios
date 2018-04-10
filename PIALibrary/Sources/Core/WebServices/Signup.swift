//
//  Signup.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

struct Signup {
    let email: String

    let receipt: Data
    
    var marketing: [String: Any]?

    var debug: [String: Any]?

    init(email: String, receipt: Data) {
        self.email = email
        self.receipt = receipt
    }
}

#if os(iOS)
extension SignupRequest {
    func signup(withStore store: InAppProvider) -> Signup? {
        guard let receipt = store.paymentReceipt else {
            return nil
        }
        var object = Signup(email: email, receipt: receipt)
        object.marketing = marketing
        if let txid = transaction?.identifier {
            object.debug = ["txid": txid]
        }
        return object
    }
}
#endif
