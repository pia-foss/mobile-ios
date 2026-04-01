//
//  AccountProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 9/30/17.
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

/// Business interface related to user account.
public protocol AccountProvider: AnyObject {

    #if os(iOS) || os(tvOS)
    /// The in-app products required to purchase a `Plan`.
    var planProducts: [Plan: InAppProduct]? { get }
    #endif

    /// Returns `true` if accountInfo is nil and loggedIn true.
    var shouldCleanAccount: Bool { get }

    /// Returns `true` if currently logged in, `false` otherwise.
    var isLoggedIn: Bool { get }
    
    /// The user account currently logged in, or `nil` if logged out.
    var currentUser: UserAccount? { get set }
    
    /// The old auth token
    var oldToken: String? { get }

    /// The token to use for api authentication.
    var apiToken: String? { get }

    /// The token to use for protocol authentication.
    var vpnToken: String? { get }
    
    /// The username extracted from the vpn token
    var vpnTokenUsername: String? { get }
    
    /// The password extracted from the vpn token
    var vpnTokenPassword: String? { get }

    /// The public username to be displayed in the views.
    var publicUsername: String? { get }

    /// The password reference object associated with the currentUser, or `nil` if logged out.
    var currentPasswordReference: Data? { get }

    #if os(iOS) || os(tvOS)
    /// The last pending signup request (useful for recovery).
    var lastSignupRequest: SignupRequest? { get }
    #endif

    /**
     It migrates an old persisted non-expiry token into a new expiry one managed by the accounts module.

     - Parameter callback: Returns `nil` on success.
     */
    func migrateOldTokenIfNeeded(_ callback: SuccessLibraryCallback?)

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
     Logs into system using the purchase receipt. The `isLoggedIn` variable becomes `true` on success.

     - Precondition: `isLoggedIn` is `false`.
     - Postcondition:
        - Sets `currentUser` on success.
        - Posts `Notification.Name.PIAAccountDidLogin` on success.
     - Parameter request: The login receipt request.
     - Parameter callback: Returns an `UserAccount`.
     */
    func login(with receiptRequest: LoginReceiptRequest, _ callback: LibraryCallback<UserAccount>?)

    /**
    Logs into system using the login link token directly. The `isLoggedIn` variable becomes `true` on success.

    - Precondition: `isLoggedIn` is `false`.
    - Postcondition:
       - Sets `currentUser` on success.
       - Posts `Notification.Name.PIAAccountDidLogin` on success.
    - Parameter linkToken: A valid token.
    - Parameter callback: Returns an `UserAccount`.
    */
    func login(with linkToken: String, _ callback: ((UserAccount?, Error?) -> Void)?)
    
    /**
    Validates the QR token and generated a new API Token.

    - Precondition: `isLoggedIn` is `false`.
    - Parameter qrToken: A valid qr token.
    - Parameter callback: Returns an `String`.
    */
    func validateLoginQR(with qrToken: String, _ callback: ((String?, (any Error)?) -> Void)?)
    
    /**
     Refreshes information associated with the account currently logged in.
 
     - Precondition: `isLoggedIn` is `true`.
     - Postcondition:
         - Posts `Notification.Name.PIAAccountDidRefresh` on success.
     - Parameter callback: Returns a refreshed `AccountInfo`.
     */
    func refreshAccountInfo(_ callback: LibraryCallback<AccountInfo>?)
    
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
     - Parameter resetPassword: Boolean to reset the password after update the account.
     - Parameter password: The credentials to perform the operation.
     - Parameter callback: Returns the updated `AccountInfo`.
     */
    func update(with request: UpdateAccountRequest, resetPassword reset: Bool, andPassword password: String, _ callback: LibraryCallback<AccountInfo>?)

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
     Deletes the user from PIA servers.

     - Precondition: `isLoggedIn` is `true`.
     - Parameter callback: Returns `nil` on success.
     */
    
    func deleteAccount(_ callback: SuccessLibraryCallback?)
    
    /**
     Remove all data from the plain and secure internal database
     */
    func cleanDatabase()
    
    /**
     Returns the enabled features in the app.
 
     - Parameter callback: Returns `nil` on success.
     */
    func featureFlags(_ callback: SuccessLibraryCallback?)

    #if os(iOS) || os(tvOS)
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
    Send a login link to the email provided as parameter.
    
    - Parameter email: The associated email to the account where the magic link is sent.
    - Parameter callback: Returns `nil` on success.
    */
    func loginUsingMagicLink(withEmail email: String, _ callback: SuccessLibraryCallback?)
    
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
     Lists plans available for renewal.
 
     - Precondition: `currentUser` has a renewable plan.
     - Parameter callback: Returns a list of available plans for renewal.
     */
    func listRenewablePlans(_ callback: LibraryCallback<[Plan]>?)
    
    /**
     Lists plans available from the AppStore and information about the purchase.
     
     - Parameter callback: Returns a AppStoreInformation object containing the list of available products and information about the status of the trial.
     */
    func subscriptionInformation(_ callback: LibraryCallback<AppStoreInformation>?)

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
