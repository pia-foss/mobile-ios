//
//  IKEv2IntegrityAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import NetworkExtension

public enum IKEv2IntegrityAlgorithm: String, EnumsBuilder {
    
    public static let defaultIntegrity: IKEv2IntegrityAlgorithm = .SHA256
    #if os(iOS)
    case SHA96 = "SHA96"
    case SHA160 = "SHA160"
    #endif
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
        #if os(iOS)
            case .SHA96: return NEVPNIKEv2IntegrityAlgorithm.SHA96
            case .SHA160: return NEVPNIKEv2IntegrityAlgorithm.SHA160
        #endif
            case .SHA256: return NEVPNIKEv2IntegrityAlgorithm.SHA256
            case .SHA384: return NEVPNIKEv2IntegrityAlgorithm.SHA384
            case .SHA512: return NEVPNIKEv2IntegrityAlgorithm.SHA512
        }
    }
    
}

