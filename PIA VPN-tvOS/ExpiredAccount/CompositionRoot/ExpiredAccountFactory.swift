//
//  ExpiredAccountFactory.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 20/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class ExpiredAccountFactory {
    static func makeExpiredAccountView() -> ExpiredAccountView {
        ExpiredAccountView(viewModel: makeExpiredAccountViewModel())
    }
    
    static private func makeExpiredAccountViewModel() -> ExpiredAccountViewModel {
        let qrTitle = [
            L10n.Localizable.Tvos.Signin.Expired.Qr.title1,
            L10n.Localizable.Tvos.Signin.Expired.Qr.title2
        ]
        
        let buttonsTitle = [
            L10n.Localizable.Tvos.Signin.Expired.Button.renewed,
            L10n.Localizable.Tvos.Signin.Expired.Button.signout
        ]

        
        let separation = L10n.Localizable.Settings.Dedicatedip.Status.expired.lowercased()
        let titleSeparated = L10n.Localizable.Tvos.Signin.Expired.title.replacingOccurrences(of: separation, with: "")
        
        return ExpiredAccountViewModel(title1: titleSeparated,
                                       title2: separation,
                                       subtitle: L10n.Localizable.Tvos.Signin.Expired.subtitle,
                                       qrTitle: qrTitle,
                                       qrCodeURL: URL(string: "https://apps.apple.com/us/app/vpn-by-private-internet-access/id955626407"),
                                       logOutUseCase: SettingsFactory.makeLogOutUseCase())
    }
}
