//
//  AccountProviderMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 12/12/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIABase
import PIALibrary
import StoreKit

@testable import PIA_VPN_tvOS

final class AccountProviderMock: AccountProvider {
    var planProducts: [Plan: any InAppProduct]?
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

    private func handleCallback(_ callback: ClientCallback<UserAccount>) {
        if let clientError = errorResult as? ClientError {
            callback(.failure(clientError))
        } else if let userResult {
            callback(.success(userResult))
        } else {
            callback(.failure(.unexpectedReply))
        }
    }

    func login(with request: LoginRequest, _ callback: @escaping ClientCallback<UserAccount>) {
        handleCallback(callback)
    }

    func login(with linkToken: String, _ callback: @escaping ClientCallback<UserAccount>) {
        loginWithTokenCalledAttempt += 1
        handleCallback(callback)
    }

    func signup(with request: SignupRequest, _ callback: LibraryCallback<UserAccount>?) {
        callback?(userResult, errorResult)
    }

    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        callback?(appStoreInformationResult, errorResult)
    }

    func login(with receiptRequest: LoginReceiptRequest, _ callback: @escaping ClientCallback<UserAccount>) {
        handleCallback(callback)
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
    func listPlanProducts() async -> Result<[Plan: any InAppProduct], StoreKitError> {
        .success([:])
    }
    func purchase(plan: Plan) async -> Result<any InAppTransaction, ClientError> {
        .failure(.userCancelled)
    }
    func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
        .failure(.userCancelled)
    }
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {}
    func restorePurchases() async -> Result<JWS, ClientError> { .success(JWS("jws")!) }
    func loginUsingMagicLink(withEmail email: String, _ callback: @escaping SuccessClientCallback) {}
    func listRenewablePlans(_ callback: LibraryCallback<[Plan]>?) {}
    func renew(with request: RenewRequest, _ callback: LibraryCallback<UserAccount>?) {}

    func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        callback?(apiToken, errorResult)
    }
}
