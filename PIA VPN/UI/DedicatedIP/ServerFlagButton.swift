//
//  ServerFlagButton.swift
//  PIA VPN
//
//  Created by Mario on 01/04/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsMobile
import PIALocalizations
import SwiftUI

struct ServerFlagButton: View {
    private let name: String
    private let image: Image
    private let isDip: Bool

    init(name: String, country: String, isDip: Bool) {
        self.name = name
        let image = Image.flag(forCountry: country) ?? Image(uiImage: .remove)
        self.image = image
        self.isDip = isDip
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            .overlay(alignment: .topTrailing) {
                Image(asset: Asset.dipBadge)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .offset(x: 6)
            }
            .accessibilityLabel(L10n.Dedicated.Ip.Country.Flag.accessibility(name))
    }
}
