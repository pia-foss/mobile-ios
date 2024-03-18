//
//  LicensesUseCase.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/27/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

protocol LicensesUseCaseType {
    func getLicences() -> [LicenseComponent]
    func getLicenseContent(for license: LicenseComponent) async -> String
    func callAsFunction()
}

class LicensesUseCase: LicensesUseCaseType {
    @MainActor internal var cachedLicenseContent: [String: String] = [:]
    
    private let licencesPath = Bundle.main.path(forResource: "Licences", ofType: "plist")
    
    let urlSession: URLSessionType
    
    init(urlSession: URLSessionType) {
        self.urlSession = urlSession
    }
    
    func getLicences() -> [LicenseComponent] {
        guard let licenceFile = licencesPath else {
            return []
        }
        let components = Components(licenceFile)
        return components.licenses
    }
    
    func getLicenseContent(for license: LicenseComponent) async -> String {
        if let cachedContent = await cachedLicenseContent[license.name] {
            return cachedContent
        }
        
        do {
            let (data, response) = try await urlSession.data(from: license.licenseURL)
            if let licenseContent = String(data: data, encoding: .ascii) {
                DispatchQueue.main.async {
                    self.cachedLicenseContent[license.name] = licenseContent
                }
                return licenseContent
            } else {
                return ""
            }
            
        } catch {
            return ""
        }
       
    }
    
    
    func callAsFunction() {
        for license in getLicences() {
            Task {
                let content = await getLicenseContent(for: license)
            }
            
        }
    }
}
