//
//  Client+Environment.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/24/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

extension Client {

    /// The available client environments.
    public enum Environment: String {
        
        /// Use staging endpoints.
        case staging
        
        /// Use production endpoints.
        case production
    }
}
