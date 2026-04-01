
import Foundation

public protocol RenewDedicatedIPUseCaseType {
    typealias Completion = ((Result<Void, NetworkRequestError>) -> Void)
    func callAsFunction(dipToken: String, completion: @escaping Completion)
}

class RenewDedicatedIPUseCase: RenewDedicatedIPUseCaseType {
    private let networkClient: NetworkRequestClientType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }
    
    func callAsFunction(dipToken: String, completion: @escaping Completion) {
        refreshAuthTokensChecker.refreshIfNeeded { [weak self] error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
            } else {
                networkClient.executeRequest(with: makeConfiguration(dipToken: dipToken)) { error, response in
                    if let error {
                        self.handleErrorResponse(error, completion: completion)
                        return
                    }
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    private func makeConfiguration(dipToken: String) -> RenewDedicatedIPRequestConfiguration {
        var configuration = RenewDedicatedIPRequestConfiguration()
        
        let bodyDataDict = ["token": dipToken]
        
        if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
            configuration.body = bodyData
        }
        
        return configuration
    }
    
    private func handleErrorResponse(_ error: NetworkRequestError, completion: @escaping RenewDedicatedIPUseCaseType.Completion) {
        switch error {
            case .allConnectionAttemptsFailed(let statusCode):
                completion(.failure(statusCode == 401 ? NetworkRequestError.unauthorized : error))
                return
            case .connectionError(statusCode: let statusCode, message: let message):
                completion(.failure(statusCode == 401 ? NetworkRequestError.unauthorized : error))
                return
            default:
                completion(.failure(error))
        }
    }
}
