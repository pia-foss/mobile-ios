
import Foundation
import NWHttpConnection

struct GetDedicatedIPsRequestConfiguration: NetworkRequestConfigurationType {
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .dedicatedIp
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let contentType: NetworkRequestContentType = .json
    var inlcudeAuthHeaders: Bool = true
    var urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .rawData
    
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "getDedicatedIPs_request.queue")
}
