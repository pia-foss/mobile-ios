//
//  Endpoint.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/14/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol Endpoint: ConfigurationAccess {
    var url: URL { get }
}

enum ClientEndpoint: String, Endpoint {
    case signup
    
    case account
    
    case payment
    
    case status
    
    var url: URL {
        return URL(string: "\(accessedConfiguration.baseUrl)/api/client/\(rawValue)")!
    }
}

enum VPNEndpoint: String, Endpoint {
    case servers
    
    case debugLog = "debug_log"
    
    var url: URL {
        return URL(string: "\(accessedConfiguration.baseUrl)/vpninfo/\(rawValue)")!
    }
}
