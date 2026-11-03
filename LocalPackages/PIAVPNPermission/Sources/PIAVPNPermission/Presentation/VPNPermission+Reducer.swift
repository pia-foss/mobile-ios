//
//  VPNPermission+Reducer.swift
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

import CoreArchitecture

extension VPNPermission {

    struct Reducer: Sendable {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return .task { [dependencies] in
                    .mailAvailabilityLoaded(canSendMail: dependencies.canSendMail())
                }

            case .mailAvailabilityLoaded(let canSendMail):
                state.canContactSupport = canSendMail
                return nil

            case .submitTapped:
                guard state.phase == .idle else { return nil }
                state.phase = .requesting
                return .task { [dependencies] in
                    .permissionResult(await dependencies.requestPermission())
                }

            case .permissionResult(.success):
                guard state.phase == .requesting else { return nil }
                state.phase = .finished
                return .fireAndForget { [dependencies] in
                    dependencies.emit(.granted)
                }

            case .permissionResult(.failure):
                guard state.phase == .requesting else { return nil }
                state.phase = .denied
                return nil

            case .deniedAcknowledged:
                // Only closes the dialog: the person retries with the screen's own button. Retrying
                // from here looped forever when the install failed instantly (KM-17461).
                guard state.phase == .denied else { return nil }
                state.phase = .idle
                return nil

            case .contactSupportTapped:
                guard state.phase == .denied else { return nil }
                state.phase = .idle
                return .fireAndForget { [dependencies] in
                    dependencies.emit(.contactSupport)
                }
            }
        }
    }
}
