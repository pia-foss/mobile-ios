//
//  Preset.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

/// Optional preset values for welcome forms.
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
    
    /// If `true`, doesn't persist state to current `Client.database`.
    public var isEphemeral = false
    
    var accountProvider: AccountProvider {
        return (isEphemeral ? EphemeralAccountProvider() : accessedProviders.accountProvider)
    }
    
    /// If `true`, the view controller is opened from Dashboard.
    public var openFromDashboard = false
    
    /// Default initializer.
    public init() {
    }
}
