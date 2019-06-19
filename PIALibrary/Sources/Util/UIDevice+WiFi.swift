//
//  UIDevice+WiFi.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 25/02/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

public extension UIDevice {
    
    public var WiFiSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    
}
