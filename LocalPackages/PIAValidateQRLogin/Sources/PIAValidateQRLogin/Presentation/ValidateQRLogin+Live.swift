//
//  ValidateQRLogin+Live.swift
//  PIAValidateQRLogin
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
import Logging
import PIAAccount

private let log = Logger(label: String(describing: ValidateQRLogin.Dependencies.self))

extension ValidateQRLogin.Dependencies {

    public static func live(
        qrToken: String,
        accountAPI: PIAAccountAPI,
        discardQRToken: @Sendable @escaping () -> Void,
        emit: @MainActor @escaping (ValidateQRLogin.Output) -> Void
    ) -> ValidateQRLogin.Dependencies {
        ValidateQRLogin.Dependencies(
            validate: {
                do {
                    try await accountAPI.bindLoginQR(qrToken: qrToken)
                    return .success(())
                } catch {
                    log.error("Binding the QR login token failed: \(error)")
                    return .failure(error)
                }
            },
            discardQRToken: discardQRToken,
            emit: emit
        )
    }
}
