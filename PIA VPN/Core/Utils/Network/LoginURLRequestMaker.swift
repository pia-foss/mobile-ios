//
//  LoginURLRequestMaker.swift
//  PIA VPN
//
//  Created by Said Rehouni on 18/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class LoginURLRequestMaker: URLRequestMaker {
    let hostName: String
    
    init(hostName: String = "https://privateinternetaccess.com/api/") {
        self.hostName = hostName
    }
    
    func makeBindLoginRURLRequest(apiToken: String, loginQRToken: String) -> URLRequest {
        let headers = [
            Endpoint.Header.authorization.rawValue : "Bearer " + apiToken,
            Endpoint.Header.accept.rawValue : Endpoint.Header.application_json.rawValue,
            Endpoint.Header.content_type.rawValue : Endpoint.Header.application_json.rawValue
        ]
        
        let endpoint = Endpoint(path: Endpoint.Path.Authentication.bindLoginToken.rawValue,
                                method: .POST,
                                allHTTPHeaderFields: headers, 
                                bodyParametrs: ["login_token" : loginQRToken])
        
        return makeURLRequest(endpoint: endpoint)
    }
}
