//
//  EnumsBuilder.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 18/12/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation

/// Usage example:
/// private enum Cells: Int, EnumsBuilder {
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
