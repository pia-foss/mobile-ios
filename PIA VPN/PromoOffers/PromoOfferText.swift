//
//  PromoOfferText.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import Foundation

/// Shared by the offer's two surfaces so a date reads the same in the banner, the sheet and the
/// billing disclaimer.
enum PromoOfferText {
    static func date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// The copy bolds a few runs. Markdown keeps that emphasis inside the localized string, where a
    /// translator can move it.
    static func markdown(_ string: String) -> AttributedString {
        (try? AttributedString(markdown: string)) ?? AttributedString(string)
    }
}
