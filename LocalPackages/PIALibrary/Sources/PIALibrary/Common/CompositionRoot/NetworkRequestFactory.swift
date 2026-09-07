import Foundation

public enum NetworkRequestFactory: Sendable {
    static func maketNetworkRequestClient() -> NetworkRequestClientType {
        networkRequestClientShared
    }
}

// MARK: - Private

private extension NetworkRequestFactory {
    static let networkRequestClientShared: NetworkRequestClientType = {
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
