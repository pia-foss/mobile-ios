//
//  HTTPClientMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Said Rehouni on 15/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
@testable import PIA_VPN_tvOS

class HTTPClientMock: HTTPClientType {
    private let result: Result<Data, ClientError>
    
    init(result: Result<Data, ClientError>) {
        self.result = result
    }
    
    func makeRequest(request: URLRequest) async throws -> Data {
        switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
        }
    }
}
