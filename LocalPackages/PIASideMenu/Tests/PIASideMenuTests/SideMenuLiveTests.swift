//
//  SideMenuLiveTests.swift
//  PIASideMenuTests
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
import Testing

@testable import PIASideMenu

struct SideMenuLiveTests {

    @Test(
        "Time left rounds down to days, then hours",
        arguments: [
            (DateComponents(day: 3, hour: 5), SideMenu.Expiration.days(3)),
            (DateComponents(day: 0, hour: 5), .hours(5)),
            (DateComponents(day: 0, hour: 0), .underAnHour),
            (DateComponents(day: -1, hour: -2), .underAnHour)
        ])
    func expiration(timeLeft: DateComponents, expected: SideMenu.Expiration) {
        #expect(SideMenu.Expiration(timeLeft: timeLeft) == expected)
    }

    @Test(
        "Legacy products renew as today's plan of the same length",
        arguments: [
            (String?.some(AppConstants.InApp.monthlyProductIdentifier), Plan?.some(.monthly)),
            (AppConstants.LegacyInApp.oldMonthlyProductIdentifier, .monthly),
            (AppConstants.InApp.yearlyProductIdentifier, .yearly),
            (AppConstants.LegacyInApp.yearlyOctober2020ProductIdentifier, .yearly),
            ("com.example.unknown", nil),
            (nil, nil)
        ])
    func renewalPlan(productId: String?, expected: Plan?) {
        #expect(SideMenu.Dependencies.renewalPlan(forProductId: productId) == expected)
    }
}
