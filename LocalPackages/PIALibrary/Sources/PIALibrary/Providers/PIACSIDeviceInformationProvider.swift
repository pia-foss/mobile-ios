//
//  PIACSIDeviceInformationProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 06.05.22.
//

import Foundation
import csi
import UIKit

class PIACSIDeviceInformationProvider: ICSIProvider {
    
    var filename: String? { return "device_information" }
    
    var isPersistedData: Bool { return false }
    
    var providerType: ProviderType { return ProviderType.deviceInformation }
    
    var reportType: ReportType { return ReportType.diagnostic }
    
    var value: String? { return getDeviceInformation() }
    
    
    func getDeviceInformation() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return "OS Version: \(versionString)\nDeviceType: \(UIDevice.current.type.rawValue)"
    }
}
