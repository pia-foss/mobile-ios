//
//  EphemeralAccountProvider.swift
//  
//
//  Created by Juan Docal on 2022-08-10.
//

import Foundation

fileprivate let log = PIALogger.logger(for: EphemeralAccountProvider.self)

@available(tvOS 17.0, *)
class EphemeralAccountProvider: AccountProvider, ProvidersAccess, InAppAccess {

    // XXX: we want legit web services calls, yet allow the option to mock them
    private var webServices: WebServices? {
        guard let accountProvider = accessedProviders.accountProvider as? WebServicesConsumer else {
            log.error("Current accountProvider is not a WebServicesConsumer. Use MockAccountProvider for mocking ephemeral Welcome process")
            return nil
        }
        return accountProvider.webServices
    }

    var planProducts: [Plan : InAppProduct]? {
        return accessedProviders.accountProvider.planProducts
    }

    var shouldCleanAccount = false

    var isLoggedIn = false

    var currentUser: UserAccount?

    var oldToken: String?

    var vpnToken: String?

    var vpnTokenUsername: String?

    var vpnTokenPassword: String?

    var apiToken: String?

    var publicUsername: String?

    var currentPasswordReference: Data? {
        return nil
    }

    var lastSignupRequest: SignupRequest? {
        return nil
    }

    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func login(with receiptRequest: LoginReceiptRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func login(with token: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
        log.error("Not implemented")
    }

    func logout(_ callback: SuccessLibraryCallback?) {
        log.error("Not implemented")
    }

    func deleteAccount(_ callback: SuccessLibraryCallback?) {
        log.error("Not implemented")
    }

    func activateDIPTokens(_ dipToken: String, _ callback: LibraryCallback<DedicatedIPStatus>?) {
        log.error("Not implemented")
    }

    func cleanDatabase() {
        log.error("Not implemented")
    }

    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        log.error("Not implemented")
    }

    func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        accessedProviders.accountProvider.listPlanProducts(callback)
    }

    func purchase(plan: Plan, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        accessedProviders.accountProvider.purchase(plan: plan, callback)
    }

    func restorePurchases(_ callback: SuccessLibraryCallback?) {
        accessedProviders.accountProvider.restorePurchases(callback)
    }

    func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard let signup = request.signup(withStore: accessedStore) else {
            callback?(nil, ClientError.noReceipt)
            return
        }

        Task { @MainActor in
            do {
                guard let credentials = try await webServices?.signup(with: signup) else {
                    callback?(nil, nil)
                    return
                }

                let user = UserAccount(credentials: credentials, info: nil)
                self.currentUser = user
                self.isLoggedIn = true
                callback?(user, nil)
            } catch {
                callback?(nil, error)
            }
        }
    }

    func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        log.error("Not implemented")
    }

    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        guard let webServices = webServices else {
            callback?(false, nil)
            return
        }
        webServices.taskForConnectivityCheck { (_, error) in
            callback?(error == nil, error)
        }
    }

    func featureFlags(_ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    func validateLoginQR(with qrToken: String, _ callback: ((String?, Error?) -> Void)?) {
        callback?(nil, nil)
    }
}
