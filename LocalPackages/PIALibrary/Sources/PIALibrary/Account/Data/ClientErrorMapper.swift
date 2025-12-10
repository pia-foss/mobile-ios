

import Foundation

/// Maps an Network Error with a ClientError
/// The idea is to use this mapper on `PIAWebServices` to map the errors returned from the Swift implementation of the Accounts Lib with the ones that the app expects
struct ClientErrorMapper {
    static func map(networkRequestError: NetworkRequestError) -> ClientError {
        switch networkRequestError {
        case .connectionError(let statusCode, let message):
            return getClientError(from: statusCode) ?? .unexpectedReply
               
        case .allConnectionAttemptsFailed(let statusCode):
            return getClientError(from: statusCode) ?? .unexpectedReply
            
        case .noDataContent:
            return .malformedResponseData
            
        case .noErrorAndNoResponse:
            return .unexpectedReply
            
        case .unableToSaveVpnToken:
            return .unexpectedReply
            
        case .unableToSaveAPIToken:
            return .unexpectedReply

        case .connectionCompletedWithNoResponse:
            return .malformedResponseData
            
        case .unknown(message: let message):
            return .unexpectedReply
            
        case .unableToDecodeAPIToken, .unableToDecodeDataContent:
            return .malformedResponseData
            
        case .unableToDecodeVpnToken:
            return .malformedResponseData
            
        case .badReceipt:
            return .badReceipt
            
        case .unableToDecodeData:
            return .malformedResponseData
            
        case .unauthorized:
            return .unauthorized
        }
    }
    
    static func getClientError(from statusCode: Int?) -> ClientError? {
        
        guard let statusCode,
              let httpStatusCode = HttpResponseStatusCode(rawValue: statusCode) else {
            return nil
        }
        switch httpStatusCode {
        case .unauthorized:
            return .unauthorized
        case .throttled:
            return .throttled(retryAfter: 60)
        default:
            return nil
        }
    }
    
    
}
