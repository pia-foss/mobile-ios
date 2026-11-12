//
//  RestoreSignupError.swift
//  PIALogin
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

import PIALibrary
import PIALocalizations

public enum RestoreSignupError: Error, Equatable, Sendable {
    /// No receipt, or one the backend rejected.
    case nothingToRestore
    /// Anything else, already localized.
    case failed(message: String)
}

extension RestoreSignupError {
    init(_ error: any Error) {
        switch error as? ClientError {
        case .noReceipt, .badReceipt: self = .nothingToRestore
        default: self = .failed(message: error.localizedDescription)
        }
    }

    var message: String {
        switch self {
        case .nothingToRestore: L10n.Account.Restore.Failure.message
        case .failed(let message): message
        }
    }
}
