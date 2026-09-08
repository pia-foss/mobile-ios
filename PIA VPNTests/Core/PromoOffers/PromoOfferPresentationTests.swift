//
//  PromoOfferPresentationTests.swift
//  PIA VPNTests
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import UIKit
import XCTest

@testable import PIA_VPN

@MainActor
final class PromoOfferPresentationTests: XCTestCase {
    /// Regression: an unassigned `viewController` property left the hosting controller unparented, and
    /// the button's action returning early.
    func testTileParentsItsHostingControllerToTheOwningViewController() {
        let owner = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        window.rootViewController = owner
        window.isHidden = false

        XCTAssertTrue(owner.children.isEmpty)

        let tile = PromoOfferTile(frame: CGRect(x: 0, y: 0, width: 375, height: 240))
        owner.view.addSubview(tile)
        window.layoutIfNeeded()

        XCTAssertEqual(owner.children.count, 1, "the tile did not parent its hosting controller")
    }

    /// The lookup the button's action depends on, which has to survive being nested inside a cell.
    func testPresenterFindsATargetThroughANestedHierarchy() {
        let owner = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        window.rootViewController = owner
        window.isHidden = false

        let cell = UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 375, height: 240))
        owner.view.addSubview(cell)
        let tile = PromoOfferTile(frame: cell.bounds)
        cell.contentView.addSubview(tile)
        window.layoutIfNeeded()

        XCTAssertEqual(owner.children.count, 1, "the responder chain did not reach the owner")

        PromoOfferSheetHostingController.present(from: owner)

        XCTAssertTrue(
            owner.presentedViewController is PromoOfferSheetHostingController,
            "the sheet was not presented")
        XCTAssertEqual(owner.presentedViewController?.modalPresentationStyle, .overFullScreen)
    }
}
