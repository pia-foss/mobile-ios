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

private let log = SwiftyBeaver.self

class DefaultAccountProvider: AccountProvider, ConfigurationAccess, DatabaseAccess, WebServicesAccess, InAppAccess, WebServicesConsumer {
    
    private let customWebServices: WebServices?

    init(webServices: WebServices? = nil) {
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
    }

    // MARK: AccountProvider
    
    #if os(iOS)
    var planProducts: [Plan: InAppProduct]? {
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
    
    var isLoggedIn: Bool {
        guard let username = accessedDatabase.secure.username() else {
            return false
        }
        return (accessedDatabase.secure.password(for: username) != nil)
    }
    
    var shouldCleanAccount: Bool {
        if self.accessedDatabase.plain.accountInfo == nil,
            self.isLoggedIn {
            return true
        }
        return false
    }
    
    var publicUsername: String? {
        guard let username = accessedDatabase.secure.publicUsername() else {
            return nil
        }
        return username
    }
    
    var currentUser: UserAccount? {
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
    
    var token: String? {
        guard let username = accessedDatabase.secure.username() else {
            return nil
        }
        return accessedDatabase.secure.token(for: accessedDatabase.secure.tokenKey(for: username))
    }

    
    var currentPasswordReference: Data? {
        guard let username = accessedDatabase.secure.username() else {
            return nil
        }
        return accessedDatabase.secure.passwordReference(for: username)
    }
    
    #if os(iOS)
    var lastSignupRequest: SignupRequest? {
        guard let email = accessedDatabase.plain.lastSignupEmail else {
            return nil
        }
        return SignupRequest(email: email)
    }
    #endif

    private func updateDatabaseWith(_ token: String, andUsername username: String) {
        let tokenComponents = token.split(by: token.count/2)
        if let first = tokenComponents.first,
            let last = tokenComponents.last {
            self.accessedDatabase.secure.setPublicUsername(username)
            self.accessedDatabase.secure.setUsername(first)
            self.accessedDatabase.secure.setToken(token,
                                                  for: self.accessedDatabase.secure.tokenKey(for: first))
            self.accessedDatabase.secure.setPassword(last,
                                                     for: first)
        }
    }
    
    private func updateToken(_ token: String) {
        let tokenComponents = token.split(by: token.count/2)
        if let first = tokenComponents.first,
            let last = tokenComponents.last {
            self.accessedDatabase.secure.setUsername(first)
            self.accessedDatabase.secure.setToken(token,
                                                  for: self.accessedDatabase.secure.tokenKey(for: first))
            self.accessedDatabase.secure.setPassword(last,
                                                     for: first)
        }
    }
    
    func login(with receiptRequest: LoginReceiptRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        
        webServices.token(receipt: receiptRequest.receipt) { (token, error) in
            self.saveToken(token: token, error: error, callback)
        }

    }
    
    func login(with token: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        
        guard !isLoggedIn else {
            preconditionFailure()
        }

        self.saveToken(token: token, error: nil, callback)
        
    }
    
    private func saveToken(token: String?, error: Error?, _ callback: ((UserAccount?, Error?) -> Void)?) {
        
        guard let token = token else {
            callback?(nil, error)
            return
        }

        self.updateToken(token)

        self.webServices.info(token: token) { (accountInfo, error) in
            guard let accountInfo = accountInfo else {
                callback?(nil, error)
                return
            }
            
            self.updateDatabaseWith(token,
                                    andUsername: accountInfo.username)

            //Save after confirm the login was successful.
            self.accessedDatabase.plain.accountInfo = accountInfo

            let user = UserAccount(credentials: Credentials(username: "", password: ""), info: accountInfo)
            Macros.postNotification(.PIAAccountDidLogin, [
                .user: user
                ])
            callback?(user, nil)
        }

    }


    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        
        webServices.token(credentials: request.credentials) { (token, error) in
            
            guard let token = token else {
                callback?(nil, ClientError.unauthorized)
                return
            }

            self.updateDatabaseWith(token,
                                    andUsername: request.credentials.username)

            self.webServices.info(token: token) { (accountInfo, error) in
                guard let accountInfo = accountInfo else {
                    self.webServices.logout(nil)
                    self.cleanDatabase()
                    callback?(nil, ClientError.unauthorized)
                    return
                }
                
                //Save after confirm the login was successful.
                self.accessedDatabase.plain.accountInfo = accountInfo

                let user = UserAccount(credentials: request.credentials, info: accountInfo)
                Macros.postNotification(.PIAAccountDidLogin, [
                    .user: user
                    ])
                callback?(user, nil)
            }

        }

    }
    
    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        
        guard let token = self.token,
            let _ = self.publicUsername else {

            guard let user = currentUser else {
                preconditionFailure()
            }

            self.logout(nil)
            
            return
        }

        accountInfoWith(token, callback)
        
    }
    
