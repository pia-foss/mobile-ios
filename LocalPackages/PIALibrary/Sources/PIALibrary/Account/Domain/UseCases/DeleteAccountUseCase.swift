
import Foundation


protocol DeleteAccountUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func callAsFunction(completion: @escaping Completion)
}


class DeleteAccountUseCase: DeleteAccountUseCaseType {
    
    let networkClient: NetworkRequestClientType
    let refreshAuthTokenChecker: RefreshAuthTokensCheckerType
    let apiTokenProvider: APITokenProviderType
    let vpnTokenProvider: VpnTokenProviderType
    
    init(networkClient: NetworkRequestClientType, refreshAuthTokenChecker: RefreshAuthTokensCheckerType, apiTokenProvider: APITokenProviderType, vpnTokenProvider: VpnTokenProviderType) {
        self.networkClient = networkClient
        self.refreshAuthTokenChecker = refreshAuthTokenChecker
        self.apiTokenProvider = apiTokenProvider
        self.vpnTokenProvider = vpnTokenProvider
    }
    
    
    func callAsFunction(completion: @escaping Completion) {
        refreshAuthTokenChecker.refreshIfNeeded { [weak self] error in
            guard let self else { return }
            if let error {
                completion(error)
            } else {
                self.executeRequest(with: completion)
            }
        }
    }
}


extension DeleteAccountUseCase {
    func executeRequest(with completion: @escaping Completion) {
        let configuration = DeleteAccountRequestConfiguration()
        networkClient.executeRequest(with: configuration) { [weak self] error, response in
            
            guard let self else { return }
          
            if let error {
                completion(error)
            } else {
                self.apiTokenProvider.clearAPIToken()
                self.vpnTokenProvider.clearVpnToken()
                completion(nil)
            }
            
            
        }
    }
}
