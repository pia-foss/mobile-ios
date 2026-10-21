//
//  AlertBannerActor.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Foundation

/// The global actor banner state lives on, off the main thread.
@globalActor
public actor AlertBannerActor {
    public static let shared = AlertBannerActor()
}
