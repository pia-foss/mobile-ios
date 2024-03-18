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
            Endpoint.Header.authorization.rawValue : "Bearer " + loginQRToken,
            Endpoint.Header.application_json.rawValue : "accept"
        ]
        
        let endpoint = Endpoint(path: Endpoint.Path.Authentication.validateLogin.rawValue,
                                method: .POST,
                                allHTTPHeaderFields: headers)
        
        return makeURLRequest(endpoint: endpoint)
    }
    
    func makeGenerateLoginQRURLRequest() -> URLRequest {
        let headers = [
            Endpoint.Header.application_json.rawValue : "accept",
            Endpoint.Header.user_agent.rawValue : "PIA VPN"
        ]
        
        let endpoint = Endpoint(path: Endpoint.Path.Authentication.generateLoginQR.rawValue,
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
