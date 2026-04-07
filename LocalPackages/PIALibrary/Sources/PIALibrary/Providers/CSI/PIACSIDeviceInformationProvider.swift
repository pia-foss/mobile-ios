//
//  PIACSIDeviceInformationProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 06.05.22.
//

import Foundation
import PIACSI

struct PIACSIDeviceInformationProvider: CSIDataProvider {
    var sectionName: String { "device_information" }
    var content: String? { getDeviceInformation() }

    private func getDeviceInformation() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return "OS Version: \(versionString)\nDeviceType: \(modelCode())"
    }

    private func modelCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
    }
}
