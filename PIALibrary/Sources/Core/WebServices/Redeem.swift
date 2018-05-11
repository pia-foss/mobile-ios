//
//  Redeem.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 5/8/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

struct Redeem {
    let email: String
    
    let code: String
    
    init(email: String, code: String) {
        self.email = email
        self.code = code
    }
}
