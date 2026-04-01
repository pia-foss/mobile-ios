

import Foundation
import NWHttpConnection

struct PaymentRequestConfiguration: NetworkRequestConfigurationType {
    
    let networkRequestModule: NetworkRequestModule = .account
    let path: RequestAPI.Path = .iosPayment
    let httpMethod: NWHttpConnection.NWConnectionHTTPMethod = .post
    let contentType: NetworkRequestContentType = .json
    let inlcudeAuthHeaders: Bool = false
    let urlQueryParameters: [String : String]? = nil
    let responseDataType: NWDataResponseType = .jsonData
    
    var body: Data? = nil
    var otherHeaders: [String : String]? = nil
    
    let timeout: TimeInterval = 10
    let requestQueue: DispatchQueue? = DispatchQueue(label: "payment_request.queue")
}

