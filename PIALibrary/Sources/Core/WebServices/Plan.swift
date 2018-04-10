//
//  Plan.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// The available subscription plans.
public enum Plan: String {

    /// Plan expires/renews after one month.
    case monthly

    /// Plan expires/renews after one year.
    case yearly
    
    /// It's a trial plan.
    case trial

    /// Another unspecified plan.
    case other
}
