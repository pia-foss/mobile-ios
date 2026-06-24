//
//  ProtocolSelectionViewModel.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

class ProtocolSelectionViewModel: ObservableObject {
    @Published private(set) var selectedProtocol: TvOSVPNProtocol

    let availableProtocols: [TvOSVPNProtocol]

    private let useCase: ProtocolSelectionUseCaseType

    init(useCase: ProtocolSelectionUseCaseType) {
        self.useCase = useCase
        self.availableProtocols = useCase.availableProtocols
        self.selectedProtocol = useCase.selectedProtocol()
    }

    func select(_ vpnProtocol: TvOSVPNProtocol) {
        useCase.select(vpnProtocol)
        selectedProtocol = vpnProtocol
    }

    func isSelected(_ vpnProtocol: TvOSVPNProtocol) -> Bool {
        vpnProtocol == selectedProtocol
    }
}
