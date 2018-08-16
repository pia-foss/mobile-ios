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
        guard let username = accessedDatabase.plain.username else {
            return false
        }
        return (accessedDatabase.secure.password(for: username) != nil)
    }
    
    var currentUser: UserAccount? {
        get {
            guard let username = accessedDatabase.plain.username else {
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
                accessedDatabase.plain.username = user.credentials.username
                accessedDatabase.secure.setPassword(user.credentials.password, for: user.credentials.username)
                accessedDatabase.plain.accountInfo = user.info
            } else {
                if let username = accessedDatabase.plain.username {
                    accessedDatabase.secure.setPassword(nil, for: username)
                }
                accessedDatabase.plain.username = nil
                accessedDatabase.plain.accountInfo = nil
            }
        }
    }
    
    var currentPasswordReference: Data? {
        guard let username = accessedDatabase.plain.username else {
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

    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            preconditionFailure()
        }
        webServices.info(credentials: request.credentials) { (accountInfo, error) in
            guard let accountInfo = accountInfo else {
                callback?(nil, error)
                return
            }
            self.accessedDatabase.plain.username = request.credentials.username
            self.accessedDatabase.secure.setPassword(request.credentials.password, for: request.credentials.username)
            self.accessedDatabase.plain.accountInfo = accountInfo
            
            let user = UserAccount(credentials: request.credentials, info: accountInfo)
            Macros.postNotification(.PIAAccountDidLogin, [
                .user: user
            ])
            callback?(user, nil)
        }
    }
    
    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            preconditionFailure()
        }
        webServices.info(credentials: user.credentials) { (accountInfo, error) in
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
    
    func update(with request: UpdateAccountRequest, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            preconditionFailure()
        }
        webServices.update(credentials: user.credentials, email: request.email) { (error) in
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
        if let username = accessedDatabase.plain.username {
            accessedDatabase.secure.setPassword(nil, for: username)
        }
        accessedDatabase.plain.username = nil
        accessedDatabase.plain.accountInfo = nil
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
            self.accessedDatabase.plain.username = credentials.username
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
            self.accessedDatabase.plain.username = credentials.username
            self.accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)
            
            let user = UserAccount(credentials: credentials, info: nil)
            Macros.postNotification(.PIAAccountDidSignup, [
                .user: user
                ])
            callback?(user, nil)
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
                callback?(nil, ClientError.renewingNonRenewable)
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

            self.webServices.info(credentials: user.credentials) { (accountInfo, error) in
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
