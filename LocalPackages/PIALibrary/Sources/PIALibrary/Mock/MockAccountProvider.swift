//
//  MockAccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
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

/// Simulates account-related operations
@available(tvOS 17.0, *)
public class MockAccountProvider: AccountProvider, WebServicesConsumer {
    
    /// Mocks the outcome of a sign-up operation.
    ///
    /// - Seealso: `AccountProvider.signup(...)`
    public enum SignupOutcome {

        /// Sign-up succeeded.
        case success
        
        /// Sign-up failed.
        case failure
        
        /// Sign-up failed due to missing Internet connectivity.
        case internetUnreachable
    }

    /// Mocks the outcome of a redeem operation.
    ///
    /// - Seealso: `AccountProvider.redeem(...)`
    public enum RedeemOutcome {
        
        /// Redeem succeeded.
        case success
        
        /// Redeem code is invalid.
        case invalid

        /// Redeem code already claimed.
        case claimed
    }
    
    /// Fakes authentication outcome.
    public var mockIsUnauthorized = false

    /// Fakes can invite.
    public var mockCanInvite = false

    /// Fakes sign-up outcome.
    public var mockSignupOutcome: SignupOutcome = .success

    /// Fakes redeem outcome.
    public var mockRedeemOutcome: RedeemOutcome = .success
    
    /// Fakes `AccountInfo.email`.
    public var mockEmail: String = "mock@email.com"

    /// Fakes `AccountInfo.product_id`.
    public var mockProductId: String = "com.privateinternetaccess.subscription.1month"

    /// Fakes `AccountInfo.plan`.
    public var mockPlan: Plan = .monthly
    
    /// Fakes `AccountInfo.isRenewable`.
    public var mockIsRenewable: Bool = false
    
    /// Fakes `AccountInfo.isRecurring`.
    public var mockIsRecurring: Bool = true
    
    /// Fakes `AccountInfo.expirationDate`.
    public var mockExpirationDate: Date = Date().addingTimeInterval(7 * 24 * 60 * 60)
    
    /// Fakes `AccountInfo.shouldPresentExpirationAlert`.
    public var mockIsExpiring: Bool = false
    
    let webServices: WebServices
    
    private let delegate: AccountProvider
    
    /// :nodoc:
    public init() {
        let webServices = MockWebServices()
        self.webServices = webServices
        delegate = AccountFactory.makeDefaultAccountProvider(with: webServices)

        webServices.credentials = {
            return Credentials(
                username: "p0000000",
                password: "BogusPassword"
            )
        }
        webServices.accountInfo = {
            return AccountInfo(
                email: self.mockEmail,
                username: "p0000000",
                plan: self.mockPlan,
                productId: self.mockProductId,
                isRenewable: self.mockIsRenewable,
                isRecurring: self.mockIsRecurring,
                expirationDate: self.mockExpirationDate,
                canInvite: self.mockCanInvite,
                shouldPresentExpirationAlert: self.mockIsExpiring,
                renewUrl: nil
            )
        }
        webServices.appstoreInformationEligible = {
            return AppStoreInformation(products: [Product(identifier: "com.product.monthly",
                                                          plan: .monthly,
                                                          price: "3.99",
                                                          legacy: false)],
                                       eligibleForTrial: true)
        }
        webServices.appstoreInformationEligibleButDisabledFromBackend = {
            return AppStoreInformation(products: [Product(identifier: "com.product.monthly",
                                                          plan: .monthly,
                                                          price: "3.99",
                                                          legacy: false)],
                                       eligibleForTrial: false)
        }
        webServices.appstoreInformationNotEligible = {
            return AppStoreInformation(products: [Product(identifier: "com.product.monthly",
                                                          plan: .monthly,
                                                          price: "3.99",
                                                          legacy: false)],
                                       eligibleForTrial: false)
        }
    }
    
    // MARK: AccountProvider

