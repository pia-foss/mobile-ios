//
//  ServiceQualityManagerTests.swift
//  PIALibraryTests
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import PIAKPI
import XCTest

@testable import PIALibrary

final class ServiceQualityManagerTests: XCTestCase {

    private var mockKPI: MockKPIAPI!
    private var sut: ServiceQualityManager!
    private var originalConsent: Bool!

    override func setUp() {
        super.setUp()
        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        originalConsent = Client.preferences.shareServiceQualityData
        mockKPI = MockKPIAPI()
        sut = ServiceQualityManager(kpiManager: mockKPI)
        setConsent(true)
    }

    override func tearDown() {
        setConsent(originalConsent)
        originalConsent = nil
        sut = nil
        mockKPI = nil
        super.tearDown()
    }

    private func setConsent(_ enabled: Bool) {
        let prefs = Client.preferences.editable()
        prefs.shareServiceQualityData = enabled
        prefs.commit()
    }

    private func firstSubmittedEvent(
        after action: () -> Void,
        timeout: TimeInterval = 2.0
    ) -> KPIClientEvent? {
        let submitted = mockKPI.expectSubmissions()
        action()
        wait(for: [submitted], timeout: timeout)
        return mockKPI.submittedEvents.first
    }

    func testPurchaseEventNameAndProperties() {
        let event = firstSubmittedEvent {
            sut.iapProcessingPurchaseEvent(origin: .signup)
        }

        XCTAssertEqual(event?.eventName, "iap_processing_purchase")
        XCTAssertEqual(event?.eventProperties["origin"], "signup")
        XCTAssertEqual(event?.eventProperties["environment"], Client.environment.rawValue)
        // Purchase carries only origin + environment.
        XCTAssertNil(event?.eventProperties["retryCount"])
        XCTAssertNil(event?.eventProperties["error"])
    }

    /// The `origin` raw values are the XV wire contract, so they are asserted as literals.
    func testOriginWireValues() {
        XCTAssertEqual(ServiceQualityManager.KPIIapOrigin.signup.rawValue, "signup")
        XCTAssertEqual(ServiceQualityManager.KPIIapOrigin.renew.rawValue, "renew")
        XCTAssertEqual(ServiceQualityManager.KPIIapOrigin.restore.rawValue, "restore")
        XCTAssertEqual(ServiceQualityManager.KPIIapOrigin.update.rawValue, "update")
    }

    func testRestoreOriginIsReported() {
        let event = firstSubmittedEvent {
            sut.iapProcessingPurchaseEvent(origin: .restore)
        }

        XCTAssertEqual(event?.eventName, "iap_processing_purchase")
        XCTAssertEqual(event?.eventProperties["origin"], "restore")
    }

    func testSuccessEventIncludesRetryCount() {
        let event = firstSubmittedEvent {
            sut.iapProcessingSuccessEvent(origin: .renew, retryCount: 0)
        }

        XCTAssertEqual(event?.eventName, "iap_processing_success")
        XCTAssertEqual(event?.eventProperties["origin"], "renew")
        XCTAssertEqual(event?.eventProperties["retryCount"], "0")
    }

    func testRetryEventIncludesErrorAndRetryCount() {
        let event = firstSubmittedEvent {
            sut.iapProcessingRetryEvent(
                origin: .renew,
                error: ClientError.throttled(retryAfter: 5),
                retryCount: 2
            )
        }

        XCTAssertEqual(event?.eventName, "iap_processing_retry")
        XCTAssertEqual(event?.eventProperties["origin"], "renew")
        XCTAssertEqual(event?.eventProperties["error"], "throttled_5")
        XCTAssertEqual(event?.eventProperties["retryCount"], "2")
    }

    func testFailureEventIncludesErrorCodeAndRawError() {
        let event = firstSubmittedEvent {
            sut.iapProcessingFailureEvent(origin: .signup, error: ClientError.badReceipt)
        }

        XCTAssertEqual(event?.eventName, "iap_processing_failure")
        XCTAssertEqual(event?.eventProperties["origin"], "signup")
        XCTAssertEqual(event?.eventProperties["error"], "badReceipt")
        XCTAssertNotNil(event?.eventProperties["rawError"])
        // retryCount is optional on failure and omitted until retry logic exists.
        XCTAssertNil(event?.eventProperties["retryCount"])
    }

