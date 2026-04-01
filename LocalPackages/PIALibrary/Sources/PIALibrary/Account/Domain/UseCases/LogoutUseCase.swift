
import Foundation

public protocol LogoutUseCaseType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func callAsFunction(completion: @escaping Completion)
}

class LogoutUseCase: LogoutUseCaseType {
    
    private let networkClient: NetworkRequestClientType
    private let apiTokenProvider: APITokenProviderType
    private let vpnTokenProvider: VpnTokenProviderType
    private let refreshAuthTokensChecker: RefreshAuthTokensCheckerType
    
    init(networkClient: NetworkRequestClientType, apiTokenProvider: APITokenProviderType, vpnTokenProvider: VpnTokenProviderType, refreshAuthTokensChecker: RefreshAuthTokensCheckerType) {
        self.networkClient = networkClient
        self.apiTokenProvider = apiTokenProvider
        self.vpnTokenProvider = vpnTokenProvider
        self.refreshAuthTokensChecker = refreshAuthTokensChecker
    }
    
    func callAsFunction(completion: @escaping Completion) {
        let requestConfiguration = LogoutRequestConfiguration()
        
        refreshAuthTokensChecker.refreshIfNeeded { [weak self] refreshTokensError in
            guard let self else { return }
           
            self.networkClient.executeRequest(with: requestConfiguration) { error, response in
                self.clearAuthTokens(with: completion)
            }
            
        }
    }
    
}

private extension LogoutUseCase {
    
    func clearAuthTokens(with completion: @escaping Completion) {
        apiTokenProvider.clearAPIToken()
        vpnTokenProvider.clearVpnToken()
        completion(nil)
    }
}
