//
//  IKEv2IntegrityAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension

public enum IKEv2IntegrityAlgorithm: Int, EnumsBuilder {
    
    public static let defaultAlgorithm: Int = 1
    
    case SHA96 = 1
    case SHA160
    case SHA256
    case SHA384
    case SHA512

    public func description() -> String {
        switch self {
        case .SHA96: return "SHA96"
        case .SHA160: return "SHA160"
        case .SHA256: return "SHA256"
        case .SHA384: return "SHA384"
        case .SHA512: return "SHA512"
        }
    }
    
    public func networkExtensionValue() -> NEVPNIKEv2IntegrityAlgorithm {
        return NEVPNIKEv2IntegrityAlgorithm(rawValue: self.rawValue) ?? .SHA96
    }
    
}

