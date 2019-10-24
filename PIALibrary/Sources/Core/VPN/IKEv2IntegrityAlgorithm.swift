//
//  IKEv2IntegrityAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension

public enum IKEv2IntegrityAlgorithm: String, EnumsBuilder {
    
    public static let defaultIntegrity: IKEv2IntegrityAlgorithm = .SHA256

    case SHA96 = "SHA96"
    case SHA160 = "SHA160"
    case SHA256 = "SHA256"
    case SHA384 = "SHA384"
    case SHA512 = "SHA512"

    public func value() -> String {
        return self.rawValue
    }
    
    public func description() -> String {
        return self.rawValue
    }
    
    public func networkExtensionValue() -> NEVPNIKEv2IntegrityAlgorithm {
        switch self {
            case .SHA96: return NEVPNIKEv2IntegrityAlgorithm.SHA96
            case .SHA160: return NEVPNIKEv2IntegrityAlgorithm.SHA160
            case .SHA256: return NEVPNIKEv2IntegrityAlgorithm.SHA256
            case .SHA384: return NEVPNIKEv2IntegrityAlgorithm.SHA384
            case .SHA512: return NEVPNIKEv2IntegrityAlgorithm.SHA512
            default: return NEVPNIKEv2IntegrityAlgorithm.SHA96
        }
    }
    
}

