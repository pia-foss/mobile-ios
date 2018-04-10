//
//  PIAWebServices+Ephemeral.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Gloss

extension PIAWebServices {
    func flagURL(for country: String) -> URL {
        return URL(string: "\(accessedConfiguration.baseUrl)/images/flags/\(country)_3x.png")!
    }
    
    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) -> URLSessionDataTask {
        
        // every status check should use a new HTTP connection (no Keep-Alive), so we
        // skip using AFNetworking here and just use NSURLSession directly
        let config: URLSessionConfiguration = .ephemeral
        config.timeoutIntervalForRequest = Double(accessedConfiguration.connectivityTimeout) / 1000.0
        config.timeoutIntervalForResource = Double(accessedConfiguration.connectivityTimeout) / 1000.0
        let session = URLSession(configuration: config)
        
        let url = ClientEndpoint.status.url
        
        return session.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    callback?(nil, error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    callback?(nil, ClientError.malformedResponseData)
                    return
                }

                let statusCode = httpResponse.statusCode
                guard (statusCode == 200) else {
                    callback?(nil, ClientError.unexpectedReply)
                    return
                }

                let jsonObject: Any
                do {
                    jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                } catch let e {
                    callback?(nil, e)
                    return
                }

                guard let json = jsonObject as? JSON, let connectivity = GlossConnectivityStatus(json: json) else {
                    callback?(nil, ClientError.malformedResponseData)
                    return
                }
                callback?(connectivity.parsed, nil)
            }
        })
    }
    
    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?) {
        let data = log.serialized()
        guard let bigdata = String(data: data, encoding: .isoLatin1)?.urlEncoded() else {
            callback?(nil)
            return
        }

        let body = "bigdata=\(bigdata)"
        let url = VPNEndpoint.debugLog.url

        let config: URLSessionConfiguration = .ephemeral
        config.timeoutIntervalForRequest = Double(accessedConfiguration.webTimeout) / 1000.0
        config.timeoutIntervalForResource = Double(accessedConfiguration.webTimeout) / 1000.0
        let session = URLSession(configuration: config)

        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: Double(accessedConfiguration.webTimeout) / 1000.0
        )
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .isoLatin1)

        session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    callback?(ClientError.malformedResponseData)
                    return
                }
                guard (httpResponse.statusCode == 200) else {
                    callback?(ClientError.unexpectedReply)
                    return
                }
                callback?(nil)
            }
        }.resume()
    }
}

//private extension String {
//    private static let urlEncodedSet = CharacterSet(charactersIn: "!'();:@&=+$,/?%#[]")
//
//    func urlEncoded() -> String? {
//        return addingPercentEncoding(withAllowedCharacters: String.urlEncodedSet)
//    }
//}
