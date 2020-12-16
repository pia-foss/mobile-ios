//
//  PIACSIRegionInformationProvider.swift
//  PIALibrary
//
//  Created by Juan Docal on 9/12/20.
//  Copyright © 2020 London Trust Media. All rights reserved.
//

import Foundation
import PIACSI

class PIACSIRegionInformationProvider : RegionInformationProvider {

    func regionInformation() -> String {
        return Client.providers.serverProvider.targetServer.toJSON()?.description ?? "Unknown region information"
    }
}
