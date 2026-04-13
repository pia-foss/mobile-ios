//
//  ServersBundle+DTO.swift
//  PIALibrary
//
//  Created by Mario on 02/03/2026.
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

// MARK: - Private DTOs

private struct ProtocolGroupEntryDTO: Decodable {
    let name: String
    let ports: [UInt16]
}

private struct ConfigurationDTO: Decodable {
    let ovpntcp: [ProtocolGroupEntryDTO]?
    let ovpnudp: [ProtocolGroupEntryDTO]?
    let wg: [ProtocolGroupEntryDTO]?
    let ikev2: [ProtocolGroupEntryDTO]?

    func toConfiguration() -> ServersBundle.Configuration {
        let ovpnTCPPorts = ovpntcp?.first(where: { $0.name == "openvpn_tcp" })?.ports ?? []
        let ovpnUDPPorts = ovpnudp?.first(where: { $0.name == "openvpn_udp" })?.ports ?? []
        let wgPorts = wg?.first(where: { $0.name == "wg" || $0.name == "wireguard" })?.ports ?? []
        let ikev2Ports = ikev2?.first(where: { $0.name == "ikev2" })?.ports ?? []
        return ServersBundle.Configuration(
            ovpnPorts: .init(udp: ovpnUDPPorts, tcp: ovpnTCPPorts),
            wgPorts: .init(udp: wgPorts, tcp: []),
            ikev2Ports: .init(udp: ikev2Ports, tcp: []),
            latestVersion: 102,
            pollInterval: 60_0000,
            automaticIdentifiers: nil
        )
    }
}

private struct ServersBundleDTO: Decodable {
    let groups: ConfigurationDTO
    let regions: [Server]

    func toServersBundle() -> ServersBundle {
        let sorted = regions.filter { !$0.country.isEmpty }.sorted { $0.name < $1.name }
        return ServersBundle(servers: sorted, configuration: groups.toConfiguration())
    }
}

// MARK: - ServersBundle parsing

private let log = PIALogger.logger(for: ServersBundle.self)

extension ServersBundle {
    static func parse(from data: Data) -> ServersBundle? {
        do {
            let dto = try JSONDecoder().decode(ServersBundleDTO.self, from: data)
            return dto.toServersBundle()
        } catch {
            log.error("Failed to parse servers JSON")
            log.debug("ServersBundleDTO decode error: \(error.localizedDescription)")
            return nil
        }
    }

    static func parse(from jsonString: String) -> ServersBundle? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return parse(from: data)
    }
}
