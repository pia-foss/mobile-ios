//
//  ServiceQualityManager.swift
//  PIALibrary
//  
//  Created by Jose Blaya on 24/3/21.
//  Copyright © 2021 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import Foundation
import UIKit
import PIAKPI
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class ServiceQualityManager: NSObject {
    
    private var kpiToken = ""
    public static let shared = ServiceQualityManager()
    private var kpiManager: KPIAPI?
    private var isAppActive = true
    
    public override init() {
        super.init()
        
        if Client.environment == .staging {
            kpiToken = LibraryConstants.Elastic.stagingToken
            kpiManager = KPIBuilder()
                .setAppVersion(appVersion: Macros.localizedVersionNumber())
                .setKPIFlushEventMode(kpiSendEventMode: .perBatch)
                .setKPIClientStateProvider(kpiClientStateProvider: PIAKPIStagingClientStateProvider())
                .build()
        } else {
            kpiToken = LibraryConstants.Elastic.liveToken
            kpiManager = KPIBuilder()
                .setAppVersion(appVersion: Macros.localizedVersionNumber())
                .setKPIFlushEventMode(kpiSendEventMode: .perBatch)
                .setKPIClientStateProvider(kpiClientStateProvider: PIAKPIClientStateProvider())
                .build()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appChangedState(with:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appChangedState(with:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func start() {
        kpiManager?.start()
        log.debug("KPI manager starts collecting statistics")
    }

    public func stop() {
        kpiManager?.stop()
        log.debug("KPI manager stopped")
    }
    
    @objc private func appChangedState(with notification: Notification) {
        if notification.name == UIApplication.didBecomeActiveNotification || notification.name ==  UIApplication.didFinishLaunchingNotification {
            isAppActive = true
        } else if notification.name == UIApplication.didEnterBackgroundNotification {
            isAppActive = false
            flushEvents()
        }
    }
    
    @objc private func flushEvents() {
        kpiManager?.flush(callback: { error in
            guard error != nil else {
                return
            }
            log.error("\(error)")
        })
    }
    
    public func connectionAttemptEvent() {
        let event = KPIClientEvent(eventCountry: nil, eventName: KPIConnectionEvent.vpnConnectionAttempt, eventProperties: KPIClientEvent.EventProperties(connectionSource: connectionSource(), data: nil, preRelease: isPreRelease(), reason: nil, serverIdentifier: nil, userAgent: PIAWebServices.userAgent, vpnProtocol: currentProtocol()), eventToken: kpiToken)
        kpiManager?.submit(event: event) { (error) in
            log.debug("Event sent \(event)")
        }
    }

    public func connectionEstablishedEvent() {
        let connectionSource = connectionSource()
        if connectionSource == .manual && isAppActive == true {
            let event = KPIClientEvent(eventCountry: nil, eventName: KPIConnectionEvent.vpnConnectionEstablished, eventProperties: KPIClientEvent.EventProperties(connectionSource: connectionSource, data: nil, preRelease: isPreRelease(), reason: nil, serverIdentifier: nil, userAgent: PIAWebServices.userAgent, vpnProtocol: currentProtocol()), eventToken: kpiToken)
            kpiManager?.submit(event: event) { (error) in
                log.debug("Event sent \(event)")
            }
        }
    }

    
    public func connectionCancelledEvent() {
        let event = KPIClientEvent(eventCountry: nil, eventName: KPIConnectionEvent.vpnConnectionCancelled, eventProperties: KPIClientEvent.EventProperties(connectionSource: disconnectionSource(), data: nil, preRelease: isPreRelease(), reason: nil, serverIdentifier: nil, userAgent: PIAWebServices.userAgent, vpnProtocol: currentProtocol()), eventToken: kpiToken)
        kpiManager?.submit(event: event) { (error) in
            log.debug("Event sent \(event)")
        }
    }

    public func availableData(completion: @escaping (([String]) -> Void)) {
        kpiManager?.recentEvents { events in
            completion(events)
        }
    }
    
    private func isPreRelease() -> Bool {
        return Client.environment == .staging ? true : false
    }
    
    private func connectionSource() -> KPIConnectionSource {
        return Client.configuration.connectedManually ? .manual : .automatic
    }

    private func disconnectionSource() -> KPIConnectionSource {
        return Client.configuration.disconnectedManually ? .manual : .automatic
    }

    private func currentProtocol() -> KPIVpnProtocol {
        
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType:
            return KPIVpnProtocol.ipsec
        case PIATunnelProfile.vpnType:
            return KPIVpnProtocol.openvpn
        case PIAWGTunnelProfile.vpnType:
            return KPIVpnProtocol.wireguard
        default:
            return KPIVpnProtocol.ipsec
        }

    }

}
