//
//  PIACSILastKnownExceptionProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 13.05.22.
//

import Foundation
import csi

@available(tvOS 17.0, *)
class PIACSILastKnownExceptionProvider: ICSIProvider {
    
    var filename: String? { return "last_known_exception" }
    
    var isPersistedData: Bool { return true }
    
    var providerType: ProviderType { return ProviderType.lastKnownException }
    
    var reportType: ReportType { return ReportType.crash }
    
    var value: String? { return Client.preferences.lastKnownException }
}
