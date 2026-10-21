//
//  AlertBannersTests.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Testing

@testable import PIAAlertBanners

@Suite
struct AlertBannersTests {
    @Test func callsApplyInCallOrder() async {
        let sut = AlertBanners()

        sut.show(AlertBanner(id: "sticky", message: "A", style: .error, duration: .indefinite))
        #expect(await sut.isDisplaying(id: "sticky"))

        sut.dismiss(id: "sticky")
        #expect(await !sut.isDisplaying(id: "sticky"))
    }

    @Test func showThenDismissFromAnotherThreadLeavesNothingOnScreen() async {
        let sut = AlertBanners()

        await Task.detached {
            sut.show(AlertBanner(id: "sticky", message: "A", style: .error, duration: .indefinite))
            sut.dismiss(id: "sticky")
        }.value

        #expect(await !sut.isDisplaying(id: "sticky"))
    }
}
