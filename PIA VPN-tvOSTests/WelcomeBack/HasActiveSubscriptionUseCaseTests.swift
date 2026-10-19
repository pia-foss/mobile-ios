//
//  HasActiveSubscriptionUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import PIABase
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

final class HasActiveSubscriptionUseCaseTests: XCTestCase {
    private func makeSut(currentReceipt: JWS?) -> HasActiveSubscriptionUseCase {
        HasActiveSubscriptionUseCase(
            paymentProvider: PaymentProviderMock(result: .failure(ClientError.unexpectedReply), currentReceipt: currentReceipt))
    }

    func test_isSubscribed_when_a_receipt_is_held() async {
        let sut = makeSut(currentReceipt: JWS("jws-transaction")!)

        let isSubscribed = await sut()

        XCTAssertTrue(isSubscribed)
    }

    func test_isNotSubscribed_when_no_receipt_is_held() async {
        let sut = makeSut(currentReceipt: nil)

        let isSubscribed = await sut()

        XCTAssertFalse(isSubscribed)
    }
}
