//
//  Client+ServerList.swift
//  PIALibrary
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

extension Client {

    /// Fetches the current VPN server list from the backend, or `nil` on any failure.
    ///
    /// Reuses the app's web-services fetch path (endpoint resolution, RSA-signature verification,
    /// parsing). It is safe to call from the PlatformSDK tunnel extension, where `Client` is not
    /// bootstrapped: the default `webServices` resolves the public regions host on its own and the
    /// fetch performs no app-state mutations.
    ///
    /// Callers throttle how often they call this themselves; the result is cached across connects via
    /// `PIATunnelSharedState.serversFetchedAt`, not here.
    public static func downloadServerList() async -> [Server]? {
        await withCheckedContinuation { continuation in
            webServices.downloadServers { bundle, _ in
                continuation.resume(returning: bundle?.servers)
            }
        }
    }
}
