//
//  DefaultAccountProvider.swift
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
open class DefaultAccountProvider: AccountProvider, ConfigurationAccess, DatabaseAccess, WebServicesAccess, InAppAccess, WebServicesConsumer {
    
    private let customWebServices: WebServices?
    private let apiTokenProvider: APITokenProviderType
    private let vpnTokenProvider: VpnTokenProviderType

    init(webServices: WebServices? = nil, apiTokenProvider: APITokenProviderType, vpnTokenProvider: VpnTokenProviderType) {
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
        
        self.apiTokenProvider = apiTokenProvider
        self.vpnTokenProvider = vpnTokenProvider
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
        return webServices.apiToken ?? apiTokenProvider.getAPIToken()?.apiToken
    }

    public var vpnToken: String? {
        guard let vpnToken = vpnTokenProvider.getVpnToken() else {
            return webServices.vpnToken
        }
        
        let vpnTokenString = "vpn_token_\(vpnToken.vpnUsernameToken):\(vpnToken.vpnPasswordToken)"
        
        return webServices.vpnToken ?? vpnTokenString
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
        
        webServices.token(receipt: receiptRequest.receipt) { (error) in
            let credentials = Credentials(username: "", password: "")
            self.handleLoginResult(error: error, credentials: credentials, callback: callback)
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

        webServices.token(credentials: request.credentials) { (error) in
            self.handleLoginResult(error: error, credentials: request.credentials, callback: callback)
        }

    }
    
    public func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        webServices.validateLoginQR(qrToken: qrToken) { apiToken, error in
            callback?(apiToken, error)
        }
    }
    
    private func handleLoginResult(error: Error?, credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
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
                Macros.postNotification(.PIAAccountDidLogin, [.user: userAccount])
            }
            callback?(userAccount, error)
        }
    }
        
    private func updateUser(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)? ) {
        self.updateUsernamePassword()
        self.updateUserAccount(credentials: credentials, callback: callback)
    }
        
    private func updateUserAccount(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        self.webServices.info() { (accountInfo, error) in
            guard let accountInfo = accountInfo else {
                self.webServices.logout(nil)
                self.cleanDatabase()
                callback?(nil,ClientError.unauthorized)
                return
            }

            self.accessedDatabase.plain.accountInfo = accountInfo
            self.accessedDatabase.secure.setPublicUsername(accountInfo.username)
            let userAccount = UserAccount(credentials: credentials, info: accountInfo)
            callback?(userAccount, nil)
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
        webServices.info() { (accountInfo, error) in
            guard let accountInfo = accountInfo else {
                callback?(nil, error)
                return
            }

            self.accessedDatabase.plain.accountInfo = accountInfo
            Macros.postNotification(.PIAAccountDidRefresh, [.accountInfo: accountInfo])
            callback?(accountInfo, nil)
        }
    }
    
    public func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            preconditionFailure()
        }
        let credentials = Credentials(username: Client.providers.accountProvider.publicUsername ?? "",
                                      password: password)
        webServices.update(credentials: credentials, resetPassword: reset, email: request.email) { (error) in
            guard error == nil else {
                callback?(nil, error)
                return
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
    }
    
    public func logout(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            preconditionFailure()
        }
        webServices.logout { [weak self] (result, error) in
            self?.cleanDatabase()
            Macros.postNotification(.PIAAccountDidLogout)
            callback?(nil)
        }
    }
    
    public func deleteAccount(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            preconditionFailure()
        }
        webServices.deleteAccount { (result, error) in
            guard let result = result, result != false else {
                callback?(error)
                return
            }
            callback?(nil)
        }
    }
    
    public func featureFlags(_ callback: SuccessLibraryCallback?) {
        webServices.featureFlags { (features, nil) in
            Client.configuration.featureFlags.removeAll()
            if let features = features, !features.isEmpty {
                Client.configuration.featureFlags.append(contentsOf: features)
            }
            Macros.postNotification(Notification.Name.__AppDidFetchFeatureFlags)
            callback?(nil)
        }
    }
    
    #if os(iOS) || os(tvOS)
    public func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        log.debug("Fetching available product keys...")
        
        let receipt = accessedStore.paymentReceipt
        
        webServices.subscriptionInformation(with: receipt, { appStoreInformation, error in
        
            guard error == nil else {
                callback?(nil, error)
                return
            }
            
            if let appStoreInformation = appStoreInformation {
                callback?(appStoreInformation, nil)
            } else {
                callback?(nil, ClientError.malformedResponseData)
            }

        })
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
        self.webServices.loginLink(email: email, callback)
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

        webServices.signup(with: signup) { (credentials, error) in
            if let urlError = error as? URLError, (urlError.code == .notConnectedToInternet) {
                callback?(nil, ClientError.internetUnreachable)
                return
            }
            guard let credentials = credentials else {
                if let error = error as? ClientError, error == .badReceipt {
                    if let products = Client.store.availableProducts {
                        for product in products {
                            if let uncreditedTransaction = Client.store.uncreditedTransaction(for: product) {
                                self.accessedStore.finishTransaction(uncreditedTransaction, success: false)
                            }
                        }
                    }
                }
                callback?(nil, error)
                return
            }
            if let transaction = request.transaction {
                self.accessedStore.finishTransaction(transaction, success: true)
            }
            
            self.accessedDatabase.plain.lastSignupEmail = nil
            self.accessedDatabase.secure.setPublicUsername(credentials.username)
            self.accessedDatabase.secure.setUsername(credentials.username)
            self.accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)

            self.webServices.token(credentials: credentials) { (error) in
                if error != nil {
                    callback?(nil, error)
                    return
                }

                self.webServices.info() { (accountInfo, error) in
                    guard let accountInfo = accountInfo else {
                        callback?(nil, error)
                        return
                    }

                    self.accessedDatabase.plain.accountInfo = accountInfo
                    self.accessedDatabase.secure.setPublicUsername(accountInfo.username)
                    
                    let user = UserAccount(credentials: credentials, info: nil)
                    Macros.postNotification(.PIAAccountDidSignup, [.user: user])
                    callback?(user, nil)
                }
            }
        }
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

        webServices.processPayment(credentials: user.credentials, request: payment) { (error) in
            if let _ = error {
                callback?(nil, error)
                return
            }
            if let transaction = request.transaction {
                self.accessedStore.finishTransaction(transaction, success: true)
            }
            Macros.postNotification(.PIAAccountDidRenew)

            self.webServices.info() { (accountInfo, error) in
                guard let newAccountInfo = accountInfo else {
                    callback?(nil, nil)
                    return
                }
                self.accessedDatabase.plain.accountInfo = newAccountInfo
                
                let user = UserAccount(credentials: user.credentials, info: newAccountInfo)
                Macros.postNotification(.PIAAccountDidRefresh, [.user: user])
                callback?(user, nil)
            }
        }
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
