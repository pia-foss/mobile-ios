//
//  AccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 9/30/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Business interface related to user account.
public protocol AccountProvider: class {

    #if os(iOS)
    /// The in-app products required to purchase a `Plan`.
    var planProducts: [Plan: InAppProduct]? { get }
    #endif

    /// Returns `true` if accountInfo is nil and loggedIn true.
    var shouldCleanAccount: Bool { get }

    /// Returns `true` if currently logged in, `false` otherwise.
    var isLoggedIn: Bool { get }
    
    /// The user account currently logged in, or `nil` if logged out.
    var currentUser: UserAccount? { get set }

    /// The current auth token, or 'nil' if logged out.
    var token: String? { get }

    /// The public username to be displayed in the views.
    var publicUsername: String? { get }

    /// The password reference object associated with the currentUser, or `nil` if logged out.
    var currentPasswordReference: Data? { get }

    #if os(iOS)
    /// The last pending signup request (useful for recovery).
    var lastSignupRequest: SignupRequest? { get }
    #endif

    /**
     Logs into system. The `isLoggedIn` variable becomes `true` on success.
 
     - Precondition: `isLoggedIn` is `false`.
     - Postcondition:
         - Sets `currentUser` on success.
         - Posts `Notification.Name.PIAAccountDidLogin` on success.
     - Parameter request: The login request.
     - Parameter callback: Returns an `UserAccount`.
     */
    func login(with request: LoginRequest, _ callback: LibraryCallback<UserAccount>?)

    /**
     Refreshes information associated with the account currently logged in.
 
     - Precondition: `isLoggedIn` is `true`.
     - Postcondition:
         - Posts `Notification.Name.PIAAccountDidRefresh` on success.
     - Parameter callback: Returns a refreshed `AccountInfo`.
     - Parameter force: Force refresh.
     */
    func refreshAccountInfo(force: Bool, _ callback: LibraryCallback<AccountInfo>?)
    
    /**
     Retrieves information associated with the account currently logged in.
     
     - Precondition: `isLoggedIn` is `true`.
     - Postcondition:
     - Posts `Notification.Name.PIAAccountDidRefresh` on success.
     - Parameter callback: Returns a refreshed `AccountInfo`.
     */
    func accountInformation(_ callback: ((AccountInfo?, Error?) -> Void)?)

    /**
     Updates the account currently logged in.
 
     - Precondition: `isLoggedIn` is `true`.
     - Postcondition:
         - Posts `Notification.Name.PIAAccountDidUpdate` on success.
     - Parameter request: The account update request.
     - Parameter password: The credentials to perform the operation.
     - Parameter callback: Returns the updated `AccountInfo`.
     */
    func update(with request: UpdateAccountRequest, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?)

    /**
     Logs out of the system.

     - Precondition: `isLoggedIn` is `true`.
     - Postcondition:
         - Unsets `currentUser` on success.
         - Posts `Notification.Name.PIAAccountDidLogout` on success.
     - Parameter callback: Returns `nil` on success.
     */
    func logout(_ callback: SuccessLibraryCallback?)
    
    /**
     Remove all data from the plain and secure internal database
     */
    func cleanDatabase()
    
    #if os(iOS)
    /**
     Lists the available plans with their corresponding product to purchase in order to get them.
     
     - Parameter callback: Returns a map of `Plan`s with the associated `InAppProduct` to purchase.
     */
    func listPlanProducts(_ callback: LibraryCallback<[Plan: InAppProduct]>?)

    /**
     Purchases a subscription plan and save purchase to history.

     - Parameter plan: The plan to purchase.
     - Parameter callback: Returns an `InAppTransaction` for subsequent sign-up.
     */
    func purchase(plan: Plan, _ callback: LibraryCallback<InAppTransaction>?)
    
    /**
     Check if the user has access to our servers from the country where is based.
     
     - Parameter callback: Returns a boolean indicating if the operation was successfully or not.
     */
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?)

    /**
     Restores the purchase history, possibly recovering from corruption.
     
     - Parameter callback: Returns `nil` on success.
     */
    func restorePurchases(_ callback: SuccessLibraryCallback?)
    
    /**
     Signs up with current purchase history.
     
     - Precondition: `isLoggedIn` is `false`.
     - Postcondition:
         - Sets `currentUser` on success.
         - Sets `lastSignupRequest` to `request` until success.
         - Posts `Notification.Name.PIAAccountDidSignup` on success.
     - Parameter request: The signup request.
     - Parameter callback: Returns a newly created `UserAccount`.
     */
    func signup(with request: SignupRequest, _ callback: LibraryCallback<UserAccount>?)

    /**
     Signs up with a redeem code.
 
     - Precondition: `isLoggedIn` is `false`.
     - Postcondition:
        - Sets `currentUser` on success.
        - Posts `Notification.Name.PIAAccountDidSignup` on success.
     - Parameter request: The redeem request.
     - Parameter callback: Returns a newly created `UserAccount`.
     */
    func redeem(with request: RedeemRequest, _ callback: LibraryCallback<UserAccount>?)
    
    /**
     Lists plans available for renewal.
 
     - Precondition: `currentUser` has a renewable plan.
     - Parameter callback: Returns a list of available plans for renewal.
     */
    func listRenewablePlans(_ callback: LibraryCallback<[Plan]>?)
    
    /**
     Lists plans available for purchase or renewal in the PIA database.
     
     - Parameter callback: Returns a list of available plans.
     */
    func updatePlanProductIdentifiers(_ callback: LibraryCallback<[Product]>?)

    /**
     Renews expiring plan with current purchase history.
     
     - Precondition: `currentUser` has a renewable plan.
     - Postcondition:
         - Posts `Notification.Name.PIAAccountDidRenew` on success.
         - Posts `Notification.Name.PIAAccountDidRefresh` on success if also able to refresh the account info.
     - Parameter request: The renew request.
     - Parameter callback: Returns the updated `UserAccount`.
     - Seealso: `UserAccount.isRenewable`.
     */
    func renew(with request: RenewRequest, _ callback: LibraryCallback<UserAccount>?)
    #endif
}
