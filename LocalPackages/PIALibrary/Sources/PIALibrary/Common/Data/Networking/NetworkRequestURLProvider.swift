
import Foundation

protocol NetworkRequestURLProviderType {
    func getURL(for endpoint: PinningEndpoint, path: RequestAPI.Path, query: [String: String]?) -> URL?
}

class NetworkRequestURLProvider: NetworkRequestURLProviderType {
   
    private let stagingSubdomain = "staging"
    private let domainRegex = "^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}$"
    private let ipv4Regex = "^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.(?!$)|$)){4}$"
    
    func getURL(for endpoint: PinningEndpoint, path: RequestAPI.Path, query: [String: String]?) -> URL? {
        
        let scheme = "https"
        
        let isStagingEndpoint = endpoint.host.contains(stagingSubdomain)
        let isIPEndpoint = endpoint.host.matches(ipv4Regex)
        
        var urlString = ""
        
        // We don't add subdomain to the IP endpoints and staging endpoints
        if isStagingEndpoint || isIPEndpoint {
            urlString = "\(scheme)://\(endpoint.host)\(path.rawValue)"
        } else {
            let subdomain = RequestAPI.subdomain(for: path)
            urlString = "\(scheme)://\(subdomain).\(endpoint.host)\(path.rawValue)"
        }

        if let query {
            var urlComponents = URLComponents(string: urlString)
            var queryItems = [URLQueryItem]()
            
            for (queryKey, queryValue) in query {
                let queryItem = URLQueryItem(name: queryKey, value: queryValue)
                queryItems.append(queryItem)
            }
            
            urlComponents?.queryItems = queryItems
            return urlComponents?.url
        }
        
        return URL(string: urlString)
    }
}
