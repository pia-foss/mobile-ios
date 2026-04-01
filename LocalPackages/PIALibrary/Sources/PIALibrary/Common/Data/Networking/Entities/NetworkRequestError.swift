
import Foundation

public enum NetworkRequestError: Error, Equatable {
    case connectionError(statusCode: Int? = nil, message: String? = nil)
    case allConnectionAttemptsFailed(statusCode: Int? = nil)
    case noDataContent
    case noErrorAndNoResponse
    case unableToSaveVpnToken
    case unableToSaveAPIToken
    case unableToDecodeAPIToken
    case unableToDecodeVpnToken
    case unableToDecodeDataContent
    case connectionCompletedWithNoResponse
    case badReceipt
    case unauthorized
    case unknown(message: String? = nil)
    case unableToDecodeData
    
    func asClientError() -> ClientError {
        ClientErrorMapper.map(networkRequestError: self)
    }
}


enum HttpResponseStatusCode: Int {
    case success = 200
    case throttled = 429
    case unauthorized = 401
}
