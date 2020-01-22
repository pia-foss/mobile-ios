//
//  DataCounter.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
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

extension Notification.Name {
    static let DataCounterDidReport = Notification.Name("DataCounterDidReport")
}

class DataCounter {
    static let shared = DataCounter()

    private var isCounting = false

    private var timer: Timer?
    
    private var receivedBytes: UInt32 = 0
    
    private var sentBytes: UInt32 = 0

    private var lastStopDate: Date?

    private init() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: .UIApplicationWillResignActive, object: nil)
    }
    
    func startCounting() {
        isCounting = true
        resumeCounting()
    }
    
    func resumeCounting() {
        guard (timer == nil) else {
            return
        }
        timer = Timer.scheduledTimer(
            timeInterval: AppConfiguration.DataCounter.interval,
            target: self,
            selector: #selector(timerDidCount),
            userInfo: nil,
            repeats: true
        )
    }
    
    func stopCounting() {
        timer?.invalidate()
        timer = nil
        lastStopDate = Date()
    }
    
    func notifyCurrentState() {
        timerDidCount()
    }
    
    // MARK: Notifications
    
    @objc private func timerDidCount() {
        guard Client.providers.accountProvider.isLoggedIn else {
            return
        }
        
        var numberOfSentBytes: UInt32 = 0
        var numberOfReceivedBytes: UInt32 = 0
        guard DataCounterGetCurrentState(&numberOfSentBytes, &numberOfReceivedBytes) else {
            return
        }
        
        let deltaReceived = UInt64(numberOfReceivedBytes - receivedBytes)
        let deltaSent = UInt64(numberOfSentBytes - sentBytes)
        
        let isFirst = ((receivedBytes == 0) && (sentBytes == 0))
        receivedBytes = numberOfReceivedBytes
        sentBytes = numberOfSentBytes
        
        // skip first calculation, no starting point for delta
        guard (!isFirst && (lastStopDate == nil)) else {
            lastStopDate = nil
            return
        }
        
        let downloadedBytes = deltaReceived
        let uploadedBytes = deltaSent
        
//        NSLog(@"DataCounter: D %.2fkb/s - U %.2fkb/s", downloadSpeed, uploadSpeed);
        Macros.postAppNotification(.DataCounterDidReport, [
            .downloaded: downloadedBytes,
            .uploaded: uploadedBytes
        ], false)
    }
    
    @objc private func applicationDidBecomeActive(notification: Notification) {
        if isCounting {
            resumeCounting()
        }
    }
    
    @objc private func applicationWillResignActive(notification: Notification) {
        stopCounting()
    }
}
