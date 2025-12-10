//
//  Preset.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
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

/// Optional preset values for welcome forms.
@available(tvOS 17.0, *)
public struct Preset: ProvidersAccess {
    
    /// The `Pages` to display in the scroller.
    public var pages = Pages.all
    
    /// If `true`, the controller can be cancelled.
    public var allowsCancel = false
    
    /// The login username.
    public var loginUsername: String?
    
    /// The login password.
    public var loginPassword: String?
    
    /// The purchase email address.
    public var purchaseEmail: String?
    
    /// The redeem email address.
    public var redeemEmail: String?
    
    /// The redeem code.
    public var redeemCode: String?
    
    /// If `true`, tries to recover any pending signup process.
    public var shouldRecoverPendingSignup = true
    
    /// If `true`, shows variations based on the user expiration.
    public var isExpired = false
    
    /// If `true`, doesn't persist state to current `Client.database`.
    public var isEphemeral = false
    
    public var accountProvider: AccountProvider {
        return (isEphemeral ? EphemeralAccountProvider() : accessedProviders.accountProvider)
    }
    
    /// If `true`, the view controller is opened from Dashboard.
    public var openFromDashboard = false
    
    /// Default initializer.
    public init() {
    }
}
