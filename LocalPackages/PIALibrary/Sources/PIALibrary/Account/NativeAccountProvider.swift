//
//  NativeAccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import SwiftyBeaver
import UIKit

private let log = SwiftyBeaver.self

@available(tvOS 17.0, *)
open class NativeAccountProvider: AccountProvider, ConfigurationAccess, DatabaseAccess, WebServicesAccess, InAppAccess, WebServicesConsumer {
    
    private let customWebServices: WebServices?
    
    private let logoutUseCase: LogoutUseCaseType
    private let loginUseCase: LoginUseCaseType
    private let signupUseCase: SignupUseCaseType
    private let apiTokenProvider: APITokenProviderType
    private let vpnTokenProvider: VpnTokenProviderType
    private let accountDetailsUseCase: AccountDetailsUseCaseType
    private let updateAccountUseCase: UpdateAccountUseCaseType
    private let paymentUseCase: PaymentUseCaseType
    private let subscriptionsUseCase: SubscriptionsUseCaseType
    private let deleteAccountUseCase: DeleteAccountUseCaseType
    private let featureFlagsUseCase: FeatureFlagsUseCaseType
    

    init(webServices: WebServices? = nil, logoutUseCase: LogoutUseCaseType, loginUseCase: LoginUseCaseType, signupUseCase: SignupUseCaseType, apiTokenProvider: APITokenProviderType, vpnTokenProvider: VpnTokenProviderType, accountDetailsUseCase: AccountDetailsUseCaseType, updateAccountUseCase: UpdateAccountUseCaseType, paymentUseCase: PaymentUseCaseType, subscriptionsUseCase: SubscriptionsUseCaseType, deleteAccountUseCase: DeleteAccountUseCaseType, featureFlagsUseCase: FeatureFlagsUseCaseType) {
        self.logoutUseCase = logoutUseCase
        self.loginUseCase = loginUseCase
        self.signupUseCase = signupUseCase
        self.apiTokenProvider = apiTokenProvider
        self.vpnTokenProvider = vpnTokenProvider
        self.accountDetailsUseCase = accountDetailsUseCase
        self.updateAccountUseCase = updateAccountUseCase
        self.paymentUseCase = paymentUseCase
        self.subscriptionsUseCase = subscriptionsUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.featureFlagsUseCase = featureFlagsUseCase
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
    }

    // MARK: AccountProvider
    
    #if os(iOS) || os(tvOS)
    public var planProducts: [Plan: InAppProduct]? {
        guard let products = accessedStore.availableProducts else {
            return nil
        }
        var map = [Plan: InAppProduct]()
        for product in products {
            guard let plan = accessedConfiguration.plan(forProductIdentifier: product.identifier) else {
                continue
            }
            map[plan] = product
        }
        return map
    }
    #endif
    
    public var isLoggedIn: Bool {
        guard let username = accessedDatabase.secure.username() else {
            return false
        }
        return (accessedDatabase.secure.password(for: username) != nil)
    }
    
    public var shouldCleanAccount: Bool {
        if self.accessedDatabase.plain.accountInfo == nil,
            self.isLoggedIn {
            return true
        }
        return false
    }
    
    public var oldToken: String? {
        guard let username = accessedDatabase.secure.username() else {
            return nil
        }
        return accessedDatabase.secure.token(for: accessedDatabase.secure.tokenKey(for: username))
    }

    public var apiToken: String? {
        let apiToken = apiTokenProvider.getAPIToken()
        return apiToken?.apiToken
    }

    public var vpnToken: String? {
        guard let vpnToken = vpnTokenProvider.getVpnToken() else {
            return nil
        }
        let vpnTokenString = "vpn_token_\(vpnToken.vpnUsernameToken):\(vpnToken.vpnPasswordToken)"
        return vpnTokenString
    }
    
    public var vpnTokenUsername: String? {
        return getVpnTokenUsernameAndPassword()?.username
    }
    
    public var vpnTokenPassword: String? {
        return getVpnTokenUsernameAndPassword()?.password
    }
    
