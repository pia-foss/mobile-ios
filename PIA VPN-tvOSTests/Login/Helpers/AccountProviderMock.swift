//
//  AccountProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class AccountProviderMock: AccountProvider {
    var planProducts: [PIALibrary.Plan : PIALibrary.InAppProduct]?
    var shouldCleanAccount: Bool = true
    var isLoggedIn: Bool = true
    var currentUser: PIALibrary.UserAccount?
    var oldToken: String?
    var apiToken: String?
    var vpnToken: String?
    var vpnTokenUsername: String?
    var vpnTokenPassword: String?
    var publicUsername: String?
    var currentPasswordReference: Data?
    var lastSignupRequest: PIALibrary.SignupRequest?
    func migrateOldTokenIfNeeded(_ callback: PIALibrary.SuccessLibraryCallback?) {}
    
    private let userResult: PIALibrary.UserAccount?
    private let errorResult: Error?
    var isExpired: Bool = false
    
    init(userResult: PIALibrary.UserAccount?, errorResult: Error?) {
        self.userResult = userResult
        self.errorResult = errorResult
    }
    
    func login(with request: PIALibrary.LoginRequest, _ callback: PIALibrary.LibraryCallback<PIALibrary.UserAccount>?) {
        callback?(userResult, errorResult)
    }
    
    func login(with linkToken: String, _ callback: ((PIALibrary.UserAccount?, Error?) -> Void)?) {
        callback?(userResult, errorResult)
    }
    
    func login(with receiptRequest: PIALibrary.LoginReceiptRequest, _ callback: PIALibrary.LibraryCallback<PIALibrary.UserAccount>?) {}
    func refreshAccountInfo(_ callback: PIALibrary.LibraryCallback<PIALibrary.AccountInfo>?) {}
    func accountInformation(_ callback: ((PIALibrary.AccountInfo?, Error?) -> Void)?) {}
    func update(with request: PIALibrary.UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: PIALibrary.LibraryCallback<PIALibrary.AccountInfo>?) {}
    func logout(_ callback: PIALibrary.SuccessLibraryCallback?) {}
    func deleteAccount(_ callback: PIALibrary.SuccessLibraryCallback?) {}
    func cleanDatabase() {}
    func featureFlags(_ callback: PIALibrary.SuccessLibraryCallback?) {}
    func listPlanProducts(_ callback: PIALibrary.LibraryCallback<[PIALibrary.Plan : PIALibrary.InAppProduct]>?) {}
    func purchase(plan: PIALibrary.Plan, _ callback: PIALibrary.LibraryCallback<PIALibrary.InAppTransaction>?) {}
    func isAPIEndpointAvailable(_ callback: PIALibrary.LibraryCallback<Bool>?) {}
    func restorePurchases(_ callback: PIALibrary.SuccessLibraryCallback?) {}
    func loginUsingMagicLink(withEmail email: String, _ callback: PIALibrary.SuccessLibraryCallback?) {}
    func signup(with request: PIALibrary.SignupRequest, _ callback: PIALibrary.LibraryCallback<PIALibrary.UserAccount>?) {}
    func listRenewablePlans(_ callback: PIALibrary.LibraryCallback<[PIALibrary.Plan]>?) {}
    func subscriptionInformation(_ callback: PIALibrary.LibraryCallback<PIALibrary.AppStoreInformation>?) {}
    func renew(with request: PIALibrary.RenewRequest, _ callback: PIALibrary.LibraryCallback<PIALibrary.UserAccount>?) {}
}

extension AccountProviderMock: AccountProviderType {}
