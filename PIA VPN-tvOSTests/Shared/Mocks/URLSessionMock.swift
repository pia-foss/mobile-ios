//
//  URLSessionMock.swift
//  PIA VPN-tvOSTests
//
//  Created by Laura S on 2/28/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
@testable import PIA_VPN_tvOS

class URLSessionMock: URLSessionType {
    var dataTaskCalled = false
    var dataTaskCalledAttempt = 0
    var dataTaskResultData = Data()
    var dataTaskResultResponse = URLResponse()
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        dataTaskCalled = true
        dataTaskCalledAttempt += 1
        return (dataTaskResultData, dataTaskResultResponse)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return (dataTaskResultData, dataTaskResultResponse)
    }
}
