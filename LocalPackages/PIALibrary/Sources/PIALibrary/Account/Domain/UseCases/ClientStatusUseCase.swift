
import Foundation

public protocol ClientStatusUseCaseType {
    typealias Completion = ((Result<ClientStatusInformation?, NetworkRequestError>) -> Void)
    
    func callAsFunction(completion: @escaping Completion)
}


class ClientStatusUseCase: ClientStatusUseCaseType {
    
    private let networkClient: NetworkRequestClientType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    private let clientStatusDecoder: ClientStatusInformationDecoderType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType, clientStatusDecoder: ClientStatusInformationDecoderType) {
        self.networkClient = networkClient
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
        self.clientStatusDecoder = clientStatusDecoder
    }
    
    func callAsFunction(completion: @escaping Completion) {
        
        refreshAuthTokensChecker.refreshIfNeeded { _ in }
        
        // No matter if refreshing the tokens fail or not,
        // we always execute the Client Status request
        // This request could be executed when the user is authenticated
        // as well as when the user is NOT authenticated so it is compatible to
        // be executed in parallel with the `refreshIfNeeded`
        self.executeClientStatusRequest(with: completion)
        
    }
    
}


private extension ClientStatusUseCase {
    func executeClientStatusRequest(with completion: @escaping Completion) {
        
        let configuration = ClientStatusRequestConfiguration()
        networkClient.executeRequest(with: configuration) { error, response in
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let respData = response?.data else {
                completion(.failure(.noDataContent))
                return
            }
            
            guard let clientStatusInfo = self.clientStatusDecoder.decodeClientStatus(from: respData) else {
                completion(.failure(.unableToDecodeData))
                return
            }
            
            completion(.success(clientStatusInfo))
        }
    }
}
