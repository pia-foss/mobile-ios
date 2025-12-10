
import Foundation

public protocol GetDedicatedIPsUseCaseType {
    typealias Completion = ((Result<[DedicatedIPInformation], NetworkRequestError>) -> Void)
    func callAsFunction(dipTokens: [String], completion: @escaping Completion)
}

class GetDedicatedIPsUseCase: GetDedicatedIPsUseCaseType {
    private let networkClient: NetworkRequestClientType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }
    
    func callAsFunction(dipTokens: [String], completion: @escaping Completion) {
        refreshAuthTokensChecker.refreshIfNeeded { [weak self] error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
            } else {
                networkClient.executeRequest(with: makeConfiguration(dipTokens: dipTokens)) { error, dataResponse in
                    if let error {
                        self.handleErrorResponse(error, completion: completion)
                    } else if let dataResponse {
                        self.handleDataResponse(dataResponse, completion: completion)
                    } else {
                        completion(.failure(NetworkRequestError.allConnectionAttemptsFailed()))
                    }
                }
            }
        }
    }
    
    private func makeConfiguration(dipTokens: [String]) -> GetDedicatedIPsRequestConfiguration {
        var configuration = GetDedicatedIPsRequestConfiguration()
        
        let bodyDataDict = ["tokens": dipTokens]
        
        if let bodyData = try? JSONEncoder().encode(bodyDataDict) {
            configuration.body = bodyData
        }
        
        return configuration
    }
    
    private func handleErrorResponse(_ error: NetworkRequestError, completion: @escaping GetDedicatedIPsUseCaseType.Completion) {
        switch error {
            case .allConnectionAttemptsFailed(let statusCode):
                completion(.failure(statusCode == 401 ? NetworkRequestError.unauthorized : error))
                return
            case .connectionError(statusCode: let statusCode, message: _):
                completion(.failure(statusCode == 401 ? NetworkRequestError.unauthorized : error))
                return
            default:
                completion(.failure(error))
        }
    }
    
    private func handleDataResponse(_ dataResponse: NetworkRequestResponseType, completion: @escaping GetDedicatedIPsUseCaseType.Completion) {
        guard let dataResponseContent = dataResponse.data else {
            completion(.failure(NetworkRequestError.noDataContent))
            return
        }
        
        guard let dto = DedicatedIPInformation.makeWith(data: dataResponseContent) else {
            completion(.failure(NetworkRequestError.unableToDecodeDataContent))
            return
        }
        
        completion(.success(dto))
    }
}
