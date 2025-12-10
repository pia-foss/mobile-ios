//
//  EphemeralAccountProvider.swift
//  
//
//  Created by Juan Docal on 2022-08-10.
//

import Foundation

@available(tvOS 17.0, *)
class EphemeralAccountProvider: AccountProvider, ProvidersAccess, InAppAccess {

    // XXX: we want legit web services calls, yet allow the option to mock them
    private var webServices: WebServices? {
        guard let accountProvider = accessedProviders.accountProvider as? WebServicesConsumer else {
            fatalError("Current accountProvider is not a WebServicesConsumer. Use MockAccountProvider for mocking ephemeral Welcome process")
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

    func migrateOldTokenIfNeeded(_ callback: ((Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func login(with receiptRequest: LoginReceiptRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func login(with token: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
        fatalError("Not implemented")
    }

    func logout(_ callback: SuccessLibraryCallback?) {
        fatalError("Not implemented")
    }

    func deleteAccount(_ callback: SuccessLibraryCallback?) {
        fatalError("Not implemented")
    }

    func activateDIPTokens(_ dipToken: String, _ callback: LibraryCallback<DedicatedIPStatus>?) {
        fatalError("Not implemented")
    }

    func cleanDatabase() {
        fatalError("Not implemented")
    }

    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        fatalError("Not implemented")
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

        webServices?.signup(with: signup) { (credentials, error) in
            guard let credentials = credentials else {
                callback?(nil, error)
                return
            }
            let user = UserAccount(credentials: credentials, info: nil)
            self.currentUser = user
            self.isLoggedIn = true
            callback?(user, nil)
        }
    }

    func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }

    func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
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
