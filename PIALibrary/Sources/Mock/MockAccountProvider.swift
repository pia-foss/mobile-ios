//
//  MockAccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/17/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Simulates account-related operations
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

    /// Fakes sign-up outcome.
    public var mockSignupOutcome: SignupOutcome = .success

    /// Fakes redeem outcome.
    public var mockRedeemOutcome: RedeemOutcome = .success
    
    /// Fakes `AccountInfo.email`.
    public var mockEmail: String = "mock@email.com"

    /// Fakes `AccountInfo.plan`.
    public var mockPlan: Plan = .monthly
    
    /// Fakes `AccountInfo.isRenewable`.
    public var mockIsRenewable: Bool = false
    
    /// Fakes `AccountInfo.isRecurring`.
    public var mockIsRecurring: Bool = false
    
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
        delegate = DefaultAccountProvider(webServices: webServices)

        webServices.credentials = {
            return Credentials(
                username: "p0000000",
                password: "BogusPassword"
            )
        }
        webServices.accountInfo = {
            return AccountInfo(
                email: self.mockEmail,
                plan: self.mockPlan,
                isRenewable: self.mockIsRenewable,
                isRecurring: self.mockIsRecurring,
                expirationDate: self.mockExpirationDate,
                shouldPresentExpirationAlert: self.mockIsExpiring,
                renewUrl: nil
            )
        }
    }
    
    // MARK: AccountProvider

    #if os(iOS)
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
    
    public var token: String? {
        return "TOKEN"
    }
    
    public var publicUsername: String? {
        return "p0000000"
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
    
    /// :nodoc:
    public var currentPasswordReference: Data? {
        return delegate.currentPasswordReference
    }
    
    #if os(iOS)
    /// :nodoc:
    public var lastSignupRequest: SignupRequest? {
        return delegate.lastSignupRequest
    }
    #endif
    
    /// :nodoc:
    public func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.login(with: request, callback)
    }
    
    /// :nodoc:
    public func refreshAccountInfo(force: Bool, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        guard !mockIsUnauthorized else {
            callback?(nil, ClientError.unauthorized)
            return
        }
        delegate.refreshAccountInfo(force: false, callback)
    }
    
    /// :nodoc:
    public func update(with request: UpdateAccountRequest, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?) {
        delegate.update(with: request, andPassword: password, callback)
    }
    
    /// :nodoc:
    public func logout(_ callback: SuccessLibraryCallback?) {
        delegate.logout(callback)
    }
    
    /// :nodoc:
    public func cleanDatabase() {
        delegate.cleanDatabase()
    }
    
    #if os(iOS)
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
    public func redeem(with request: RedeemRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        Macros.dispatch(after: .seconds(1)) {
            switch self.mockRedeemOutcome {
            case .success:
                self.delegate.redeem(with: request, callback)
                
            case .invalid:
                callback?(nil, ClientError.redeemInvalid)
                
            case .claimed:
                callback?(nil, ClientError.redeemClaimed)
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
    
}
