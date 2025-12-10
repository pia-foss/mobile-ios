import Foundation
import NWHttpConnection


protocol NetworkRequestResponseType {
    var statusCode: Int? { get }
    var data: Data? { get }
}

extension NWHttpConnectionDataResponse: NetworkRequestResponseType {
}

