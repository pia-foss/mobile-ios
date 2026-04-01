//
//  UserAccountMapper.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class UserAccountMapper {
    func map(userAccount: PIALibrary.UserAccount) -> UserAccount {
        let credentials = Credentials(username: userAccount.credentials.username,
                                      password: userAccount.credentials.password)
        
        guard let info = userAccount.info else {
            return UserAccount(credentials: credentials, info: nil)
        }
        
        let accountInfo = AccountInfo(email: info.email,
                                      username: info.username,
                                      plan: Plan.map(plan: info.plan),
                                      productId: info.productId,
                                      isRenewable: info.isRenewable,
                                      isRecurring: info.isRecurring,
                                      expirationDate: info.expirationDate,
                                      canInvite: info.canInvite,
                                      shouldPresentExpirationAlert: info.shouldPresentExpirationAlert,
                                      renewUrl: info.renewUrl)
        
        return UserAccount(credentials: credentials, info: accountInfo)
    }
}

extension Plan {
    static func map(plan: PIALibrary.Plan) -> Plan {
        switch plan {
            case .monthly:
                return .monthly
            case .yearly:
                return .yearly
            case .trial:
                return .trial
            case .other:
                return .other
        }
    }
}
