//
//  HTTPClient.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

enum HTTPMethod: String {
    case GET
    case POST
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let allHTTPHeaderFields: [String : String]?
    let bodyParametrs: [String : Any]?
    
    struct Path {
        enum Authentication: String {
            case validateLogin = "client/v5/login_token/auth"
            case generateLoginQR = "client/v5/login_token"
            case bindLoginToken = "client/v5/login_token/bind"
        }
    }
    
    enum Header: String {
        case application_json = "application/json"
        case authorization = "Authorization"
        case user_agent = "user-agent"
        case accept = "accept"
        case content_type = "Content-Type"
    }
}

protocol HTTPClientType {
    @available(iOS 13.0.0, *)
    func makeRequest(request: URLRequest) async throws -> Data
    func makeRequest(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), ClientError>) -> Void)
}
