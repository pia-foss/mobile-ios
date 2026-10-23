//
//  AlertBannerHubTests.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Foundation
import Testing

@testable import PIAAlertBanners

@AlertBannerActor
@Suite
struct AlertBannerHubTests {
    @Test func showsBanner() {
        let sut = AlertBannerHub(sleep: Self.never)

        sut.show(AlertBanner(id: "a", message: "A", style: .error))

        #expect(sut.current?.banner.id == "a")
        #expect(sut.isDisplaying(bannerID: "a"))
    }

    @Test func newBannerReplacesCurrentOne() {
        let sut = AlertBannerHub(sleep: Self.never)

        sut.show(AlertBanner(id: "sticky", message: "A", style: .error, duration: .indefinite))
        sut.show(AlertBanner(id: "b", message: "B", style: .success))

        #expect(sut.current?.banner.id == "b")
        #expect(!sut.isDisplaying(bannerID: "sticky"))
    }

    @Test func dismissByIDOnlyDismissesMatchingBanner() {
        let sut = AlertBannerHub(sleep: Self.never)
        sut.show(AlertBanner(id: "a", message: "A", style: .error))

        sut.dismiss(bannerID: "other")
        #expect(sut.current != nil)

        sut.dismiss(bannerID: "a")
        #expect(sut.current == nil)
    }

    @Test func timedBannerDismissesItself() async throws {
        let sut = AlertBannerHub(sleep: { _ in })

        sut.show(AlertBanner(message: "A", style: .error, duration: .seconds(1)))
        try await Task.sleep(for: .seconds(1))

        #expect(sut.current == nil)
    }

    private static let never: AlertBannerHub.Sleep = { _ in
        try await Task.sleep(nanoseconds: .max)
    }
}
