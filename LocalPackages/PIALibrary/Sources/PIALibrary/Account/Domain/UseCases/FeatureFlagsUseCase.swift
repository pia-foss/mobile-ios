
import Foundation


protocol FeatureFlagsUseCaseType {
    typealias Completion = ((Result<FeatureFlagsInformation, NetworkRequestError>) -> Void)
    func callAsFunction(completion: @escaping Completion)
}


class FeatureFlagsUseCase: FeatureFlagsUseCaseType {
    
    let networkClient: NetworkRequestClientType
    let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }
    
    func callAsFunction(completion: @escaping Completion) {
        // The API auth token is not required in the feature flags request
        // so refreshing the tokens can happen in parallel
        refreshAuthTokensChecker.refreshIfNeeded { _ in }
        
        // Get feature flags request
        executeRequest(with: completion)
    }
}

private extension FeatureFlagsUseCase {
    
    func executeRequest(with completion: @escaping Completion) {
        let configuration = FeatureFlagsRequestConfiguration()
        networkClient.executeRequest(with: configuration) { error, dataResponse in
            if let error {
                completion(.failure(error))
            } else {
                guard let data = dataResponse?.data else {
                    completion(.failure(.noDataContent))
                    return
                }
                
                guard let flagsInfo = FeatureFlagsInformation.makeWith(data: data) else {
                    completion(.failure(.unableToDecodeData))
                    return
                }
                
                completion(.success(flagsInfo))
            }
        }
    }
    
}
