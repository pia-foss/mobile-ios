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

    override func setUp() {
        super.setUp()
        Client.database = Client.Database(group: "group.com.privateinternetaccess")
        mockKPI = MockKPIAPI()
        sut = ServiceQualityManager(kpiManager: mockKPI)
        setConsent(true)
    }

    override func tearDown() {
        setConsent(false)
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
        let submitted = expectation(description: "event submitted")
        mockKPI.expectSubmission(submitted)
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

    func testSuccessEventIncludesRetryCount() {
        let event = firstSubmittedEvent {
            sut.iapProcessingSuccessEvent(origin: .renewal, retryCount: 0)
        }

        XCTAssertEqual(event?.eventName, "iap_processing_success")
        XCTAssertEqual(event?.eventProperties["origin"], "renewal")
        XCTAssertEqual(event?.eventProperties["retryCount"], "0")
    }

    func testRetryEventIncludesErrorAndRetryCount() {
        let event = firstSubmittedEvent {
            sut.iapProcessingRetryEvent(
                origin: .renewal,
                error: ClientError.throttled(retryAfter: 5),
                retryCount: 2
            )
        }

        XCTAssertEqual(event?.eventName, "iap_processing_retry")
        XCTAssertEqual(event?.eventProperties["origin"], "renewal")
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

    func testEventSuppressedWhenConsentDisabled() {
        setConsent(false)

        let notSubmitted = expectation(description: "no event submitted")
        notSubmitted.isInverted = true
        mockKPI.expectSubmission(notSubmitted)

        sut.iapProcessingPurchaseEvent(origin: .signup)

        wait(for: [notSubmitted], timeout: 1.0)
        XCTAssertTrue(mockKPI.submittedEvents.isEmpty)
    }
}
