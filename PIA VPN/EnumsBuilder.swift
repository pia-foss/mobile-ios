//
//  EnumsBuilder.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2020 Private Internet Access Inc.
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

import Foundation

/// Usage example:
/// fileprivate enum Cells: Int, EnumsBuilder {
///     case updateAmount = 0
///     case totalAmount = 1
///     var identifier: String {
///         switch self {
///         case .updateAmount: return "updateAmountCell"
///         case .totalAmount: return "totalAmountCell"
///         }
///     }
/// }
///
/// Cells.objectIdentifyBy(index: indexPath.row).identifier // eg. "totalAmountCell"
protocol EnumsBuilder {}
extension EnumsBuilder where Self: RawRepresentable, Self.RawValue == Int {
    static func objectIdentifyBy(index: Int) -> Self {
        guard let object = Self(rawValue: index) else {
            fatalError("Object identifier not implemented")
        }
        return object
    }
    static func countCases() -> Int {
        var numCases = 0
        while Self(rawValue: numCases) != nil {
            numCases += 1
        }
        return numCases
    }
}
extension EnumsBuilder where Self: RawRepresentable, Self.RawValue == String {
    static func objectIdentifyBy(name: String) -> Self {
        guard let object = Self(rawValue: name) else {
            fatalError("Object identifier not implemented")
        }
        return object
    }
}
