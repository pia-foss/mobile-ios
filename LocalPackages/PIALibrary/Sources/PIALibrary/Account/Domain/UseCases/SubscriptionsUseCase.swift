
import Foundation

protocol SubscriptionsUseCaseType {
    typealias Completion = ((Result<AppStoreInformation?, NetworkRequestError>) -> Void)
    func callAsFunction(receiptBase64: String?, completion: @escaping Completion)
}
class SubscriptionsUseCase: SubscriptionsUseCaseType {
    let networkClient: NetworkRequestClientType
    let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }

    func callAsFunction(receiptBase64: String?, completion: @escaping Completion) {
        
        // The auth token is not required in the Subscriptions request
        // That's why refreshing the tokens if needed can be executed in parallel
        refreshAuthTokensChecker.refreshIfNeeded { _ in }
        
        executeRequest(with: receiptBase64, completion: completion)
        
    }
    
    
}

private extension SubscriptionsUseCase {
    
    func executeRequest(with receiptBase64: String?, completion: @escaping Completion) {
        var configuration = SubscriptionsRequestConfiguration()
        
        var queryParams: [String: String] = [
            "type": "subscription"
        ]
        
        if let receiptBase64 {
            queryParams["receipt"] = receiptBase64
        }
        
        configuration.urlQueryParameters = queryParams
        
        networkClient.executeRequest(with: configuration) { error, dataResponse in
            
            if let error {
                completion(.failure(error))
            } else {
                if let dataContent = dataResponse?.data {
                    if let appStoreInfo = try? JSONDecoder().decode(AppStoreInformation.self, from: dataContent) {
                        completion(.success(appStoreInfo))
                    } else {
                        completion(.failure(.unableToDecodeData))
                    }
                } else {
                    completion(.failure(.noDataContent))
                }
            }
        }
        
    }
    
}
