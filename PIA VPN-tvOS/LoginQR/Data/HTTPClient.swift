//
//  HTTPClient.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let allHTTPHeaderFields: [String : String]?
}

protocol HTTPClientType {
    func makeRequest(request: URLRequest) async throws -> Data
}
