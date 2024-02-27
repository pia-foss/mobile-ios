//
//  AcknowledgementsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/27/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class AcknowledgementsViewModel: ObservableObject {
    let licencesUseCase: LicensesUseCaseType
    @Published var licenses: [LicenseComponent] = []
    
    init(licencesUseCase: LicensesUseCaseType) {
        self.licencesUseCase = licencesUseCase
        self.licenses = licencesUseCase.getLicences()
    }
    
    func getLicenseContent(for license: LicenseComponent) async -> String {
        await licencesUseCase.getLicenseContent(for: license)
    }
}
