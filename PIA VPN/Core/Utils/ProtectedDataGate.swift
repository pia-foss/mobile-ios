//
//  ProtectedDataGate.swift
//  PIA VPN
//
//  Created by Mario on 22/10/26.
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

import Combine
import PIALibrary
import UIKit

private let log = PIALogger.logger(for: ProtectedDataGate.self)

/// Defers work until first unlock, before which the keychain and `UserDefaults` read as empty.
final class ProtectedDataGate {

    private let isProtectedDataAvailable: () -> Bool
    private let notificationCenter: NotificationCenter
    private var cancellable: AnyCancellable?

    init(
        isProtectedDataAvailable: @escaping () -> Bool = { UIApplication.shared.isProtectedDataAvailable },
        notificationCenter: NotificationCenter = .default
    ) {
        self.isProtectedDataAvailable = isProtectedDataAvailable
        self.notificationCenter = notificationCenter
    }

    /// Runs `work` now if protected data is readable, otherwise once it becomes available.
    func whenAvailable(_ work: @escaping () -> Void) {
        guard !isProtectedDataAvailable() else {
            work()
            return
        }

        log.info("Protected data unavailable, deferring start until the device is unlocked")
        cancellable =
            notificationCenter
            .publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)
            .first()
            .sink { [weak self] _ in
                log.info("Protected data available, resuming start")
                self?.cancellable = nil
                work()
            }
    }
}
