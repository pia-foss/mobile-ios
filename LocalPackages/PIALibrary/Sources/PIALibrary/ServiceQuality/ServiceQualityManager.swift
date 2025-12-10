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
import kpi
import SwiftyBeaver

private let log = SwiftyBeaver.self

@available(tvOS 17.0, *)
public class ServiceQualityManager: NSObject {

    public static let shared = ServiceQualityManager()
    private let kpiPreferenceName = "PIA_KPI_PREFERENCE_NAME"
    private var kpiManager: KPIAPI?
    private var isAppActive = true
    
    /**
     * Enum defining the different connection sources.
     * e.g. Manual for user-related actions, Automatic for reconnections, etc.
     */
    private enum KPIConnectionSource: String {
        case automatic = "Automatic"
        case manual = "Manual"
    }

    /**
     * Enum defining the supported connection related events.
     */
    private enum KPIConnectionEvent: String {
        case vpnConnectionAttempt = "VPN_CONNECTION_ATTEMPT"
        case vpnConnectionCancelled = "VPN_CONNECTION_CANCELLED"
        case vpnConnectionEstablished = "VPN_CONNECTION_ESTABLISHED"
    }

    /**
     * Enum defining the supported vpn protocols to report.
     */
    private enum KPIVpnProtocol: String {
        case ovpn = "OpenVPN"
        case wireguard = "WireGuard"
        case ipsec = "IPSec"
    }

    /**
     * Enum defining the supported vpn protocols to report.
     */
    private enum KPIEventPropertyKey: String {
        case connectionSource = "connection_source"
        case userAgent = "user_agent"
        case vpnProtocol = "vpn_protocol"
        case timeToConnect = "time_to_connect"
    }

    
    public override init() {
        super.init()
        
        if Client.environment == .staging {
            kpiManager = KPIBuilder()
                .setKPIFlushEventMode(kpiSendEventMode: .perBatch)
                .setKPIClientStateProvider(kpiClientStateProvider: PIAKPIStagingClientStateProvider())
                .setEventTimeRoundGranularity(eventTimeRoundGranularity: KTimeUnit.hours)
                .setEventTimeSendGranularity(eventSendTimeGranularity: KTimeUnit.milliseconds)
                .setRequestFormat(requestFormat: KPIRequestFormat.kape)
                .setPreferenceName(preferenceName: kpiPreferenceName)
                .setUserAgent(userAgent: PIAWebServices.userAgent)
                .build()
        } else {
            kpiManager = KPIBuilder()
                .setKPIFlushEventMode(kpiSendEventMode: .perBatch)
                .setKPIClientStateProvider(kpiClientStateProvider: PIAKPIClientStateProvider())
                .setEventTimeRoundGranularity(eventTimeRoundGranularity: KTimeUnit.hours)
                .setEventTimeSendGranularity(eventSendTimeGranularity: KTimeUnit.milliseconds)
                .setRequestFormat(requestFormat: KPIRequestFormat.kape)
                .setPreferenceName(preferenceName: kpiPreferenceName)
                .setUserAgent(userAgent: PIAWebServices.userAgent)
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
        kpiManager?.stop(callback: { error in
            guard error == nil else {
                log.error("\(error)")
                return
            }
            log.debug("KPI manager stopped")
        })
    }
    
    @objc private func appChangedState(with notification: Notification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            isAppActive = false
            flushEvents()
        default:
            isAppActive = true
        }
    }
    
    @objc private func flushEvents() {
        kpiManager?.flush(callback: { error in
            guard error == nil else {
                log.error("\(error)")
                return
            }
            log.debug("KPI events flushed")
        })
    }
    
    public func connectionAttemptEvent() {
        let connectionSource = connectionSource()
        if connectionSource == .manual && isAppActive {
            let event = KPIClientEvent(
                eventCountry: nil,
                eventName: KPIConnectionEvent.vpnConnectionAttempt.rawValue,
                eventProperties: [
                    KPIEventPropertyKey.connectionSource.rawValue: connectionSource.rawValue,
                    KPIEventPropertyKey.userAgent.rawValue: PIAWebServices.userAgent,
                    KPIEventPropertyKey.vpnProtocol.rawValue: currentProtocol().rawValue
                ],
                eventInstant: Kotlinx_datetimeInstant.companion.fromEpochMilliseconds(epochMilliseconds: Date().epochMilliseconds)
            )
            kpiManager?.submit(event: event) { (error) in
                log.debug("KPI event submitted \(event)")
            }
        }
    }

