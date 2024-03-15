//
//  LoginQRURLRequestMaker.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginQRURLRequestMaker {
    private let hostName: String
    
    init(hostName: String = "https://privateinternetaccess.com/api/") {
        self.hostName = hostName
    }
    
    func makeValidateLoginQRURLRequest(loginQRToken: String) -> URLRequest {
        let headers = [
            "Authorization" : "Bearer " + loginQRToken,
            "application/json" : "accept"
        ]
        
        let endpoint = Endpoint(path: "client/v5/login_token/auth",
                                method: .POST,
                                allHTTPHeaderFields: headers)
        
        return makeURLRequest(endpoint: endpoint)
    }
    
    func makeGenerateLoginQRURLRequest() -> URLRequest {
        let headers = [
            "application/json" : "accept",
            "user-agent" : "PIA VPN"
        ]
        
        let endpoint = Endpoint(path: "client/v5/login_token",
                                method: .POST,
                                allHTTPHeaderFields: headers)
        
        return makeURLRequest(endpoint: endpoint)
    }
    
    private func makeURLRequest(endpoint: Endpoint) -> URLRequest {
        let url = URL(string: hostName + endpoint.path)!
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.allHTTPHeaderFields
        
        return request
    }
}
