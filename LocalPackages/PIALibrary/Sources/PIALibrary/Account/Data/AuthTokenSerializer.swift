

import Foundation

protocol AuthTokenSerializerType {
    func decodeAPIToken(from data: Data) -> APIToken?
    func decodeVpnToken(from data: Data) -> VpnToken?
    func encode(apiToken: APIToken) -> String?
    func encode(vpnToken: VpnToken) -> String?
    
}

class AuthTokenSerializer: AuthTokenSerializerType {
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    init() {
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonEncoder.dateEncodingStrategy = .iso8601
    }
    
    func decodeAPIToken(from data: Data) -> APIToken? {
        try? jsonDecoder.decode(APIToken.self, from: data)
    }
    
    func decodeVpnToken(from data: Data) -> VpnToken? {
        try? jsonDecoder.decode(VpnToken.self, from: data)
    }
    
    
    func encode(apiToken: APIToken) -> String? {
        guard let jsonData = try? jsonEncoder.encode(apiToken) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
    func encode(vpnToken: VpnToken) -> String? {
        guard let jsonData = try? jsonEncoder.encode(vpnToken) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    
}

