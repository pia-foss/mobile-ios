import Foundation
import KapeVPN_PacketTunnel
import PIALibrary

final class PIAEndpointRepository: VpnConfigurationGenerator, Sendable {
    private static let wireGuardPort: UInt16 = 1337

    private let logger = PIATunnelLogger(label: "PIAEndpointRepository")

    func generateConfigurations() async -> [any VpnConfiguration] {
        logger.info("Generating WireGuard configurations")

        guard let locationId = preferredLocationId() else {
            logger.error("No preferred location id found in shared app group — returning no configurations")
            return []
        }
        logger.debug("Preferred location id: \(locationId)")

        guard
            let server = getServers(for: locationId).first,
            let addresses = server.wireGuardAddressesForUDP,
            !addresses.isEmpty
        else {
            logger.error("No WireGuard UDP addresses found for location \(locationId) — returning no configurations")
            return []
        }
        logger.info("Found server \(server.name) with \(addresses.count) WireGuard UDP address(es)")

        let configurations: [any VpnConfiguration] = addresses.compactMap { address in
            let ip = IpAddress.v4(ipV4: address.ip)
            let endpoint = WireguardEndpointConfiguration(
                ip: ip,
                port: Self.wireGuardPort,
                authIp: ip,
                authPort: Self.wireGuardPort,
                certDn: address.cn,
                obfuscation: .none
            )
            logger.debug("Built endpoint \(address.ip):\(Self.wireGuardPort) (cn: \(address.cn))")
            return KapeWireGuardConfig(
                endpointConfiguration: endpoint,
                host: address.ip,
                port: Self.wireGuardPort,
                obfuscation: .none
            )
        }

        logger.info("Generated \(configurations.count) WireGuard configuration(s)")
        return configurations
    }

    // MARK: - Helpers

    // The main app stores the user's selected server identifier under "CurrentRegion"
    // in the shared app group UserDefaults (written by Client.preferences.preferredServer).
    // server.identifier is the first hostname component, e.g. "frankfurt401".
    private func preferredLocationId() -> String? {
        UserDefaults(suiteName: AppConstants.appGroup)?.string(forKey: "CurrentRegion")
    }

    private func getServers(for locationId: String) -> [Server] {
        struct RegionsFile: Decodable {
            let regions: [Server]
        }

        guard
            let bundledRegionsURL = AppConstants.RegionsGEN4.bundleURL,
            let data = try? Data(contentsOf: bundledRegionsURL),
            let regions = try? JSONDecoder().decode(RegionsFile.self, from: data).regions
        else {
            logger.error("Failed to load or decode bundled regions file")
            return []
        }

        let matches = regions.filter { $0.identifier == locationId }
        logger.debug("Matched \(matches.count) region(s) for location id \(locationId) out of \(regions.count) total")
        return matches
    }
}
