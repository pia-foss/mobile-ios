
import Foundation
import NWHttpConnection

struct UpdateAccountRequestConfiguration: NetworkRequestConfigurationType {
    
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .setEmail
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let contentType: NetworkRequestContentType = .json
    var inlcudeAuthHeaders: Bool = true
    var urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "updateAccount_request.queue")
}