    public var publicUsername: String? {
        guard let username = accessedDatabase.secure.publicUsername() else {
            return nil
        }
        return username
    }
    
    public var currentUser: UserAccount? {
        get {
            guard let username = accessedDatabase.secure.username() else {
                return nil
            }
            guard let password = accessedDatabase.secure.password(for: username) else {
                return nil
            }
            return UserAccount(
                credentials: Credentials(username: username, password: password),
                info: accessedDatabase.plain.accountInfo
            )
        }
        set {
            if let user = newValue {
                accessedDatabase.secure.setPublicUsername(user.credentials.username)
                accessedDatabase.secure.setPassword(user.credentials.password, for: user.credentials.username)
                accessedDatabase.plain.accountInfo = user.info
            } else {
                if let username = accessedDatabase.secure.username() {
                    accessedDatabase.secure.setPassword(nil, for: username)
                    accessedDatabase.secure.setUsername(nil)
                }
                accessedDatabase.secure.setPublicUsername(nil)
                accessedDatabase.plain.accountInfo = nil
            }
        }
    }
    
    public var currentPasswordReference: Data? {
        guard let username = accessedDatabase.secure.username() else {
            return nil
        }
        return accessedDatabase.secure.passwordReference(for: username)
    }
    
    #if os(iOS) || os(tvOS)
    public var lastSignupRequest: SignupRequest? {
        guard let email = accessedDatabase.plain.lastSignupEmail else {
            return nil
        }
        return SignupRequest(email: email)
    }
    #endif

    private func updateUsernamePassword() {
        if let token = self.vpnToken {
            let tokenComponents = token.components(separatedBy: ":")
            if let username = tokenComponents.first,
                let password = tokenComponents.last {
                self.accessedDatabase.secure.setUsername(username)
                self.accessedDatabase.secure.setPassword(password, for: username)
            }
        }
    }

    public func migrateOldTokenIfNeeded(_ callback: SuccessLibraryCallback?) {

        // If it was already migrated
        if (self.accessedDatabase.plain.tokenMigrated) {
            callback?(nil)
            return
        }

        // If there is something persisted. Try to migrate it.
        if let token = oldToken {
            webServices.migrateToken(token: token) { [weak self] (error) in
                guard error == nil else {
                    callback?(error)
                    return
                }
                
                guard let username = self?.vpnTokenUsername, let password = self?.vpnTokenPassword else {
                    preconditionFailure()
                }
        
                self?.accessedDatabase.secure.setPassword(password, for: username)
                self?.accessedDatabase.plain.tokenMigrated = true
                callback?(nil)
            }
        } else {

            // Nothing persisted. Continue.
            callback?(nil)
        }
    }
    
    public func login(with receiptRequest: LoginReceiptRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {

        guard !isLoggedIn else {
            preconditionFailure()
        }
       
        loginUseCase.login(with: receiptRequest.receipt) { error in
            DispatchQueue.main.async {
                let credentials = Credentials(username: "", password: "")
                self.handleLoginResult(error: error?.asClientError(), credentials: credentials, callback: callback)
            }
        }
        
    }

    public func login(with linkToken: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }

        self.webServices.migrateToken(token: linkToken) { (error) in
            let credentials = Credentials(username: "", password: "")
            self.handleLoginResult(error: error, credentials: credentials, callback: callback)
        }
    }

    public func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
    
