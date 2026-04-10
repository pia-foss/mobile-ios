//
//  PIACSIProtocolInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACSI

struct PIACSIProtocolInformationProvider: CSIDataProvider {
    var sectionName: String { "protocol_information" }
    var content: String? { protocolInformation() }

    private func protocolInformation() -> String {
        return "Unknown"
    }
}
