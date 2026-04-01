//
//  URLSessionHTTPClient.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 10/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class URLSessionHTTPClient: HTTPClientType {
    private let session: URLSessionType
    
    init(session: URLSessionType = URLSession.shared) {
        self.session = session
    }
    
    func makeRequest(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else { throw ClientError.malformedResponseData }
            guard response.statusCode == 200 else { throw ClientError.invalidParameter }
            
            return data
        } catch {
            throw error
        }
    }
    
    func makeRequest(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), ClientError>) -> Void ) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(ClientError.unsupported))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(ClientError.malformedResponseData))
                return
            }
            
            guard response.statusCode == 200 else {
                completion(.failure(ClientError.invalidParameter))
                return
            }
            
            completion(.success((data, response)))
            
        }.resume()
    }
}
