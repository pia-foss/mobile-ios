//
//  AlertBannersTests.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Testing

@testable import PIAAlertBanners

@MainActor
@Suite
struct AlertBannersTests {
    @Test func showsBanner() {
        let sut = AlertBannerPresenter()

        sut.show(AlertBanner(id: "a", message: "A", style: .error))

        #expect(sut.current?.banner.id == "a")
    }

    @Test func newBannerReplacesCurrentOne() {
        let sut = AlertBannerPresenter()

        sut.show(AlertBanner(id: "sticky", message: "A", style: .error, duration: .indefinite))
        sut.show(AlertBanner(id: "b", message: "B", style: .success))

        #expect(sut.current?.banner.id == "b")
    }

    @Test func dismissByIDOnlyDismissesMatchingBanner() {
        let sut = AlertBannerPresenter()
        sut.show(AlertBanner(id: "a", message: "A", style: .error))

        sut.dismiss(bannerID: "other")
        #expect(sut.current != nil)

        sut.dismiss(bannerID: "a")
        #expect(sut.current == nil)
    }

    @Test func dismissIgnoresStalePresentation() throws {
        let sut = AlertBannerPresenter()
        sut.show(AlertBanner(id: "a", message: "A", style: .error))
        let stale = try #require(sut.current?.id)
        sut.show(AlertBanner(id: "a", message: "A", style: .error))

        sut.dismiss(presentationID: stale)

        #expect(sut.current != nil)
    }

    @Test func removeByIDLeavesOtherBannersOnScreen() {
        let sut = AlertBanners()

        sut.show(AlertBanner(id: "sticky", message: "A", style: .error, duration: .indefinite))
        sut.show(AlertBanner(id: "b", message: "B", style: .success))
        sut.dismiss(id: "sticky")

        #expect(sut.presenter.current?.banner.id == "b")
    }
}
