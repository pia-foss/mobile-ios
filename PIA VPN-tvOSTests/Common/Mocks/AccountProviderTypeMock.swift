//
//  AccountProviderTypeMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 12/20/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import XCTest

#if canImport(PIA_VPN_tvOS)
@testable import PIA_VPN_tvOS
#endif

#if canImport(PIA_VPN)
@testable import PIA_VPN
#endif


class AccountProviderTypeMock: AccountProviderType {
    
    
    var publicUsername: String? = nil
    
    var currentUser: PIALibrary.UserAccount? = nil
    
    var isLoggedIn: Bool = false
    var isExpired: Bool = false
    
    private(set) var logoutCalled = false
    private(set) var logoutCalledAttempt = 0
    private(set) var loginWithTokenCalledAttempt = 0
    func logout(_ callback: ((Error?) -> Void)?) {
        logoutCalled = true
        logoutCalledAttempt += 1
    }
    
    func login(with linkToken: String, _ callback: ((PIALibrary.UserAccount?, Error?) -> Void)?) {
        loginWithTokenCalledAttempt += 1
    }
    
    private(set) var accountInformationCalledAttempt = 0
    var accountInformationResult: PIALibrary.AccountInfo?
    var accountInformationError: Error?
    func accountInformation(_ callback: ((PIALibrary.AccountInfo?, Error?) -> Void)?) {
        accountInformationCalledAttempt += 1
        callback?(accountInformationResult, accountInformationError)

    }
}
