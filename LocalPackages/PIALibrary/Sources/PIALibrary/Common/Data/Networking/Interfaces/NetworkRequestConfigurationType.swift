
import Foundation
import NWHttpConnection

enum NetworkRequestModule {
    case account
}

enum NetworkRequestContentType: String {
    case json = "application/json"
    case textHtml = "text/html"
    case formData = "multipart/form-data"
}

protocol NetworkRequestConfigurationType {
    
    var networkRequestModule: NetworkRequestModule { get }
    var path: RequestAPI.Path { get }
    var httpMethod: NWConnectionHTTPMethod { get }
    var inlcudeAuthHeaders: Bool { get }
    var otherHeaders: [String: String]? { get }
    var contentType: NetworkRequestContentType { get }
    var urlQueryParameters: [String: String]? { get }
    var responseDataType: NWDataResponseType { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
    var requestQueue: DispatchQueue? { get }
}