    public func connectionEstablishedEvent() {
        let connectionSource = connectionSource()
        if connectionSource == .manual && isAppActive {
            let event = KPIClientEvent(
                eventCountry: nil,
                eventName: KPIConnectionEvent.vpnConnectionEstablished.rawValue,
                eventProperties: createEstablishedEventProperties(),
                eventInstant: Kotlinx_datetimeInstant.companion.fromEpochMilliseconds(epochMilliseconds: Date().epochMilliseconds)
            )
            kpiManager?.submit(event: event) { (error) in
                log.debug("KPI event submitted \(event)")
            }
        }
    }

    
    public func connectionCancelledEvent() {
        let disconnectionSource = disconnectionSource()
        if disconnectionSource == .manual && isAppActive {
            let event = KPIClientEvent(
                eventCountry: nil,
                eventName: KPIConnectionEvent.vpnConnectionCancelled.rawValue,
                eventProperties: [
                    KPIEventPropertyKey.connectionSource.rawValue: disconnectionSource.rawValue,
                    KPIEventPropertyKey.userAgent.rawValue: PIAWebServices.userAgent,
                    KPIEventPropertyKey.vpnProtocol.rawValue: currentProtocol().rawValue
                ],
                eventInstant: Kotlinx_datetimeInstant.companion.fromEpochMilliseconds(epochMilliseconds: Date().epochMilliseconds)
            )
            kpiManager?.submit(event: event) { (error) in
                log.debug("KPI event submitted \(event)")
            }
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
        return Client.configuration.connectedManually ?
        KPIConnectionSource.manual :
        KPIConnectionSource.automatic
    }

    private func disconnectionSource() -> KPIConnectionSource {
        return Client.configuration.disconnectedManually ?
        KPIConnectionSource.manual :
        KPIConnectionSource.automatic
    }

    private func currentProtocol() -> KPIVpnProtocol {
        
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType:
            return KPIVpnProtocol.ipsec
        #if(iOS)
        case PIATunnelProfile.vpnType:
            return KPIVpnProtocol.ovpn
        case PIAWGTunnelProfile.vpnType:
            return KPIVpnProtocol.wireguard
        #endif
        default:
            return KPIVpnProtocol.ipsec
        }
    }
    
    private func createEstablishedEventProperties() -> [String: String] {
        var eventProperties: [String: String] = [
            KPIEventPropertyKey.connectionSource.rawValue: connectionSource().rawValue,
            KPIEventPropertyKey.userAgent.rawValue: PIAWebServices.userAgent,
            KPIEventPropertyKey.vpnProtocol.rawValue: currentProtocol().rawValue
        ]
        if let appVersion = Macros.versionString(),
           let optedVersion = Client.preferences.versionWhenServiceQualityOpted,
           appVersion.isVersionGreaterThanEqual(to: optedVersion) {
            eventProperties[KPIEventPropertyKey.timeToConnect.rawValue] = getTimeToConnect()
        }
        return eventProperties
    }
    
    private func getTimeToConnect() -> String {
        return "\(Client.preferences.timeToConnectVPN)"
    }
}

private extension String {
    
    func isVersionGreaterThanEqual(to version: String) -> Bool {
        switch self.versionCompare(version) {
        case .orderedSame, .orderedDescending:
            return true
        default:
            return false
        }
    }
    
    func versionCompare(_ otherVersion: String, versionDelimiter: String = ".") -> ComparisonResult {
        // split the versions by period a default delimiter (.)
        var versionComponents = self.components(separatedBy: versionDelimiter)
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)
        
        // then, find the difference of digit that we will zero pad
        let zeroDiff = versionComponents.count - otherVersionComponents.count
        
        // if there are no differences, we don't need to do anything and use simple .compare
        if zeroDiff == 0 {
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            // we populate an array of missing zero
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            // we add zero pad array to a version with a fewer period and zero.
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros)
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            // we use array components to build back our versions from components and compare them. This time it will have the same period and number of digit.
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric)
        }
    }
}
