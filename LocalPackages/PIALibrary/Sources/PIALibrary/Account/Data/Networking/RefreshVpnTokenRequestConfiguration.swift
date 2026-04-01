
import Foundation
import NWHttpConnection

struct RefreshVpnTokenRequestConfiguration: NetworkRequestConfigurationType {
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .vpnToken
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = true
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    let body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "refresh.vpn_token.queue")
}
