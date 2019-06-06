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

    /// Subscription expires/renews after one month.
    case monthly

    /// Subscription expires/renews after one year.
    case yearly
    
    /// Plan expires/renews after one month (price inApp 2019).
    case legacyMonthly
    
    /// Plan expires/renews after one year (price inApp 2019).
    case legacyYearly
    
    /// Plan expires/renews after one month (price before 2019).
    case oldLegacyMonthly
    
    /// Plan expires/renews after one year (price before 2019).
    case oldLegacyYearly

    /// It's a trial plan.
    case trial

    /// Another unspecified plan.
    case other
}
