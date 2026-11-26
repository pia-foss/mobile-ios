//
//  AppPreferences+AutoProtocolNudge.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

extension AppPreferences {
    var autoProtocolNudgeHistory: AutoProtocolNudgeCaps.History {
        AutoProtocolNudgeCaps.History(
            promptDates: autoProtocolPromptDates,
            dismissCount: autoProtocolDismissCount,
            lastDismissedAt: autoProtocolLastDismissedAt,
            accepted: autoProtocolAccepted
        )
    }

    func recordAutoProtocolNudgeShown(at date: Date) {
        autoProtocolPromptDates = (autoProtocolPromptDates + [date]).suffix(AppConstants.AutoProtocolNudge.lifetimeCap)
    }

    func recordAutoProtocolNudgeDismissed(at date: Date) {
        autoProtocolDismissCount += 1
        autoProtocolLastDismissedAt = date
    }

    func recordAutoProtocolNudgeAccepted() {
        autoProtocolAccepted = true
    }
}
