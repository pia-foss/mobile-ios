//
//  DedicatedIP+Live.swift
//  PIADedicatedIP
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
import PIABase
import PIALibrary

private let log = PIALogger.logger(for: DedicatedIP.Dependencies.self)

// The use cases are built by the host, so nothing here reaches for `Client`.
extension DedicatedIP.Dependencies {

    public static func live(
        getDedicatedIp: GetDedicatedIpUseCaseType,
        activateDIPToken: ActivateDIPTokenUseCaseType,
        removeDIPToken: RemoveDIPUseCaseType,
        emit: @MainActor @escaping (DedicatedIP.Output) -> Void
    ) -> DedicatedIP.Dependencies {
        DedicatedIP.Dependencies(
            getDedicatedIP: { getDedicatedIp().map(DedicatedIP.Info.init) },
            activate: { token in
                await activateDIPToken(token: token)
                    .map(DedicatedIP.Info.init)
                    .mapError(DedicatedIP.Failure.init)
            },
            remove: {
                do {
                    try await removeDIPToken()
                } catch {
                    log.error("Failed to remove DIP token:\(error)")
                }
            },
            emit: emit
        )
    }
}

extension DedicatedIP.Info {
    fileprivate init(_ server: ServerType) {
        self.init(name: server.name, country: server.country.lowercased(), ip: server.dipIKEv2IP)
    }
}

extension DedicatedIP.Failure {
    fileprivate init(_ error: DedicatedIPError) {
        switch error {
        case .alreadyHasOne:
            self = .alreadyHasOne
        case .expired:
            self = .expired
        case .invalid:
            self = .invalid
        case .generic(let underlying):
            switch underlying as? ClientError {
            case .unauthorized?:
                log.error("Activate DIP token failed with unauthorized error")
                self = .unauthorized
            case .throttled(let retryAfter)?:
                self = .throttled(retryAfter: TimeInterval(retryAfter))
            default:
                self = .invalid
            }
        }
    }
}
