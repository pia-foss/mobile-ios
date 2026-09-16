//
//  KapePlatformSDKTunnelProfile+IPC.swift
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

import NetworkExtension

/// Questions the app asks the PacketTunnel extension, over `sendProviderMessage`.
///
/// Each one encodes a `PIAPacketTunnelRequest` and decodes the reply; the payload types live
/// alongside that enum in `KapePlatformSDK/IPC/`. All of them answer "nothing" rather than failing
/// when no tunnel process is running, since being disconnected is the ordinary case, not an error.
///
/// Commands are deliberately not here: `sendSwitchLocationMessage` stays next to `connect`, its only
/// caller, because it is a step of connecting rather than a query with a reply.
extension KapePlatformSDKTunnelProfile {

    public func requestLog(withCustomConfiguration customConfiguration: (any VPNCustomConfiguration)?, _ callback: LibraryCallback<String>?) {
        find { (vpn, error) in
            guard let session = vpn?.connection as? NETunnelProviderSession else {
                callback?(nil, error)
                return
            }
            do {
                let data = try JSONEncoder().encode(PIAPacketTunnelRequest.requestLog)
                try session.sendProviderMessage(data) { response in
                    guard let response, let log = String(data: response, encoding: .utf8), !log.isEmpty else {
                        callback?(nil, nil)
                        return
                    }
                    callback?(log, nil)
                }
            } catch {
                callback?(nil, error)
            }
        }
    }

    /// Queries the extension for the active session's cumulative tx/rx via a
    /// `dataUsage` provider message and maps the reply into `Usage`. Returns
    /// `nil` (no usage) when disconnected or when the active protocol cannot
    /// report counters — the extension answers with an empty response.
    public func requestDataUsage(withCustomConfiguration customConfiguration: (any VPNCustomConfiguration)?, _ callback: LibraryCallback<Usage>?) {
        find { (vpn, error) in
            guard let session = vpn?.connection as? NETunnelProviderSession else {
                callback?(nil, error)
                return
            }
            do {
                let data = try JSONEncoder().encode(PIAPacketTunnelRequest.dataUsage)
                try session.sendProviderMessage(data) { response in
                    guard let response,
                        let usage = try? JSONDecoder().decode(PIADataUsage.self, from: response)
                    else {
                        callback?(nil, nil)
                        return
                    }
                    // Map received→downloaded, sent→uploaded.
                    callback?(Usage(uploaded: usage.bytesSent, downloaded: usage.bytesReceived), nil)
                }
            } catch {
                callback?(nil, error)
            }
        }
    }

    /// Queries the extension for the endpoints it will attempt, in attempt order, via a
    /// `connectionConfigurations` provider message. Returns an empty list when the tunnel process
    /// isn't running (nothing to ask) or hasn't generated a batch yet.
    public func requestConnectionConfigurations(_ callback: LibraryCallback<[PIAConnectionConfiguration]>?) {
        find { (vpn, error) in
            guard let session = vpn?.connection as? NETunnelProviderSession else {
                callback?(nil, error)
                return
            }
            do {
                let data = try JSONEncoder().encode(PIAPacketTunnelRequest.connectionConfigurations)
                try session.sendProviderMessage(data) { response in
                    guard let response,
                        let configurations = try? JSONDecoder().decode([PIAConnectionConfiguration].self, from: response)
                    else {
                        callback?(nil, nil)
                        return
                    }
                    callback?(configurations, nil)
                }
            } catch {
                callback?(nil, error)
            }
        }
    }
}
