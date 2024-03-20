//
//  URLRequestMaker.swift
//  PIA VPN
//
//  Created by Said Rehouni on 18/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol URLRequestMaker {
    var hostName: String { get }
    func makeURLRequest(endpoint: Endpoint) -> URLRequest
}

extension URLRequestMaker {
    func makeURLRequest(endpoint: Endpoint) -> URLRequest {
        let url = URL(string: hostName + endpoint.path)!
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.allHTTPHeaderFields
        if let bodyParametrs = endpoint.bodyParametrs {
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParametrs)
        }
        
        return request
    }
}
