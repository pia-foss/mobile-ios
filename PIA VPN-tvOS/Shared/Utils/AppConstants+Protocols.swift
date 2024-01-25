//
//  AppConstants+Protocols.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 1/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol AppConstantsType {
    static var appId: String { get }
    static var teamId: String { get }
    static var appGroup: String { get }
    
}

extension AppConstants: AppConstantsType {}
