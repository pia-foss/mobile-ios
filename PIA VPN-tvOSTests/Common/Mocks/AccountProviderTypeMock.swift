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

class AccountProviderTypeMock: AccountProvider {
    var publicUsername: String? = nil
    var currentUser: UserAccount? = nil
    var isLoggedIn: Bool = false

    // Custom setter to update currentUser when isExpired changes
    var isExpired: Bool {
        get {
            currentUser?.info?.isExpired ?? false
        }
        set {
            if newValue {
                // Create an expired user account
                currentUser = UserAccount.makeExpiredStub()
            } else {
                // Create a non-expired user account
                currentUser = UserAccount.makeStub()
            }
        }
    }

    private(set) var logoutCalled = false
    private(set) var logoutCalledAttempt = 0
    private(set) var loginWithTokenCalledAttempt = 0
    func logout(_ callback: ((Error?) -> Void)?) {
        logoutCalled = true
        logoutCalledAttempt += 1
    }

    func login(with linkToken: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        loginWithTokenCalledAttempt += 1
    }

    private(set) var accountInformationCalledAttempt = 0
    var accountInformationResult: AccountInfo?
    var accountInformationError: Error?
    func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        accountInformationCalledAttempt += 1
        callback?(accountInformationResult, accountInformationError)
    }

    // Additional required methods for AccountProvider conformance
    var planProducts: [Plan : InAppProduct]?
    var shouldCleanAccount: Bool = true
    var oldToken: String?
    var apiToken: String?
    var vpnToken: String?
    var vpnTokenUsername: String?
    var vpnTokenPassword: String?
    var currentPasswordReference: Data?
    var lastSignupRequest: SignupRequest?

    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?) {}
    func signup(with request: SignupRequest, _ callback: LibraryCallback<UserAccount>?) {}
    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {}
    func login(with receiptRequest: LoginReceiptRequest, _ callback: LibraryCallback<UserAccount>?) {}
    func refreshAccountInfo(_ callback: LibraryCallback<AccountInfo>?) {}
    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?) {}
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
    func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {}
}
