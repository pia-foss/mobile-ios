//
//  PromoOffersHostingController.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  Proof-of-concept only: hosts `PromoOffersPoCView` so it can be presented from UIKit.
//  Present it from anywhere while testing, e.g.:
//
//      let host = PromoOffersHostingController()
//      present(host, animated: true)
//

import SwiftUI
import UIKit

final class PromoOffersHostingController: UIHostingController<PromoOffersPoCView> {
    init() {
        super.init(rootView: PromoOffersPoCView())
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
