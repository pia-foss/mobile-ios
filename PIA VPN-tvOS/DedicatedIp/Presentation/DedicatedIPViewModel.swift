//
//  DedicatedIPViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 16/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

struct DedicatedIpData {
    let id = UUID()
    let title: String
    let description: String
}

class DedicatedIPViewModel: ObservableObject {
    @Published var dedicatedIPStats: [DedicatedIpData] = []
    @Published var shouldShowErrorMessage: Bool = false
    
    private let getDedicatedIp: GetDedicatedIpUseCaseType
    private let activateDIPToken: ActivateDIPTokenUseCaseType
    private let removeDIPToken: RemoveDIPUseCaseType
    
    init(getDedicatedIp: GetDedicatedIpUseCaseType, activateDIPToken: ActivateDIPTokenUseCaseType, removeDIPToken: RemoveDIPUseCaseType) {
        self.getDedicatedIp = getDedicatedIp
        self.activateDIPToken = activateDIPToken
        self.removeDIPToken = removeDIPToken
    }
    
    func onAppear() {
        guard let server = getDedicatedIp(),
              let dipIKEv2IP = server.dipIKEv2IP,
              let dipStatusString = server.dipStatusString else {
            dedicatedIPStats = []
            return
        }
        Task { @MainActor in
            dedicatedIPStats = [
                DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.dedicatedip, description: dipStatusString),
                DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.ip, description: dipIKEv2IP),
                DedicatedIpData(title: L10n.Localizable.Settings.Dedicatedip.Stats.location, description: server.name + " (\(server.country))")
            ]
        }
    }
    
    func activateDIP(token: String) async {
        guard !token.isEmpty else {
            Task { @MainActor in
                shouldShowErrorMessage = true
            }
            return
        }
        
        do {
            try await activateDIPToken(token: token)
            onAppear()
        } catch {
            Task { @MainActor in
                shouldShowErrorMessage = true
            }
        }
    }
    
    func removeDIP() {
        removeDIPToken()
        dedicatedIPStats = []
    }
}
