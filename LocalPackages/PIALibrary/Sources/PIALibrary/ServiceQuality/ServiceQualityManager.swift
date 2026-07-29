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
import PIAKPI
import UIKit

private let log = PIALogger.logger(for: ServiceQualityManager.self)

public final class ServiceQualityManager: NSObject {

    public static let shared = ServiceQualityManager()
    private static let kpiPreferenceName = "PIA_KPI_PREFERENCE_NAME"
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

    /**
     * Enum defining the in-app-purchase processing events.
     * These track the KapeClientSDK receipt-verification funnel.
     */
    private enum KPIIapEvent: String {
        case iapProcessingPurchase = "iap_processing_purchase"
        case iapProcessingSuccess = "iap_processing_success"
        case iapProcessingRetry = "iap_processing_retry"
        case iapProcessingFailure = "iap_processing_failure"
    }

    /**
     * Property keys for the IAP processing events. Their raw values are camelCase
     * on purpose: they are the cross-platform (XV) wire contract, unlike the
     * lower_snake_case keys used by the connection events above.
     */
    private enum KPIIapPropertyKey: String {
        case origin
        case environment
        case retryCount
        case error
        case internalError
        case rawError
    }

    /**
     * The user-facing flow a purchase originated from, reported as the `origin`
     * property. NOTE: the XV spec lists `origin` but does not enumerate its values;
     * these map to the two purchase-crediting flows and can be adjusted if XV
     * expects a fixed literal (e.g. a store name).
     */
    public enum KPIIapOrigin: String {
        case signup
        case renewal
    }

    public override init() {
        super.init()
        kpiManager = ServiceQualityManager.makeKPIManager()
        registerAppStateObservers()
    }

    /// Injectable initializer used by unit tests to supply a mock `KPIAPI`.
    init(kpiManager: KPIAPI?) {
        super.init()
        self.kpiManager = kpiManager
        registerAppStateObservers()
    }

    private static func makeKPIManager() -> KPIAPI? {
        do {
            let provider: KPIClientStateProvider = Client.environment == .staging ? PIAKPIStagingClientStateProvider() : PIAKPIClientStateProvider()
            return try KPIBuilder()
                .setFlushEventMode(.perBatch)
                .setKPIClientStateProvider(provider)
                .setEventTimeRoundGranularity(.hours)
                .setEventTimeSendGranularity(.milliseconds)
                .setRequestFormat(.kape)
                .setPreferenceName(kpiPreferenceName)
                .setUserAgent(PIAWebServices.userAgent)
                .build()
        } catch {
            log.error("KPI manager build failed: \(error)")
            return nil
        }
    }

