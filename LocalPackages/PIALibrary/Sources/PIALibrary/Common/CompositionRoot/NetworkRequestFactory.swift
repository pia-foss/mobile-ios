
import Foundation

public class NetworkRequestFactory {
    static func maketNetworkRequestClient() -> NetworkRequestClientType {
        networkRequestClientShared
    }
}

// MARK: - Private

private extension NetworkRequestFactory {
    static var networkRequestClientShared: NetworkRequestClientType = {
        NetworkRequestClient(networkConnectionRequestProvider: makeNetworkConnectionRequestProvider(), endpointManager: makeEndpointManager())
    }()
    
    static func makeEndpointManager() -> EndpointManagerType {
        EndpointManager.shared
    }
    
    static func makeNetworkRequestURLProvider() -> NetworkRequestURLProviderType {
        NetworkRequestURLProvider()
    }
    
    static func makeNetworkConnectionRequestProvider() -> NetworkConnectionRequestProviderType {
        NetworkConnectionRequestProvider(apiTokenProvider: AccountFactory.makeAPITokenProvider(), networkRequestURLProvider: makeNetworkRequestURLProvider())
        
    }
    
}
