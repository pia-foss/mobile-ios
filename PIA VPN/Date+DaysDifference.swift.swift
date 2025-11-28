//
//  AccountProvider.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 28/11/25.
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

  extension Date {
      /// Returns the number of days between this date and another date.
      /// - Parameter date: The date to compare with
      /// - Returns: The number of days between the dates. Positive if this date is after the other date, negative if before.
      func daysDifference(from date: Date) -> Int {
          let calendar = Calendar.current
          let components = calendar.dateComponents([.day], from: date, to: self)
          return components.day ?? 0
      }

      /// Returns the absolute number of days between this date and another date.
      /// - Parameter date: The date to compare with
      /// - Returns: The absolute number of days between the dates.
      func absoluteDaysDifference(from date: Date) -> Int {
          return abs(daysDifference(from: date))
      }

      /// Returns the number of days between this date and now.
      /// - Returns: The number of days. Positive if this date is in the future, negative if in the past.
      func daysFromNow() -> Int {
          return daysDifference(from: Date())
      }

      /// Returns the number of days between now and this date.
      /// - Returns: The number of days. Positive if this date is in the past, negative if in the future.
      func daysUntilNow() -> Int {
          return Date().daysDifference(from: self)
      }
  }