    public func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let token = self.token else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        accountInfoWith(token, callback)
    }
    
    private func accountInfoWith(_ token: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        webServices.info(token: token) { (accountInfo, error) in
            guard let accountInfo = accountInfo else {
                callback?(nil, error)
                return
            }
            self.accessedDatabase.plain.accountInfo = accountInfo
            Macros.postNotification(.PIAAccountDidRefresh, [
                .accountInfo: accountInfo
                ])
            callback?(accountInfo, nil)
        }
    }
    
    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            preconditionFailure()
        }
        let credentials = Credentials(username: Client.providers.accountProvider.publicUsername ?? "",
                                      password: password)
        webServices.update(credentials: credentials, resetPassword: reset, email: request.email) { (error) in
            if let _ = error {
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
    
    func logout(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            preconditionFailure()
        }
        webServices.logout { [weak self] (result, error) in
            self?.cleanDatabase()
            Macros.postNotification(.PIAAccountDidLogout)
            callback?(nil)
        }
    }
    
    func featureFlags(_ callback: SuccessLibraryCallback?) {
        webServices.featureFlags { (features, nil) in
            if let features = features, !features.isEmpty {
                Client.configuration.featureFlags.append(contentsOf: features)
            }
            callback?(nil)
        }
    }
    
    func inAppMessages(_ callback: LibraryCallback<InAppMessage>?) {
        webServices.messages { (message, error) in
            callback?(message, error)
        }
    }
    
    #if os(iOS)
    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        log.debug("Fetching available product keys...")
        
        let receipt = accessedStore.paymentReceipt
        
        webServices.subscriptionInformation(with: receipt, { appStoreInformation, error in
        
            if let _ = error {
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
    
    func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
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

    func purchase(plan: Plan, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        listPlanProducts { (map, error) in
            guard let product = map?[plan] else {
                callback?(nil, ClientError.productUnavailable)
                return
            }

//            if let uncredited = self.accessedStore.uncreditedTransaction(for: product) {
//                callback?(uncredited, nil)
//                return
//            }
            self.accessedStore.purchaseProduct(product) { (transaction, error) in
                guard let transaction = transaction else {
                    callback?(nil, error)
                    return
                }
                callback?(transaction, nil)
            }
        }
    }
    
    func restorePurchases(_ callback: SuccessLibraryCallback?) {
        accessedStore.refreshPaymentReceipt(callback)
    }
    
    func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
        self.webServices.loginLink(email: email, callback)
    }

    func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
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
            self.accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)

            self.webServices.token(credentials: credentials) { (token, error) in
                
                guard let token = token else {
                    callback?(nil, error)
                    return
                }
                
                self.updateDatabaseWith(token,
                                        andUsername: credentials.username)
                
                self.webServices.info(token: token) { (accountInfo, error) in
                    guard let accountInfo = accountInfo else {
                        callback?(nil, error)
                        return
                    }
                    
                    //Save after confirm the login was successful.
                    self.accessedDatabase.plain.accountInfo = accountInfo
                    
                    let user = UserAccount(credentials: credentials, info: nil)
                    Macros.postNotification(.PIAAccountDidSignup, [
                        .user: user
                        ])
                    callback?(user, nil)
                }
                
            }

        }
    }

    func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        guard let info = currentUser?.info else {
            preconditionFailure()
        }
        listPlanProducts { (_, error) in
            if let error = error {
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
    
    func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard let token = token else {
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

            self.webServices.info(token: token) { (accountInfo, error) in
                guard let newAccountInfo = accountInfo else {
                    callback?(nil, nil)
                    return
                }
                self.accessedDatabase.plain.accountInfo = newAccountInfo
                
                let user = UserAccount(credentials: user.credentials, info: newAccountInfo)
                Macros.postNotification(.PIAAccountDidRefresh, [
                    .user: user
                    ])
                callback?(user, nil)
            }
        }
    }
    
    /**
     Remove all data from the plain and secure internal database
     */
    func cleanDatabase() {
        if let username = accessedDatabase.secure.username() {
            accessedDatabase.secure.setPassword(nil, for: username)
            accessedDatabase.secure.setUsername(nil)
            accessedDatabase.secure.clear(for: username)
            accessedDatabase.secure.setToken(nil, for: accessedDatabase.secure.tokenKey(for: username))
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
    
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        webServices.taskForConnectivityCheck { (_, error) in
            callback?(error == nil, error)
        }
    }
    
}
