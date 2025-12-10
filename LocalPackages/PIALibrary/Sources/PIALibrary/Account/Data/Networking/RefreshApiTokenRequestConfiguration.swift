
import Foundation
import NWHttpConnection

struct RefreshApiTokenRequestConfiguration: NetworkRequestConfigurationType {
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .refreshApiToken
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = true
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    let body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "refresh.api_token.queue")
}
