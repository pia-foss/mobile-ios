//
//  InAppTransaction.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/22/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// Wraps any native implementation of an in-app transaction by providing a common interface.
public protocol InAppTransaction: class, CustomStringConvertible {

    /// The transaction identifier.
    var identifier: String? { get }

    /// The underlying native transaction implementation.
    var native: Any? { get }
}

extension InAppTransaction {
    var description: String {
        return identifier ?? "InAppTransaction"
    }
}
