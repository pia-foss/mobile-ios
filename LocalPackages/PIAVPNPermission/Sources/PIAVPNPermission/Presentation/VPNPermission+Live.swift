//
//  VPNPermission+Live.swift
//  PIAVPNPermission
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

private let log = Logger(label: String(describing: VPNPermission.Dependencies.self))

extension VPNPermission.Dependencies {

    /// - Parameters:
    ///   - obtainPermission: Installs the VPN profile, calling back with `nil` on success. The
    ///     callback may arrive on any queue.
    public static func live(
        obtainPermission: @MainActor @escaping (@escaping @Sendable ((any Error)?) -> Void) -> Void,
        canSendMail: @MainActor @escaping () -> Bool,
        emit: @MainActor @escaping (VPNPermission.Output) -> Void
    ) -> VPNPermission.Dependencies {
        VPNPermission.Dependencies(
            requestPermission: {
                await withCheckedContinuation { continuation in
                    obtainPermission { error in
                        if let error {
                            log.error("Failed to obtain VPN permission: \(error)")
                            continuation.resume(returning: .failure(error))
                        } else {
                            continuation.resume(returning: .success(()))
                        }
                    }
                }
            },
            canSendMail: canSendMail,
            emit: emit
        )
    }
}
