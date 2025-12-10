
import Foundation
import SwiftyBeaver

private let log = SwiftyBeaver.self

protocol PaymentUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func callAsFunction(with credentials: Credentials, request: Payment, completion: @escaping Completion)
}


class PaymentUseCase: PaymentUseCaseType {
    private let networkClient: NetworkRequestClientType
    private let paymentInformationDataConverter: PaymentInformationDataConverterType
    
    init(networkClient: NetworkRequestClientType, paymentInformationDataConverter: PaymentInformationDataConverterType) {
        self.networkClient = networkClient
        self.paymentInformationDataConverter = paymentInformationDataConverter
    }
    
    func callAsFunction(with credentials: Credentials, request: Payment, completion: @escaping Completion) {
        
        var configuration = PaymentRequestConfiguration()
        
        if let basicAuthHeader = getBasicAuthHeader(for: credentials) {
            configuration.otherHeaders = basicAuthHeader
        }
        
        configuration.body = paymentInformationDataConverter(payment: request)
        
        networkClient.executeRequest(with: configuration) { [weak self] error, dataResponse in
            guard let self else { return }
            
            log.debug("PaymentUseCase: request executed with status code: \(dataResponse?.statusCode)")
            
            if let error {
                log.debug("PaymentUseCase: request executed with error: \(error)")
                self.handleErrorResponse(error, completion: completion)
            } else {
                completion(nil)
            }
        }
        
        
    }
    
    
}


private extension PaymentUseCase {
    func getBasicAuthHeader(for credentials: Credentials) -> [String: String]? {
        guard let authHeatherValue = "\(credentials.username):\(credentials.password)".toBase64() else {
            return nil
        }
        
        return ["Authorization" : "Basic \(authHeatherValue)"]
    }
    
    private func handleErrorResponse(_ error: NetworkRequestError, completion: @escaping Completion) {
        if case .allConnectionAttemptsFailed(statusCode: let statusCode) = error, statusCode == 400 {
            completion(NetworkRequestError.badReceipt)
            return
        }
        completion(error)
    }
}