        loginWithCredentials(request.credentials, callback: callback)
        
    }
    
    private func loginWithCredentials(_ credentials: Credentials, notificationToSend: Notification.Name = .PIAAccountDidLogin, callback: ((UserAccount?, Error?) -> Void)?) {
        
        loginUseCase.login(with: credentials) { error in
            DispatchQueue.main.async {
                self.handleLoginResult(error: error?.asClientError(), credentials: credentials, notificationToSend: notificationToSend, callback: callback)
            }
        }
    }
    
    private func handleLoginResult(error: Error?, credentials: Credentials, notificationToSend: Notification.Name = .PIAAccountDidLogin, callback: ((UserAccount?, Error?) -> Void)?) {
        guard error == nil else {
            callback?(nil, error)
            return
        }
        
        guard vpnToken != nil else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        
        self.updateUser(credentials: credentials) { userAccount, error in
            if let userAccount = userAccount {
                Macros.postNotification(notificationToSend, [.user: userAccount])
            }
            callback?(userAccount, error)
        }
    }
        
    private func updateUser(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)? ) {
        self.updateUsernamePassword()
        self.updateUserAccount(credentials: credentials, callback: callback)
    }
        
    private func updateUserAccount(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        accountDetailsUseCase() { result in
            
            switch result {
            case .failure(let error):
                self.logout(nil)
                self.cleanDatabase()
                DispatchQueue.main.async {
                    callback?(nil, ClientError.unauthorized)
                }
            case .success(let accountInfo):
                self.accessedDatabase.plain.accountInfo = accountInfo
                self.accessedDatabase.secure.setPublicUsername(accountInfo.username)
                let userAccount = UserAccount(credentials: credentials, info: accountInfo)
                DispatchQueue.main.async {
                    callback?(userAccount, nil)
                }
            }
        }
    
    }
    
    public func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard isLoggedIn,
            let _ = self.publicUsername else {
            guard let user = currentUser else {
                preconditionFailure()
            }

            self.logout(nil)
            return
        }
        accountInfoWith(callback)
    }
    
    public func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard isLoggedIn else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        accountInfoWith(callback)
    }
    
    private func accountInfoWith(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        
        accountDetailsUseCase() { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    callback?(nil, error.asClientError())
                }
            case .success(let accountInfo):
                DispatchQueue.main.async {
                    self.accessedDatabase.plain.accountInfo = accountInfo
                    
                    Macros.postNotification(.PIAAccountDidRefresh, [.accountInfo: accountInfo])
                    callback?(accountInfo, nil)
                }
                
            }
        }
        
    }
    
    public func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        
        let credentials = Credentials(username: Client.providers.accountProvider.publicUsername ?? "",
                                      password: password)
        
        if reset {
            updateAccountUseCase.setEmail(email: request.email, resetPassword: reset) { result in
                DispatchQueue.main.async {
                    self.handleUpdateAccountResult(result, request: request, shouldUpdatePassword: true, callback: callback)
                }
            }
        } else {
            updateAccountUseCase.setEmail(username: credentials.username, password: credentials.password, email: request.email, resetPassword: reset) { result in
                DispatchQueue.main.async {
                    //We use the email and the password returned by the signup endpoint in the previous step, we don't update the password
                    self.handleUpdateAccountResult(result, request: request, shouldUpdatePassword: false, callback: callback)
                }
                
            }
        }
        
    }
    
    private func handleUpdateAccountResult(_ result: Result<String?,  NetworkRequestError>, request: UpdateAccountRequest, shouldUpdatePassword: Bool,  callback: ((AccountInfo?, Error?) -> Void)?) {
        switch result {
        case .failure(let error):
            callback?(nil, error.asClientError())
        case .success(let tempPassword):
            if shouldUpdatePassword {
                if let newPassword = tempPassword {
                    Client.configuration.tempAccountPassword = newPassword
                }
            }
            
            self.handleUpdateAccountSuccessRequest(request, callback: callback)
        }
    }
    
    private func handleUpdateAccountSuccessRequest(_ request: UpdateAccountRequest, callback: ((AccountInfo?, Error?) -> Void)?) {
        
        guard let user = currentUser else {
            preconditionFailure()
        }
        
        guard let newAccountInfo = user.info?.with(email: request.email) else {
            Macros.postNotification(.PIAAccountDidUpdate)
            callback?(nil, nil)
            return
        }
        
        self.accessedDatabase.plain.accountInfo = newAccountInfo
        Macros.postNotification(.PIAAccountDidUpdate, [
            .accountInfo: newAccountInfo
        ])
        
        callback?(newAccountInfo, nil)
        
    }
    
    public func logout(_ callback: SuccessLibraryCallback?) {
        logoutUseCase() { [weak self] error in
            DispatchQueue.main.async {
                self?.cleanDatabase()
                Macros.postNotification(.PIAAccountDidLogout)
                callback?(nil)
            }
            
        }
    }
    
    public func deleteAccount(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            preconditionFailure()
        }
        
        deleteAccountUseCase() { error in
            DispatchQueue.main.async {
                callback?(error?.asClientError())
            }
            
        }
        
    }
    
    public func featureFlags(_ callback: SuccessLibraryCallback?) {
        featureFlagsUseCase() { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    callback?(error.asClientError())
                }
            case .success(let featuresInfo):
                DispatchQueue.main.async {
                    Client.configuration.featureFlags.removeAll()
                    Client.configuration.featureFlags.append(contentsOf: featuresInfo.flags)
                    Macros.postNotification(Notification.Name.__AppDidFetchFeatureFlags)
                    callback?(nil)
                }
            }
        }
    }
    
    #if os(iOS) || os(tvOS)
    public func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        log.debug("Fetching available product keys...")
        
        subscriptionsUseCase(receiptBase64: nil) { result in
            switch result {
            case .failure(let error):
                log.debug("SubscriptionsUseCase executed with error: \(error)")
                DispatchQueue.main.async {
                    callback?(nil, error.asClientError())
                }
            case .success(let appStoreInformation):
                DispatchQueue.main.async {
                    if let info = appStoreInformation {
                        callback?(info, nil)
                    } else {
                        log.debug("SubscriptionUseCase executed without error but unable to decode app store information")
                        callback?(nil, ClientError.malformedResponseData)
                    }
                }
            }
            
        }
        
    }
    
    public func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        log.debug("Fetching available products...")
        
        if let products = planProducts {
            log.debug("Available products in cache: \(products)")
            Macros.postNotification(.__InAppDidFetchProducts, [.products: products])
            callback?(products, nil)
            return
        }
        
        log.debug("No available products in cache, requesting from store...")
        
        let identifiers = accessedConfiguration.allProductIdentifiers()
        accessedStore.fetchProducts(identifiers: identifiers) { (products, error) in
            let products = self.planProducts ?? [:]
            log.debug("Available products from store: \(products)")
            Macros.postNotification(.__InAppDidFetchProducts, [.products: products])
            callback?(products, nil)
        }
    }

    public func purchase(plan: Plan, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        listPlanProducts { (map, error) in
            guard let product = map?[plan] else {
                callback?(nil, ClientError.productUnavailable)
                return
            }

            self.accessedStore.purchaseProduct(product) { (transaction, error) in
                guard let transaction = transaction else {
                    callback?(nil, error)
                    return
                }
                callback?(transaction, nil)
            }
        }
    }
    
    public func restorePurchases(_ callback: SuccessLibraryCallback?) {
        accessedStore.refreshPaymentReceipt(callback)
    }
    
    public func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
        loginUseCase.loginLink(with: email) { error in
            DispatchQueue.main.async {
                callback?(error?.asClientError())
            }
            
        }
    }

    public func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        guard let signup = request.signup(withStore: accessedStore) else {
            callback?(nil, ClientError.noReceipt)
            return
        }

        accessedDatabase.plain.lastSignupEmail = request.email
        
        signupUseCase(signup: signup) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let credentials):
                    handleSignupSuccessResult(transaction: request.transaction,
                                              credentials: credentials,
                                              callback: callback)
                case .failure(let error):
                    handleSignupErrorResult(error: error.asClientError(), callback: callback)
            }
        }
    }
    
    private func handleSignupErrorResult(error: ClientError?, callback: ((UserAccount?, Error?) -> Void)?) {
        guard error == .badReceipt, let products = Client.store.availableProducts else {
            DispatchQueue.main.async {
                callback?(nil, error)
            }
            return
        }
        
        for product in products {
            if let uncreditedTransaction = Client.store.uncreditedTransaction(for: product) {
                self.accessedStore.finishTransaction(uncreditedTransaction, success: false)
            }
        }
        
        DispatchQueue.main.async {
            callback?(nil, error)
        }
    }
    
    private func handleSignupSuccessResult(transaction: InAppTransaction?, credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        
        if let transaction = transaction {
            self.accessedStore.finishTransaction(transaction, success: true)
        }
        
        self.accessedDatabase.plain.lastSignupEmail = nil
        self.accessedDatabase.secure.setPublicUsername(credentials.username)
        self.accessedDatabase.secure.setUsername(credentials.username)
        self.accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)
        
        self.loginWithCredentials(credentials, notificationToSend: .PIAAccountDidSignup, callback: callback)
    }

    public func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        guard let info = currentUser?.info else {
            preconditionFailure()
        }

        listPlanProducts { (_, error) in
            guard error == nil else {
                callback?(nil, error)
                return
            }
            guard info.isRenewable else {
                //We need to check if the plan is a trial even when the plan is not renewable, as the
                //error message should be different for each scenario
                if info.plan == .trial {
                    callback?(nil, ClientError.renewingTrial)
                } else {
                    callback?(nil, ClientError.renewingNonRenewable)
                }
                return
            }

            switch info.plan {
            case .trial:
                callback?(nil, ClientError.renewingTrial)
                return
            case .monthly:
                callback?([.monthly], nil)
            case .yearly:
                callback?([.yearly], nil)
            case .other:
                callback?(nil, ClientError.renewingNonRenewable)
            }
        }
    }
    
    public func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard isLoggedIn else {
            preconditionFailure()
        }
        guard let user = currentUser else {
            preconditionFailure()
        }
        guard let accountInfo = user.info, accountInfo.isRenewable else {
            preconditionFailure()
        }
        guard let payment = request.payment(withStore: accessedStore) else {
            callback?(nil, ClientError.noReceipt)
            return
        }
        
        paymentUseCase(with: user.credentials, request: payment) { (error) in
            
            log.debug("Payment processed with error: \(error)")
            
            DispatchQueue.main.async {
                if let error {
                    callback?(nil, error)
                    return
                }
                
                if let transaction = request.transaction {
                    self.accessedStore.finishTransaction(transaction, success: true)
                }
                
                Macros.postNotification(.PIAAccountDidRenew)
            }
            
            
            self.accountDetailsUseCase() { result in
                switch result {
                case .success(let newAccountInfo):
                    DispatchQueue.main.async {
                        self.accessedDatabase.plain.accountInfo = newAccountInfo
                        let user = UserAccount(credentials: user.credentials, info: newAccountInfo)
                        Macros.postNotification(.PIAAccountDidRefresh, [.user: user])
                        callback?(user, nil)
                    }
                    
                case .failure(_):
                    DispatchQueue.main.async {
                        callback?(nil, nil)
                    }
                }
            }
            
        }
    }
    
    public func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        callback?(nil, nil)
    }
    
    /**
     Remove all data from the plain and secure internal database
     */
    public func cleanDatabase() {
        if let username = accessedDatabase.secure.username() {
            accessedDatabase.secure.setPassword(nil, for: username)
            accessedDatabase.secure.setUsername(nil)
            accessedDatabase.secure.clear(for: username)
        }
        accessedDatabase.secure.removeDIPTokens()
        accessedDatabase.secure.setPublicUsername(nil)
        accessedDatabase.plain.accountInfo = nil
        accessedDatabase.plain.visibleTiles = AvailableTiles.defaultTiles()
        accessedDatabase.plain.orderedTiles = AvailableTiles.defaultTiles()
        accessedDatabase.plain.historicalServers = []
        accessedDatabase.plain.reset()
    }
    
    #endif

    // MARK: WebServicesConsumer
    
    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
    
    public func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        webServices.taskForConnectivityCheck { (_, error) in
            callback?(error == nil, error)
        }
    }
    
    // MARK: Private

    /// :nodoc:
    func getVpnTokenUsernameAndPassword() -> (username: String, password: String)? {
        let token = Client.providers.accountProvider.vpnToken
        guard let unwrappedToken = token else {
            return nil
        }

        let tokenComponents = unwrappedToken.components(separatedBy: ":")
        guard tokenComponents.count == 2 else {
            return nil
        }

        guard let username = tokenComponents.first,
              let password = tokenComponents.last else {
            return nil
        }

        return (username, password)
    }
}
