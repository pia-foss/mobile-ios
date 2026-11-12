//
//  RestoreSignup+Live.swift
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

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: RestoreSignup.Dependencies.self)

extension RestoreSignup.Dependencies {

    /// - Parameter restorePurchases: Syncs the purchase history with the App Store
    ///   (`AccountProvider.restorePurchases()`), returning the error if it failed. Passed in because
    ///   that async call can't hop off the main actor with a non-`Sendable` provider.
    public static func live(
        restorePurchases: @MainActor @escaping () async -> (any Error)?,
        emit: @MainActor @escaping (RestoreSignup.Output) -> Void
    ) -> RestoreSignup.Dependencies {
        RestoreSignup.Dependencies(
            restorePurchases: {
                guard let error = await restorePurchases() else {
                    log.debug("Restored payment receipt")
                    return .success(Success())
                }
                log.error("Failed to restore payment receipt (error: \(error))")
                return .failure(RestoreSignupError(error))
            },
            emit: emit
        )
    }
}