    #if os(iOS) || os(tvOS)
    /// :nodoc:
    public var planProducts: [Plan : InAppProduct]? {
        return delegate.planProducts
    }
    #endif
    
    /// :nodoc:
    public var shouldCleanAccount: Bool {
        return false
    }

    /// :nodoc:
    public var isLoggedIn: Bool {
        return delegate.isLoggedIn
    }
    
    public var oldToken: String? {
        return "TOKEN"
    }
    
    public var vpnToken: String? {
        return "TOKEN"
    }

    public var apiToken: String? {
        return "TOKEN"
    }
    
    public var vpnTokenUsername: String? {
        return "USERNAME"
    }
    
    public var vpnTokenPassword: String? {
        return "PASSWORD"
    }
    
    public var publicUsername: String? {
        return "p0000000"
    }

    public var currentPasswordReference: Data? {
        return nil
    }

    /// :nodoc:
    public var currentUser: UserAccount? {
        get {
            return delegate.currentUser
        }
        set {
            delegate.currentUser = newValue
        }
    }
        
    #if os(iOS) || os(tvOS)
    /// :nodoc:
    public var lastSignupRequest: SignupRequest? {
        return delegate.lastSignupRequest
    }
    #endif

    /// :nodoc:
    public func migrateOldTokenIfNeeded(_ callback: SuccessLibraryCallback?) {
        guard !mockIsUnauthorized else {
            callback?(ClientError.unauthorized)
            return
        }
        delegate.migrateOldTokenIfNeeded(callback)
    }

    public func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.login(with: request, callback)
    }
    
    public func login(with receiptRequest: LoginReceiptRequest, _ callback: LibraryCallback<UserAccount>?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.login(with: receiptRequest, callback)
    }

    public func login(with token: String, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.login(with: "12345", callback)
    }
    
    /// :nodoc:
    public func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.refreshAccountInfo(callback)
    }
    
    /// :nodoc:
    public func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.accountInformation(callback)
    }
    
    /// :nodoc:
    public func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?) {
        delegate.update(with: request, resetPassword: reset, andPassword: password, callback)
    }
    
    /// :nodoc:
    public func logout(_ callback: SuccessLibraryCallback?) {
        delegate.logout(callback)
    }
    
    /// :nodoc:
    public func deleteAccount(_ callback: SuccessLibraryCallback?) {
        delegate.deleteAccount(callback)
    }
    
    /// :nodoc:
    public func cleanDatabase() {
        delegate.cleanDatabase()
    }
    
    #if os(iOS) || os(tvOS)
    /// :nodoc:
    public func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        delegate.listPlanProducts(callback)
    }
    
    /// :nodoc:
    public func purchase(plan: Plan, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        delegate.purchase(plan: plan, callback)
    }
    
    /// :nodoc:
    public func restorePurchases(_ callback: SuccessLibraryCallback?) {
        delegate.restorePurchases(callback)
    }
    
    public func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?) {
        delegate.loginUsingMagicLink(withEmail: email, callback)
    }
    
    /// :nodoc:
    public func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?) {
        delegate.subscriptionInformation(callback)
    }
    
    /// :nodoc:
    public func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        Macros.dispatch(after: .seconds(1)) {
            switch self.mockSignupOutcome {
            case .success:
                self.delegate.signup(with: request, callback)

            case .failure:
                callback?(nil, nil)

            case .internetUnreachable:
                callback?(nil, ClientError.internetUnreachable)
            }
        }
    }
        
    /// :nodoc:
    public func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        delegate.listRenewablePlans(callback)
    }
    
    /// :nodoc:
    public func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        mockExpirationDate += 30 * 24 * 60 * 60 // 1 month
        delegate.renew(with: request, callback)
    }
    #endif
    
    public func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        callback?(true, nil)
    }
    
    public func featureFlags(_ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    public func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?) {
        callback?(nil, nil)
    }
}
