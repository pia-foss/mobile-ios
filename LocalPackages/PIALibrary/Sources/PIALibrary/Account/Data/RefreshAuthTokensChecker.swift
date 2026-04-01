
import Foundation

private let log = PIALogger.logger(for: RefreshAuthTokensChecker.self)

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
            log.debug("Already refreshing, skipping.")
            completion(nil)
            return
        }
        
        switch (shouldRefreshApiToken(), shouldRefreshVpnToken()) {
        case (true, true):
            log.debug("Refreshing both API and VPN tokens.")
            refreshBothTokens(with: completion)
        case (true, false):
            log.debug("Refreshing API token only.")
            refreshApiToken(with: completion)
        case(false, true):
            log.debug("Refreshing VPN token only.")
            refreshVpnToken(with: completion)
        case(false, false):
            log.debug("No tokens need refresh.")
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
                log.debug("API token refresh failed with error: \(refreshApiTokenError)")
                self.isRefreshing = false
                completion(refreshApiTokenError)
            } else {
                log.debug("API token refresh completed successfully, starting VPN token refresh.")
                self.refreshVpnTokenUseCase() { refreshVpnTokenError in
                    self.isRefreshing = false
                    if let refreshVpnTokenError {
                        log.debug("VPN token refresh failed with error: \(refreshVpnTokenError)")
                    } else {
                        log.debug("Both tokens refresh completed successfully.")
                    }
                    completion(refreshApiTokenError)
                }
            }
        }
    }
    
    func refreshApiToken(with completion: @escaping Completion) {
        isRefreshing = true
        refreshAPITokenUseCase() { error in
            self.isRefreshing = false
            if let error {
                log.debug("API token refresh failed with error: \(error)")
            } else {
                log.debug("API token refresh completed successfully.")
            }
            completion(error)
        }
    }
    
    func refreshVpnToken(with completion: @escaping Completion) {
        isRefreshing = true
        refreshVpnTokenUseCase() { error in
            self.isRefreshing = false
            if let error {
                log.debug("VPN token refresh failed with error: \(error)")
            } else {
                log.debug("VPN token refresh completed successfully.")
            }
            completion(error)
        }
    }
    
}

// MARK: - Refresh time intervals utils

private extension RefreshAuthTokensChecker {
    
    func shouldRefreshApiToken() -> Bool {
        guard let apiToken = apiTokenProvider.getAPIToken() else {
            log.debug("API token is missing, refresh needed.")
            return true
        }

        let needsRefresh = shouldRefresh(with: apiToken.expiresAt)
        if needsRefresh {
            log.debug("API token expires at \(apiToken.expiresAt), refresh needed.")
        }
        return needsRefresh
    }
    
    func shouldRefreshVpnToken() -> Bool {
        guard let vpnToken = vpnTokenProvier.getVpnToken() else {
            log.debug("VPN token is missing, refresh needed.")
            return true
        }

        let needsRefresh = shouldRefresh(with: vpnToken.expiresAt)
        if needsRefresh {
            log.debug("VPN token expires at \(vpnToken.expiresAt), refresh needed.")
        }
        return needsRefresh
    }
    
    
    func shouldRefresh(with expiration: Date) -> Bool {
        let daysUntilExpires = expiration.timeIntervalSinceNow.inDays()
        
        return daysUntilExpires < daysUntilRefresh
    }
    
}
