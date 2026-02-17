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
    var planProducts: [Plan : InAppProduct]?
    var shouldCleanAccount: Bool = true
    var isLoggedIn: Bool = true
    var currentUser: UserAccount?
    var oldToken: String?
    var apiToken: String?
    var vpnToken: String?
    var vpnTokenUsername: String?
    var vpnTokenPassword: String?
    var publicUsername: String?
    var currentPasswordReference: Data?
    var lastSignupRequest: SignupRequest?

    private let userResult: UserAccount?
    private let errorResult: Error?
    private let appStoreInformationResult: AppStoreInformation?
    
    private(set) var logoutCalledAttempt = 0
    private(set) var loginWithTokenCalledAttempt = 0
    private(set) var accountInformationCalledAttempt = 0
    var accountInformationResult: AccountInfo?
    var accountInformationError: Error?
    
    var isExpired: Bool {
        get {
            currentUser?.info?.isExpired ?? false
        }
        set {
            if newValue {
                currentUser = UserAccount.makeExpiredStub()
            } else {
                currentUser = UserAccount.makeStub()
            }
        }
    }

    init(userResult: UserAccount?, errorResult: Error?, appStoreInformationResult: AppStoreInformation? = nil) {
        self.userResult = userResult
        self.errorResult = errorResult
        self.appStoreInformationResult = appStoreInformationResult
    }

    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?) {
        callback?(userResult, errorResult)
    }

    func login(with linkToken: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        loginWithTokenCalledAttempt += 1
        callback?(userResult, errorResult)
    }

    func signup(with request: SignupRequest, _ callback: LibraryCallback<UserAccount>?) {
        callback?(userResult, errorResult)
    }

    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        callback?(appStoreInformationResult, errorResult)
    }

    func login(with receiptRequest: LoginReceiptRequest, _ callback: LibraryCallback<UserAccount>?) {
        callback?(userResult, errorResult)
    }

    func refreshAccountInfo(_ callback: LibraryCallback<AccountInfo>?) {}
    func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        accountInformationCalledAttempt += 1
        callback?(accountInformationResult, accountInformationError)
    }
    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?) {}
    func logout(_ callback: SuccessLibraryCallback?) {
        logoutCalledAttempt += 1
    }
    func deleteAccount(_ callback: SuccessLibraryCallback?) {}
    func cleanDatabase() {}
    func featureFlags(_ callback: SuccessLibraryCallback?) {}
    func listPlanProducts(_ callback: LibraryCallback<[Plan : InAppProduct]>?) {}
    func purchase(plan: Plan, _ callback: LibraryCallback<InAppTransaction>?) {}
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {}
    func restorePurchases(_ callback: SuccessLibraryCallback?) {}
    func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {}
    func listRenewablePlans(_ callback: LibraryCallback<[Plan]>?) {}
    func renew(with request: RenewRequest, _ callback: LibraryCallback<UserAccount>?) {}

    func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        callback?(apiToken, errorResult)
    }
}