    private func registerAppStateObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appChangedState(with:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appChangedState(with:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func start() {
        guard let kpiManager else { return }

        Task {
            await kpiManager.start()
            log.debug("KPI manager starts collecting statistics")
        }
    }

    public func stop() {
        guard let kpiManager else { return }

        Task {
            do {
                try await kpiManager.stop()
                log.debug("KPI manager stopped")
            } catch {
                log.error("\(error)")
            }
        }
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
        guard let kpiManager else { return }

        Task {
            do {
                try await kpiManager.flush()
                log.debug("KPI events flushed")
            } catch {
                log.error("\(error)")
            }
        }
    }

    public func connectionAttemptEvent() {
        let connectionSource = connectionSource()
        guard connectionSource == .manual, isAppActive, let kpiManager else { return }

        let event = KPIClientEvent(
            eventCountry: nil,
            eventName: KPIConnectionEvent.vpnConnectionAttempt.rawValue,
            eventProperties: [
                KPIEventPropertyKey.connectionSource.rawValue: connectionSource.rawValue,
                KPIEventPropertyKey.userAgent.rawValue: PIAWebServices.userAgent,
                KPIEventPropertyKey.vpnProtocol.rawValue: currentProtocol().rawValue
            ],
            eventInstant: Date()
        )

        Task {
            do {
                try await kpiManager.submit(event: event)
                log.debug("KPI event submitted \(event)")
            } catch {
                log.error("\(error)")
            }
        }
    }

    public func connectionEstablishedEvent() {
        let connectionSource = connectionSource()
        guard connectionSource == .manual, isAppActive, let kpiManager else { return }

        let event = KPIClientEvent(
            eventCountry: nil,
            eventName: KPIConnectionEvent.vpnConnectionEstablished.rawValue,
            eventProperties: createEstablishedEventProperties(),
            eventInstant: Date()
        )

        Task {
            do {
                try await kpiManager.submit(event: event)
                log.debug("KPI event submitted \(event)")
            } catch {
                log.error("\(error)")
            }
        }
    }

    public func connectionCancelledEvent() {
        let disconnectionSource = disconnectionSource()
        guard disconnectionSource == .manual, isAppActive, let kpiManager else { return }

        let event = KPIClientEvent(
            eventCountry: nil,
            eventName: KPIConnectionEvent.vpnConnectionCancelled.rawValue,
            eventProperties: [
                KPIEventPropertyKey.connectionSource.rawValue: disconnectionSource.rawValue,
                KPIEventPropertyKey.userAgent.rawValue: PIAWebServices.userAgent,
                KPIEventPropertyKey.vpnProtocol.rawValue: currentProtocol().rawValue
            ],
            eventInstant: Date()
        )

        Task {
            do {
                try await kpiManager.submit(event: event)
                log.debug("KPI event submitted \(event)")
            } catch {
                log.error("\(error)")
            }
        }
    }

    // MARK: IAP processing events

    /// A new IAP transaction starts processing on the KapeClientSDK path.
    public func iapProcessingPurchaseEvent(origin: KPIIapOrigin) {
        submitIapEvent(.iapProcessingPurchase, properties: baseIapProperties(origin: origin))
    }

    /// The purchase succeeded verification using KapeClientSDK.
    public func iapProcessingSuccessEvent(origin: KPIIapOrigin, retryCount: Int = 0) {
        var properties = baseIapProperties(origin: origin)
        properties[KPIIapPropertyKey.retryCount.rawValue] = String(retryCount)
        submitIapEvent(.iapProcessingSuccess, properties: properties)
    }

    /// A verification attempt failed and is being retried on the KapeClientSDK path.
    /// Reported when signup verification returns HTTP 400 and the login-with-receipt
    /// fallback re-verifies the same transaction; `retryCount` is that attempt's number.
    public func iapProcessingRetryEvent(origin: KPIIapOrigin, error: Error, retryCount: Int) {
        var properties = baseIapProperties(origin: origin)
        properties[KPIIapPropertyKey.retryCount.rawValue] = String(retryCount)
        properties[KPIIapPropertyKey.error.rawValue] = iapErrorCode(for: error)
        submitIapEvent(.iapProcessingRetry, properties: properties)
    }

    /// The purchase failed verification using KapeClientSDK.
    public func iapProcessingFailureEvent(origin: KPIIapOrigin, error: Error, retryCount: Int? = nil) {
        var properties = baseIapProperties(origin: origin)
        properties[KPIIapPropertyKey.error.rawValue] = iapErrorCode(for: error)
        if let retryCount {
            properties[KPIIapPropertyKey.retryCount.rawValue] = String(retryCount)
        }
        properties.merge(iapErrorDetails(for: error)) { _, new in new }
        submitIapEvent(.iapProcessingFailure, properties: properties)
    }

    private func baseIapProperties(origin: KPIIapOrigin) -> [String: String] {
        [
            KPIIapPropertyKey.origin.rawValue: origin.rawValue,
            KPIIapPropertyKey.environment.rawValue: Client.environment.rawValue
        ]
    }

    /// Short, stable identifier for the primary `error` property.
    private func iapErrorCode(for error: Error) -> String {
        switch error {
        case let clientError as ClientError:
            switch clientError {
            case .unknown(let code, _): return "unknown_\(code)"
            case .throttled(let retryAfter): return "throttled_\(retryAfter)"
            case .libraryError: return "library_error"
            default: return String(describing: clientError)
            }
        default:
            let nsError = error as NSError
            return "\(nsError.domain)_\(nsError.code)"
        }
    }

    /// Optional diagnostic detail for failure events (`internalError`, `rawError`).
    /// The XV spec also lists a `csi` property, which has no client-side source on
    /// Apple platforms and is therefore never reported.
    private func iapErrorDetails(for error: Error) -> [String: String] {
        var details: [String: String] = [
            KPIIapPropertyKey.rawError.rawValue: String(describing: error)
        ]
        if let clientError = error as? ClientError {
            switch clientError {
            case .unknown(_, let message), .libraryError(let message):
                if let message {
                    details[KPIIapPropertyKey.internalError.rawValue] = message
                }
            default:
                break
            }
        }
        return details
    }

    private func submitIapEvent(_ event: KPIIapEvent, properties: [String: String]) {
        guard Client.preferences.shareServiceQualityData, let kpiManager else { return }

        let clientEvent = KPIClientEvent(
            eventCountry: nil,
            eventName: event.rawValue,
            eventProperties: properties,
            eventInstant: Date()
        )

        Task {
            do {
                try await kpiManager.submit(event: clientEvent)
                log.debug("KPI event submitted \(clientEvent)")
            } catch {
                log.error("\(error)")
            }
        }
    }

    public func availableData(completion: @escaping (([String]) -> Void)) {
        guard let kpiManager else {
            completion([])
            return
        }

        Task {
            let events = await kpiManager.recentEvents()
            completion(events)
        }
    }

    private func isPreRelease() -> Bool {
        return Client.environment == .staging ? true : false
    }

    private func connectionSource() -> KPIConnectionSource {
        return Client.configuration.connectedManually ? KPIConnectionSource.manual : KPIConnectionSource.automatic
    }

    private func disconnectionSource() -> KPIConnectionSource {
        return Client.configuration.disconnectedManually ? KPIConnectionSource.manual : KPIConnectionSource.automatic
    }

    private func currentProtocol() -> KPIVpnProtocol {
        switch Client.providers.vpnProvider.currentVPNType {
        case IKEv2Profile.vpnType: return .ipsec
        #if !os(tvOS)
            case PIATunnelProfile.vpnType: return .ovpn
            case PIAWGTunnelProfile.vpnType: return .wireguard
        #endif
        case let other:
            log.warning("Unknown VPN type: \(other)")
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
            appVersion.isVersionGreaterThanEqual(to: optedVersion)
        {
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
