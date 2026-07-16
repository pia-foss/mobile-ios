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
import PIABase
import StoreKit
import UIKit

private let log = PIALogger.logger(for: DefaultAccountProvider.self)

public final class DefaultAccountProvider: AccountProvider, ConfigurationAccess, DatabaseAccess, WebServicesAccess, InAppAccess, WebServicesConsumer {

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
        public var planProducts: [Plan: any InAppProduct]? {
            guard let products = accessedStore.availableProducts else {
                return nil
            }
            var map = [Plan: any InAppProduct]()
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
            self.isLoggedIn
        {
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
                let password = tokenComponents.last
            {
                self.accessedDatabase.secure.setUsername(username)
                self.accessedDatabase.secure.setPassword(password, for: username)
            }
        }
    }

    public func login(with receiptRequest: LoginReceiptRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            callback?(currentUser, nil)
            return
        }

        Task { @MainActor in
            let credentials = Credentials(username: "", password: "")

            do {
                try await webServices.token(receipt: receiptRequest.receipt)
                self.handleLoginResult(error: nil, credentials: credentials, callback: callback)
            } catch {
                self.handleLoginResult(error: error, credentials: credentials, callback: callback)
            }
        }
    }

    public func login(with linkToken: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            callback?(currentUser, nil)
            return
        }

        Task { @MainActor in
            let credentials = Credentials(username: "", password: "")

            do {
                try await webServices.migrateToken(token: linkToken)
                self.handleLoginResult(error: nil, credentials: credentials, callback: callback)
            } catch {
                self.handleLoginResult(error: error, credentials: credentials, callback: callback)
            }
        }
    }

    public func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !isLoggedIn else {
            callback?(currentUser, nil)
            return
        }

        Task { @MainActor in
            do {
                try await webServices.token(credentials: request.credentials)
                handleLoginResult(error: nil, credentials: request.credentials, callback: callback)
            } catch {
                handleLoginResult(error: error, credentials: request.credentials, callback: callback)
            }
        }
    }

    public func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        Task { @MainActor in
            do {
                let apiToken = try await webServices.validateLoginQR(qrToken: qrToken)
                DispatchQueue.main.async { callback?(apiToken, nil) }
            } catch {
                DispatchQueue.main.async { callback?(nil, error) }
            }
        }
    }

    private func handleLoginResult(error: Error?, credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        guard error == nil else {
            DispatchQueue.main.async { callback?(nil, error) }
            return
        }

        guard vpnToken != nil else {
            DispatchQueue.main.async { callback?(nil, ClientError.unauthorized) }
            return
        }

        self.updateUser(credentials: credentials) { userAccount, error in
            if let userAccount = userAccount {
                Macros.postNotification(.PIAAccountDidLogin, [.user: userAccount])
            }
            callback?(userAccount, error)
        }
    }

    private func updateUser(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        self.updateUsernamePassword()
        self.updateUserAccount(credentials: credentials, callback: callback)
    }

    private func updateUserAccount(credentials: Credentials, callback: ((UserAccount?, Error?) -> Void)?) {
        Task { @MainActor in
            do {
                let accountInfo = try await self.webServices.info()
                self.accessedDatabase.plain.accountInfo = accountInfo
                self.accessedDatabase.secure.setPublicUsername(accountInfo.username)
                let userAccount = UserAccount(credentials: credentials, info: accountInfo)
                DispatchQueue.main.async { callback?(userAccount, nil) }
            } catch {
                try? await self.webServices.logout()
                self.cleanDatabase()
                DispatchQueue.main.async { callback?(nil, ClientError.unauthorized) }
            }
        }
    }

    public func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard isLoggedIn, self.publicUsername != nil else {
            if currentUser == nil {
                self.logout(nil)
            }
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
        Task { @MainActor in
            do {
                let accountInfo = try await webServices.info()
                self.accessedDatabase.plain.accountInfo = accountInfo
                Macros.postNotification(.PIAAccountDidRefresh, [.accountInfo: accountInfo])
                DispatchQueue.main.async { callback?(accountInfo, nil) }
            } catch {
                DispatchQueue.main.async { callback?(nil, error) }
            }
        }
    }

    public func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard let user = currentUser else {
            callback?(nil, ClientError.unauthorized)
            return
        }

        let credentials = Credentials(
            username: Client.providers.accountProvider.publicUsername ?? "",
            password: password
        )

        Task { @MainActor in
            do {
                try await webServices.update(
                    credentials: credentials,
                    resetPassword: reset,
                    email: request.email
                )

                guard let newAccountInfo = user.info?.with(email: request.email) else {
                    Macros.postNotification(.PIAAccountDidUpdate)
                    DispatchQueue.main.async { callback?(nil, nil) }
                    return
                }

                self.accessedDatabase.plain.accountInfo = newAccountInfo
                Macros.postNotification(
                    .PIAAccountDidUpdate,
                    [
                        .accountInfo: newAccountInfo
                    ])

                DispatchQueue.main.async { callback?(newAccountInfo, nil) }
            } catch {
                DispatchQueue.main.async { callback?(nil, error) }
            }
        }
    }

    public func logout(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            callback?(nil)
            return
        }

        Task { @MainActor in
            try? await webServices.logout()
            cleanDatabase()
            Macros.postNotification(.PIAAccountDidLogout)
            DispatchQueue.main.async { callback?(nil) }
        }
    }

    public func deleteAccount(_ callback: SuccessLibraryCallback?) {
        guard isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }

        Task { @MainActor in
            do {
                try await webServices.deleteAccount()
                DispatchQueue.main.async { callback?(nil) }
            } catch {
                DispatchQueue.main.async { callback?(error) }
            }
        }
    }

    public func featureFlags(_ callback: SuccessLibraryCallback?) {
        Task { @MainActor in
            guard let features = try? await webServices.featureFlags() else {
                DispatchQueue.main.async { callback?(nil) }
                return
            }

            Client.configuration.featureFlags.configure(with: features)
            Macros.postNotification(Notification.Name.__AppDidFetchFeatureFlags)
            DispatchQueue.main.async { callback?(nil) }
        }
    }

    #if os(iOS) || os(tvOS)
        public func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
            log.debug("Fetching available product keys...")

            Task {
                let receipt = await accessedStore.currentEntitlementJWS()
                do {
                    let appStoreInformation = try await webServices.subscriptionInformation(with: receipt)
                    DispatchQueue.main.async { callback?(appStoreInformation, nil) }
                } catch {
                    DispatchQueue.main.async { callback?(nil, error) }
                }
            }
        }

        public func listPlanProducts() async -> Result<[Plan: any InAppProduct], StoreKitError> {
            log.debug("Fetching available products...")

            if let products = planProducts {
                log.debug("Available products in cache: \(products)")
                Macros.postNotification(.__InAppDidFetchProducts, [.products: products])
                return .success(products)
            }

            log.debug("No available products in cache, requesting from store...")

            let identifiers = accessedConfiguration.allProductIdentifiers()
            switch await accessedStore.fetchProducts(identifiers: identifiers) {
            case .failure(let error):
                return .failure(error)
            case .success(let products):
                log.debug("Available products from store: \(products)")
                Macros.postNotification(.__InAppDidFetchProducts, [.products: planProducts ?? [:]])
                return .success(planProducts!)
            }
        }

        public func purchase(plan: Plan) async -> Result<any InAppTransaction, ClientError> {
            let products: [Plan: any InAppProduct]
            switch await listPlanProducts() {
            case .failure(.userCancelled):
                return .failure(.userCancelled)
            case .failure(let error):
                return .failure(.unknown(code: 606, message: error.localizedDescription))
            case .success(let products_):
                products = products_
            }

            guard let product = products[plan] else {
                return .failure(ClientError.productUnavailable)
            }

            return await purchase(product: product)
        }

        @inlinable
        public func purchase(product: any InAppProduct) async -> Result<any InAppTransaction, ClientError> {
            return await accessedStore.purchase(product: product)
        }

        public func restorePurchases() async -> Result<JWS, ClientError> {
            let syncError = await accessedStore.synchronizeEntitlements()
            if let syncError {
                log.warning("Entitlements sync failed: \(syncError)")
            }

            // Success requires an actual entitlement, not just a successful sync.
            // A cached entitlement is acceptable when the sync fails (e.g. offline).
            let jws = await accessedStore.currentEntitlementJWS()
            if let jws {
                log.debug("Returning found JWS entitlement (count \(jws.value.count))")
                return .success(jws)
            } else {
                log.debug("No JWS entitlement found")
                return .failure(.noReceipt)
            }
        }

        public func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
            Task { @MainActor in
                do {
                    try await webServices.loginLink(email: email)
                    DispatchQueue.main.async { callback?(nil) }
                } catch {
                    DispatchQueue.main.async { callback?(error) }
                }
            }
        }

        public func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
            guard !isLoggedIn else {
                callback?(nil, ClientError.unauthorized)
                return
            }

            Task { @MainActor in
                await performSignup(with: request, callback: callback)
            }
        }

        private func performSignup(with request: SignupRequest, callback: ((UserAccount?, Error?) -> Void)?) async {
            guard let signup = await request.signup(withStore: accessedStore) else {
                DispatchQueue.main.async { callback?(nil, ClientError.noReceipt) }
                return
            }

            accessedDatabase.plain.lastSignupEmail = request.email

            do {
                let credentials = try await webServices.signup(with: signup)

                if let transaction = request.transaction {
                    accessedStore.finishTransaction(transaction, success: true)
                }

                accessedDatabase.plain.lastSignupEmail = nil
                accessedDatabase.secure.setPublicUsername(credentials.username)
                accessedDatabase.secure.setUsername(credentials.username)
                accessedDatabase.secure.setPassword(credentials.password, for: credentials.username)

                try await webServices.token(credentials: credentials)
                let accountInfo = try await webServices.info()
                accessedDatabase.plain.accountInfo = accountInfo
                accessedDatabase.secure.setPublicUsername(accountInfo.username)

                let user = UserAccount(credentials: credentials, info: nil)
                Macros.postNotification(.PIAAccountDidSignup, [.user: user])
                DispatchQueue.main.async { callback?(user, nil) }

            } catch let error as ClientError where error == .badReceipt {
                // If signup failed with badReceipt (HTTP 400), try login-with-receipt.
                // This handles returning users (e.g. "Duplicate purchase" from API).
                await attemptLoginWithReceiptFallback(transaction: request.transaction, callback: callback)
            } catch {
                if let urlError = error as? URLError, (urlError.code == .notConnectedToInternet) {
                    DispatchQueue.main.async { callback?(nil, ClientError.internetUnreachable) }
                    return
                }

                DispatchQueue.main.async { callback?(nil, error) }
            }
        }

        private func attemptLoginWithReceiptFallback(transaction: (any InAppTransaction)?, callback: ((UserAccount?, Error?) -> Void)?) async {
            let jws: JWS?
            if let transaction {
                jws = transaction.jwsRepresentation
            } else {
                jws = await accessedStore.currentEntitlementJWS()
            }

            guard let jws else {
                DispatchQueue.main.async { callback?(nil, ClientError.badReceipt) }
                return
            }

            do {
                try await webServices.token(receipt: jws)
            } catch {
                DispatchQueue.main.async { callback?(nil, ClientError.badReceipt) }
                return
            }

            if let transaction = transaction {
                accessedStore.finishTransaction(transaction, success: true)
            }

            accessedDatabase.plain.lastSignupEmail = nil
            updateUsernamePassword()

            guard let accountInfo = try? await webServices.info() else {
                DispatchQueue.main.async { callback?(nil, ClientError.badReceipt) }
                return
            }

            accessedDatabase.plain.accountInfo = accountInfo
            accessedDatabase.secure.setPublicUsername(accountInfo.username)

            let credentials = Credentials(
                username: vpnTokenUsername ?? "",
                password: vpnTokenPassword ?? ""
            )
            let user = UserAccount(credentials: credentials, info: accountInfo)
            Macros.postNotification(.PIAAccountDidSignup, [.user: user])
            DispatchQueue.main.async { callback?(user, nil) }
        }

        public func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
            guard let info = currentUser?.info else {
                callback?(nil, ClientError.unauthorized)
                return
            }

            Task { [weak self] in
                guard let self else { return }

                if case .failure(let error) = await self.listPlanProducts() {
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
                callback?(nil, ClientError.unauthorized)
                return
            }
            guard let user = currentUser else {
                callback?(nil, ClientError.unauthorized)
                return
            }
            guard let accountInfo = user.info, accountInfo.isRenewable else {
                callback?(nil, ClientError.renewingNonRenewable)
                return
            }

            Task { @MainActor in
                await performRenew(with: request, user: user, callback: callback)
            }
        }

        private func performRenew(with request: RenewRequest, user: UserAccount, callback: ((UserAccount?, Error?) -> Void)?) async {
            guard let payment = await request.payment(withStore: accessedStore) else {
                DispatchQueue.main.async { callback?(nil, ClientError.noReceipt) }
                return
            }

            do {
                try await webServices.processPayment(credentials: user.credentials, request: payment)

                if let transaction = request.transaction {
                    accessedStore.finishTransaction(transaction, success: true)
                }
                Macros.postNotification(.PIAAccountDidRenew)

                let accountInfo = try await webServices.info()
                accessedDatabase.plain.accountInfo = accountInfo

                let user = UserAccount(credentials: user.credentials, info: accountInfo)
                Macros.postNotification(.PIAAccountDidRefresh, [.user: user])
                DispatchQueue.main.async { callback?(user, nil) }
            } catch {
                DispatchQueue.main.async { callback?(nil, error) }
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

            apiTokenProvider.clearAPIToken()
            vpnTokenProvider.clearVpnToken()
        }

    #endif

    // MARK: WebServicesConsumer

    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }

    public func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        Task { @MainActor in
            switch await webServices.connectivityCheck() {
            case .failure(let error):
                DispatchQueue.main.async { callback?(false, error) }
            case .success:
                DispatchQueue.main.async { callback?(true, nil) }
            }
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
            let password = tokenComponents.last
        else {
            return nil
        }

        return (username, password)
    }
}
