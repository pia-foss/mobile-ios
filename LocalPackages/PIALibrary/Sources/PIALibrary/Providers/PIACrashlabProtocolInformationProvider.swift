//
//  PIACSIProtocolInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import csi

class PIACSIProtocolInformationProvider : ICSIProvider {
    
    var filename: String? { return "protocol_information" }
    
    var isPersistedData: Bool { return false }
    
    var providerType: ProviderType { return ProviderType.protocolInformation }
    
    var reportType: ReportType { return ReportType.diagnostic }
    
    var value: String? { return protocolInformation() }
    

    private var protocolLogs: String?

    func setProtocolLogs(protocolLogs: String) {
        self.protocolLogs = protocolLogs
    }

    func protocolInformation() -> String {
        protocolLogs = protocolLogs != nil ? protocolLogs : "Unknown"
        return protocolLogs!.redactIPs()
    }
}
