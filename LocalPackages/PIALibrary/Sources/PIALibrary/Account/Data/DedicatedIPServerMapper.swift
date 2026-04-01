
import Foundation

class DedicatedIPServerMapper: DedicatedIPServerMapperType {
    private let dedicatedIPTokenHandler: DedicatedIPTokenHandlerType
    
    init(dedicatedIPTokenHandler: DedicatedIPTokenHandlerType) {
        self.dedicatedIPTokenHandler = dedicatedIPTokenHandler
    }
    
    func map(dedicatedIps: [DedicatedIPInformation]) -> Result<[Server], ClientError> {
        var dipRegions = [Server]()
        
        for dipServer in dedicatedIps {
            let status = DedicatedIPStatus(fromAPIStatus: dipServer.status)

            switch dipServer.status {
            case .active:

                guard let firstServer = Client.providers.serverProvider.currentServers.first(where: {$0.regionIdentifier == dipServer.id}) else {
                    return .failure(ClientError.malformedResponseData)
                }

                guard let ip = dipServer.ip, let cn = dipServer.cn, let expirationTime = dipServer.dipExpire else {
                    return .failure(ClientError.malformedResponseData)
                }

                let dipUsername = "dedicated_ip_"+dipServer.dipToken+"_"+String.random(length: 8)
                let expiringDate = Date(timeIntervalSince1970: TimeInterval(expirationTime))
                let server = Server.ServerAddressIP(ip: ip, cn: cn, van: false)
                
                let dipRegion = Server(serial: firstServer.serial, name: firstServer.name, country: firstServer.country, hostname: firstServer.hostname, openVPNAddressesForTCP: [server], openVPNAddressesForUDP: [server], wireGuardAddressesForUDP: [server], iKEv2AddressesForUDP: [server], pingAddress: firstServer.pingAddress, geo: false, meta: nil, dipExpire: expiringDate, dipToken: dipServer.dipToken, dipStatus: status, dipUsername: dipUsername, regionIdentifier: firstServer.regionIdentifier)

                dipRegions.append(dipRegion)
                dedicatedIPTokenHandler(dedicatedIp: dipServer, dipUsername: dipUsername)

            default:

                let dipRegion = Server(serial: "", name: "", country: "", hostname: "", openVPNAddressesForTCP: [], openVPNAddressesForUDP: [], wireGuardAddressesForUDP: [], iKEv2AddressesForUDP: [], pingAddress: nil, geo: false, meta: nil, dipExpire: nil, dipToken: nil, dipStatus: status, dipUsername: nil, regionIdentifier: "")
                dipRegions.append(dipRegion)
            }
        }
        
        return .success(dipRegions)
    }
}
