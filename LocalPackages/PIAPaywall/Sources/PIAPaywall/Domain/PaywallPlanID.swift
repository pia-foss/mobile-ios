//
//  PaywallPlanID.swift
//  PIAPaywall
//
//  Copyright © 2026 Private Internet Access, Inc.
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
import PIALibrary

/// The plans the paywall can offer.
///
/// A deliberately narrower type than `PIALibrary.Plan`, which also has `.trial` and `.other` —
/// neither is purchasable here, and modelling them would mean handling states that cannot occur.
public enum PaywallPlanID: String, Equatable, CaseIterable, Sendable {
    case yearly
    case monthly

    var libraryPlan: Plan {
        switch self {
        case .yearly: return .yearly
        case .monthly: return .monthly
        }
    }

    /// How many months one billing period covers. Used to derive the "/mo" equivalent price.
    var monthlyFactor: Decimal {
        switch self {
        case .yearly: return 12
        case .monthly: return 1
        }
    }
}
