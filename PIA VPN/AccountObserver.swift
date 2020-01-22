//
//  AccountObserver.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/6/17.
//  Copyright © 2020 Private Internet Access Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

class AccountObserver {
    static let shared = AccountObserver()
    
    private let secondsPerDay: TimeInterval = 24 * 60 * 60

    private init() {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func start() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(registerExpirationNotifications), name: .PIAAccountDidLogin, object: nil)
        nc.addObserver(self, selector: #selector(registerExpirationNotifications), name: .PIAAccountDidSignup, object: nil)
        nc.addObserver(self, selector: #selector(registerExpirationNotifications), name: .PIAAccountDidRefresh, object: nil)
        nc.addObserver(self, selector: #selector(accountDidLogout), name: .PIAAccountDidLogout, object: nil)
    }
    
    @objc private func registerExpirationNotifications() -> [Date]? {
        let application = UIApplication.shared
        application.cancelAllLocalNotifications()
        
        guard let accountInfo = Client.providers.accountProvider.currentUser?.info else {
            return nil
        }
        guard (!accountInfo.isExpired && !accountInfo.isRecurring) else {
            return nil
        }
        
        let oneDayPrior = accountInfo.expirationDate.addingTimeInterval(-secondsPerDay)
        let threeDaysPrior = accountInfo.expirationDate.addingTimeInterval(-3 * secondsPerDay)
        let oneWeekPrior = accountInfo.expirationDate.addingTimeInterval(-7 * secondsPerDay)
        let oneMonthPrior = accountInfo.expirationDate.addingTimeInterval(-30 * secondsPerDay)
        
        var dates: [Date] = []
        
        if ((accountInfo.plan == .yearly) && (oneMonthPrior.timeIntervalSinceNow > 0)) {
            dates.append(oneMonthPrior)
        }
        if (oneWeekPrior.timeIntervalSinceNow > 0) {
            dates.append(oneWeekPrior)
        }
        if (threeDaysPrior.timeIntervalSinceNow > 0) {
            dates.append(threeDaysPrior)
        }
        if (oneDayPrior.timeIntervalSinceNow > 0) {
            dates.append(oneDayPrior)
        }
        
        for date in dates {
            let note = UILocalNotification()
            note.timeZone = NSTimeZone.local
            note.fireDate = date
            note.alertAction = L10n.Expiration.title
            note.alertBody = L10n.Expiration.message
            note.userInfo = ["date": date]
            note.soundName = UILocalNotificationDefaultSoundName
            note.applicationIconBadgeNumber = 1
            
            application.scheduleLocalNotification(note)
        }
        
        if !dates.isEmpty {
            log.debug("Account: Registered renewal notifications on: \(dates)")
        }
    
        return dates
    }
    
    private func cancelExpirationNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()

        log.debug("Account: Cancelled any pending renewal notification")
    }
    
    @objc private func accountDidLogout() {
        log.debug("Account: Logging out, uninstalling local profiles...")

        Client.providers.vpnProvider.uninstallAll()
        cancelExpirationNotifications()
    }
}
