
import Foundation

protocol RefreshAuthTokensCheckerType {
    typealias Completion = ((NetworkRequestError?) -> Void)
    func refreshIfNeeded(completion: @escaping Completion)
}

class RefreshAuthTokensChecker: RefreshAuthTokensCheckerType {
    
    let apiTokenProvider: APITokenProviderType
    let vpnTokenProvier: VpnTokenProviderType
    let refreshAPITokenUseCase: RefreshAPITokenUseCaseType
    let refreshVpnTokenUseCase: RefreshVpnTokenUseCaseType
    internal var isRefreshing: Bool = false
    
    // Number of days remaining before refreshing a token
    private let daysUntilRefresh: Double = 30
    
    init(apiTokenProvider: APITokenProviderType, vpnTokenProvier: VpnTokenProviderType, refreshAPITokenUseCase: RefreshAPITokenUseCaseType, refreshVpnTokenUseCase: RefreshVpnTokenUseCaseType) {
        self.apiTokenProvider = apiTokenProvider
        self.vpnTokenProvier = vpnTokenProvier
        self.refreshAPITokenUseCase = refreshAPITokenUseCase
        self.refreshVpnTokenUseCase = refreshVpnTokenUseCase
    }
    
    func refreshIfNeeded(completion: @escaping Completion) {
        
        guard !isRefreshing else {
            completion(nil)
            return
        }
        
        switch (shouldRefreshApiToken(), shouldRefreshVpnToken()) {
        case (true, true):
            refreshBothTokens(with: completion)
        case (true, false):
            refreshApiToken(with: completion)
        case(false, true):
            refreshVpnToken(with: completion)
        case(false, false):
            completion(nil)
        }
    }
    
}

// MARK: - Refresh tokens helpers

private extension RefreshAuthTokensChecker {
    
    func refreshBothTokens(with completion: @escaping Completion) {
        isRefreshing = true
        refreshAPITokenUseCase() { refreshApiTokenError in
            if let refreshApiTokenError {
                self.isRefreshing = false
                completion(refreshApiTokenError)
            } else {
                self.refreshVpnTokenUseCase() { refreshVpnTokenError in
                    self.isRefreshing = false
                    completion(refreshApiTokenError)
                }
            }
        }
    }
    
    func refreshApiToken(with completion: @escaping Completion) {
        isRefreshing = true
        refreshAPITokenUseCase() { error in
            self.isRefreshing = false
            completion(error)
        }
    }
    
    func refreshVpnToken(with completion: @escaping Completion) {
        isRefreshing = true
        refreshVpnTokenUseCase() { error in
            self.isRefreshing = false
            completion(error)
        }
    }
    
}

// MARK: - Refresh time intervals utils

private extension RefreshAuthTokensChecker {
    
    func shouldRefreshApiToken() -> Bool {
        guard let apiToken = apiTokenProvider.getAPIToken() else {
             return true
        }

        return shouldRefresh(with: apiToken.expiresAt)
    }
    
    func shouldRefreshVpnToken() -> Bool {
        guard let vpnToken = vpnTokenProvier.getVpnToken() else {
             return true
        }
        
        return shouldRefresh(with: vpnToken.expiresAt)
    }
    
    
    func shouldRefresh(with expiration: Date) -> Bool {
        let daysUntilExpires = expiration.timeIntervalSinceNow.inDays()
        
        return daysUntilExpires < daysUntilRefresh
    }
    
}
