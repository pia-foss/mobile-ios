//
//  DefaultAccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
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
    
    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        
        webServices.token(credentials: request.credentials) { (token, error) in
            
            guard let token = token else {
                callback?(nil, error)
                return
            }

            self.updateDatabaseWith(token,
                                    andUsername: request.credentials.username)

            self.webServices.info(token: token) { (accountInfo, error) in
                guard let accountInfo = accountInfo else {
                    callback?(nil, error)
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

            self.webServices.token(credentials: user.credentials) { (token, error) in
                if let token = token {
                    
                    self.updateDatabaseWith(token,
                                       andUsername: user.credentials.username)
                    self.accountInfoWith(token, callback)
                }
            }
            
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
    
    func update(with request: UpdateAccountRequest, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            preconditionFailure()
        }
        let credentials = Credentials(username: Client.providers.accountProvider.publicUsername ?? "",
                                      password: password)
        webServices.update(credentials: credentials, email: request.email) { (error) in
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
        cleanDatabase()
        Macros.postNotification(.PIAAccountDidLogout)
        callback?(nil)
    }

    #if os(iOS)
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
                callback?(nil, error)
                return
            }
            if let transaction = request.transaction {
                self.accessedStore.finishTransaction(transaction, success: true)
            }
            self.accessedDatabase.plain.lastSignupEmail = nil
            self.accessedDatabase.secure.setPublicUsername(credentials.username)
            self.accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)

            let user = UserAccount(credentials: credentials, info: nil)
            Macros.postNotification(.PIAAccountDidSignup, [
                .user: user
            ])
            callback?(user, nil)
        }
    }

    func redeem(with request: RedeemRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        let redeem = Redeem(email: request.email, code: request.code)
        
        webServices.redeem(with: redeem) { (credentials, error) in
            if let urlError = error as? URLError, (urlError.code == .notConnectedToInternet) {
                callback?(nil, ClientError.internetUnreachable)
                return
            }
            guard let credentials = credentials else {
                callback?(nil, error)
                return
            }
            
            self.webServices.token(credentials: credentials) { (token, error) in
                
                guard let token = token else {
                    callback?(nil, error)
                    return
                }
                
                let tokenComponents = token.split(by: token.count/2)
                if let first = tokenComponents.first,
                    let last = tokenComponents.last {
                    self.accessedDatabase.secure.setPublicUsername(credentials.username)
                    self.accessedDatabase.secure.setUsername(first)
                    self.accessedDatabase.secure.setToken(token,
                                                          for: self.accessedDatabase.secure.tokenKey(for: first))
                    self.accessedDatabase.secure.setPassword(last,
                                                             for: first)

                }
                
                let user = UserAccount(credentials: credentials, info: nil)
                Macros.postNotification(.PIAAccountDidSignup, [
                    .user: user
                    ])
                callback?(user, nil)

                
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
//                callback?([.monthly, .yearly], nil)
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
            accessedDatabase.secure.setToken(nil, for: accessedDatabase.secure.tokenKey(for: username))
        }
        accessedDatabase.secure.setPublicUsername(nil)
        accessedDatabase.plain.accountInfo = nil
        accessedDatabase.plain.visibleTiles = AvailableTiles.defaultTiles()
        accessedDatabase.plain.orderedTiles = AvailableTiles.defaultTiles()
        accessedDatabase.plain.historicalServers = []
    }
    #endif

    // MARK: WebServicesConsumer
    
    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
    
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        let task = webServices.taskForConnectivityCheck { (_, error) in
            callback?(error == nil, error)
        }
        task.resume()
    }
    
}
