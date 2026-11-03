//
//  AutoProtocolNudgeCaps.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

/// How often the "switch to Automatic" prompt may be shown. Mirrors Android's caps so both platforms
/// nag at the same rate. Pure: the caller supplies the history and the clock.
enum AutoProtocolNudgeCaps {

    struct History {
        var promptDates: [Date]
        var dismissCount: Int
        var lastDismissedAt: Date?
        var accepted: Bool

        init(promptDates: [Date] = [], dismissCount: Int = 0, lastDismissedAt: Date? = nil, accepted: Bool = false) {
            self.promptDates = promptDates
            self.dismissCount = dismissCount
            self.lastDismissedAt = lastDismissedAt
            self.accepted = accepted
        }
    }

    static func allowsPrompt(_ history: History, now: Date) -> Bool {
        guard !history.accepted, history.dismissCount < AppConstants.AutoProtocolNudge.dismissStopCount else {
            return false
        }

        if let lastDismissedAt = history.lastDismissedAt, now.timeIntervalSince(lastDismissedAt) < AppConstants.AutoProtocolNudge.dismissCooldown {
            return false
        }

        guard history.promptDates.count < AppConstants.AutoProtocolNudge.lifetimeCap else {
            return false
        }

        return !history.promptDates.contains { now.timeIntervalSince($0) < AppConstants.AutoProtocolNudge.promptCapWindow }
    }
}