    func testFailureEventSurfacesInternalErrorMessage() {
        let event = firstSubmittedEvent {
            sut.iapProcessingFailureEvent(
                origin: .signup,
                error: ClientError.unknown(code: 606, message: "boom")
            )
        }

        XCTAssertEqual(event?.eventProperties["error"], "unknown_606")
        XCTAssertEqual(event?.eventProperties["internalError"], "boom")
    }

    // MARK: Common properties

    func testIapEventsCarryPlatformAndVersion() {
        let event = firstSubmittedEvent {
            sut.iapProcessingPurchaseEvent(origin: .signup)
        }

        XCTAssertEqual(event?.eventProperties["platform"], Self.expectedPlatform)
        XCTAssertEqual(event?.eventProperties["version"], Macros.versionString() ?? "Unknown")
    }

    /// The ticket puts these properties on every event, not only the IAP ones.
    func testConnectionEventsCarryPlatformAndVersion() {
        Client.configuration.connectedManually = true
        defer { Client.configuration.connectedManually = false }

        let event = firstSubmittedEvent {
            sut.connectionAttemptEvent()
        }

        XCTAssertEqual(event?.eventName, "VPN_CONNECTION_ATTEMPT")
        XCTAssertEqual(event?.eventProperties["platform"], Self.expectedPlatform)
        XCTAssertEqual(event?.eventProperties["version"], Macros.versionString() ?? "Unknown")
        // The pre-existing connection properties must survive the change.
        XCTAssertEqual(event?.eventProperties["connection_source"], "Manual")
        XCTAssertNotNil(event?.eventProperties["vpn_protocol"])
    }

    /// Spelled out rather than delegating to `Macros`, so the wire values stay
    /// asserted against literals.
    private static var expectedPlatform: String {
        #if targetEnvironment(macCatalyst)
            return "macOS"
        #elseif os(macOS)
            return "macOS"
        #elseif os(tvOS)
            return "tvOS"
        #else
            return "iOS"
        #endif
    }

    // MARK: Error detail

    /// A non-`ClientError` enum must report its case name, not the opaque case
    /// index that `NSError` bridging produces.
    func testNonClientErrorReportsCaseName() {
        let event = firstSubmittedEvent {
            sut.iapProcessingFailureEvent(origin: .renew, error: SampleError.receiptRejected)
        }

        XCTAssertEqual(event?.eventProperties["error"], "receiptRejected")
    }

    /// Associated values are described inline, so the value is not a bare case name.
    func testNonClientErrorWithAssociatedValueReportsCaseName() {
        let event = firstSubmittedEvent {
            sut.iapProcessingFailureEvent(origin: .renew, error: SampleError.rejected(status: 409))
        }

        XCTAssertEqual(event?.eventProperties["error"], "rejected(status: 409)")
    }

    /// A genuine `NSError` is described rather than reduced to domain/code.
    /// The error is held as `Error` on purpose: `String(describing:)` renders a
    /// bridged type differently once its static type is the existential, which
    /// is how the production call site receives it.
    func testNSErrorIsDescribed() {
        let urlError: Error = URLError(.notConnectedToInternet)
        let event = firstSubmittedEvent {
            sut.iapProcessingFailureEvent(origin: .renew, error: urlError)
        }

        XCTAssertEqual(event?.eventProperties["error"], String(describing: urlError))
        XCTAssertEqual(event?.eventProperties["error"], "Error Domain=NSURLErrorDomain Code=-1009 \"(null)\"")
    }

    private enum SampleError: Error {
        case receiptRejected
        case rejected(status: Int)
    }

    func testEventSuppressedWhenConsentDisabled() {
        setConsent(false)

        let notSubmitted = mockKPI.expectNoSubmission()

        sut.iapProcessingPurchaseEvent(origin: .signup)

        wait(for: [notSubmitted], timeout: 1.0)
        XCTAssertTrue(mockKPI.submittedEvents.isEmpty)
    }
}
