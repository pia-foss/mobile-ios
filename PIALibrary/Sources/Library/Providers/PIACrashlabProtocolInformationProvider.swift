//
//  PIACSIProtocolInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACSI

class PIACSIProtocolInformationProvider : ProtocolInformationProvider {

    private var protocolLogs: String?

    func setProtocolLogs(protocolLogs: String) {
        self.protocolLogs = protocolLogs
    }

    func protocolInformation() -> String {
        protocolLogs = protocolLogs == nil ? protocolLogs : "Unknown"
        return protocolLogs!.redactIPs()
    }
}
