

import Foundation
import NWHttpConnection

protocol NetworkConnectionRequestProviderType {
    func makeNetworkRequestConnection(for endpoint: PinningEndpoint, with configuration: NetworkRequestConfigurationType) -> NWHttpConnectionType?
    
}


class NetworkConnectionRequestProvider: NetworkConnectionRequestProviderType {
    let apiTokenProvider: APITokenProviderType
    let networkRequestURLProvider: NetworkRequestURLProviderType
    
    init(apiTokenProvider: APITokenProviderType, networkRequestURLProvider: NetworkRequestURLProviderType) {
        self.apiTokenProvider = apiTokenProvider
        self.networkRequestURLProvider = networkRequestURLProvider
    }
    
    
    func makeNetworkRequestConnection(for endpoint: PinningEndpoint, with configuration: NetworkRequestConfigurationType) -> NWHttpConnectionType? {
        
        guard let requestURL = networkRequestURLProvider.getURL(for: endpoint, path: configuration.path, query: configuration.urlQueryParameters) else {
            return nil
        }
        
        guard let anchorCertificate = AnchorCertificateProvider.getAnchorCertificate() else {
            return nil
        }
        
        var headers: [String: String] = [
            "Content-Type": configuration.contentType.rawValue,
            "User-Agent": PIAWebServices.userAgent
        ]
        
        if configuration.inlcudeAuthHeaders {
            guard let apiToken = apiTokenProvider.getAPIToken() else {
                return nil
            }
            headers["Authorization"] = "Token \(apiToken.apiToken)"
        }
        
        if let otherHeaders = configuration.otherHeaders {
            headers.merge(otherHeaders) { $1 }
        }
        
        let connectionConfiguration = NWConnectionConfiguration(url: requestURL, method: configuration.httpMethod, headers: headers, body: configuration.body, certificateValidation: makeCertificateValidation(for: endpoint, anchorCertificate: anchorCertificate), dataResponseType: configuration.responseDataType, timeout: configuration.timeout, queue: configuration.requestQueue)
        
        return NWHttpConnectionFactory.makeNWHttpConnection(with: connectionConfiguration)
        
    }
    
    
}


// MARK: - Private

private extension NetworkConnectionRequestProvider {
    
    func makeCertificateValidation(for endpoint: PinningEndpoint, anchorCertificate: SecCertificate) -> CertificateValidation {
        if endpoint.useCertificatePinning {
            return CertificateValidation.anchor(certificate: anchorCertificate, commonName: endpoint.commonName)
        } else {
            return CertificateValidation.trustedCA
        }
    }
    
}
