//
//  UserAccount.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation

struct UserAccount {
    let credentials: Credentials
    let info: AccountInfo?

    var isRenewable: Bool {
        return info?.isRenewable ?? false
    }

    init(credentials: Credentials, info: AccountInfo?) {
        self.credentials = credentials
        self.info = info
    }
}

extension UserAccount: Equatable {
    public static func == (lhs: UserAccount, rhs: UserAccount) -> Bool {
        lhs.credentials == rhs.credentials
        && lhs.info == rhs.info
    }
}
