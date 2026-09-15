//
//  FeatureFlags.swift
//  PIALibrary
//
//  Created by Mario on 23/03/2026.
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// Known values of remote configurable feature flags.
///
/// See ``FeatureFlagHolder``.
public enum FeatureFlag: String, CaseIterable, Sendable {
    case forceUpdate = "force_update"
    case checkDipExpirationRequest = "check-dip-expiration-request"
    case disableSystemRatingDialog = "disable-system-rating-dialogue"
    case showLeakProtection = "ios_custom_leak_protection_v2"
    case showLeakProtectionNotifications = "ios_custom_leak_protection_notifications_v2"
    case showDynamicIslandLiveActivity = "ios_dynamic_island_live_activity_v2"
}
