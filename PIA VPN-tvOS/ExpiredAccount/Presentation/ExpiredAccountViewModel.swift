//
//  ExpiredAccountViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class ExpiredAccountViewModel {
    let title1: String
    let title2: String?
    let subtitle: String
    let qrTitle: [String]
    let qrCodeURL: URL?
    
    @Published var isLoading: Bool = false
    private let logOutUseCase: LogOutUseCaseType
    
    init(title1: String, title2: String?, subtitle: String, qrTitle: [String], qrCodeURL: URL?, logOutUseCase: LogOutUseCaseType) {
        self.title1 = title1
        self.title2 = title2
        self.subtitle = subtitle
        self.qrTitle = qrTitle
        self.qrCodeURL = qrCodeURL
        self.logOutUseCase = logOutUseCase
    }
    
    func logout() {
        Task {
            do {
                setLoading(to: true)
                try await logOutUseCase.logOut()
                setLoading(to: false)
            } catch {
                setLoading(to: false)
            }
        }
    }
    
    private func setLoading(to loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = loading
        }
    }
}
