

import Foundation
import NWHttpConnection

struct SubscriptionsRequestConfiguration: NetworkRequestConfigurationType {
    
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .iosSubscriptions
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .get
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = false
    var urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "subscriptions_request.queue")
}

