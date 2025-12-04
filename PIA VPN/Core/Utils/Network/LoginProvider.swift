//
//  LoginProvider.swift
//  PIA VPN
//
//  Created by Said Rehouni on 18/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol LoginProviderType {
    func bindTokens(apiToken: String, loginToken: String, completion: @escaping (Result<Void, ClientError>) -> Void)
}

class LoginProvider: LoginProviderType {
    private let httpClient: HTTPClientType
    private let urlRequestMaker: LoginURLRequestMaker
    
    init(httpClient: HTTPClientType, urlRequestMaker: LoginURLRequestMaker) {
        self.httpClient = httpClient
        self.urlRequestMaker = urlRequestMaker
    }
    
    func bindTokens(apiToken: String, loginToken: String, completion: @escaping (Result<Void, ClientError>) -> Void) {
        let urlRequest = urlRequestMaker.makeBindLoginRURLRequest(apiToken: apiToken, loginQRToken: loginToken)
        
        httpClient.makeRequest(request: urlRequest) { result in
            switch result {
                case .success:
                    completion(.success(()))
                case let .failure(error):
                    completion(.failure(error))
            }
        }
    }
}
