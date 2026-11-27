//
//  ElementHelper.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 23/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var defaultTimeout: TimeInterval { 10.0 }
    var shortTimeout: TimeInterval { 5.0 }
    /// Establishing or tearing down a real VPN tunnel on a device can take well over `defaultTimeout`.
    var vpnConnectionTimeout: TimeInterval { 30.0 }

    func button(with id: String) -> XCUIElement {
        return buttons[id]
    }

    func textField(with id: String) -> XCUIElement {
        return textFields[id]
    }

    func secureTextField(with id: String) -> XCUIElement {
        return secureTextFields[id]
    }

    func staticText(with id: String) -> XCUIElement {
        return staticTexts[id]
    }

    func otherElement(with id: String) -> XCUIElement {
        return otherElements[id]
    }

    func cell(with id: String) -> XCUIElement {
        return cells[id]
    }

    func searchField(with id: String) -> XCUIElement {
        return searchFields[id]
    }

    func image(with id: String) -> XCUIElement {
        return images[id]
    }

    func switches(with id: String) -> XCUIElement {
        return switches[id]
    }

    /// Swipes up until `element` is on screen, giving up after `maxSwipes`. Off-screen collection view cells aren't in
    /// the accessibility tree until scrolled into view.
    @discardableResult
    func scrollToElement(_ element: XCUIElement, maxSwipes: Int = 5) -> Bool {
        for _ in 0..<maxSwipes where !(element.exists && element.isHittable) {
            swipeUp()
        }
        return element.exists && element.isHittable
    }

    func findElementWithPartialText(_ partialText: String) -> XCUIElement? {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", partialText)
        let matchingStaticTexts = staticTexts.matching(predicate)

        return matchingStaticTexts.firstMatch
    }
}

extension XCUIElement {
    /// Taps the control at the trailing edge of a full-width settings row (a toggle, or a menu's value label). The row
    /// is a single accessibility element, but only that control responds to taps.
    func tapTrailingControl() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
    }

    func isElementHigher(than element: XCUIElement) -> Bool {
        frame.minY < element.frame.minY
    }

    func findChildElement(matching elementType: XCUIElement.ElementType, identifier: String) -> XCUIElement? {
        let childElementQuery = descendants(matching: elementType).matching(identifier: identifier)
        return childElementQuery.element
    }
}

/// An IPv4 address, e.g. "213.21.234.71".
let ipv4Pattern = #"^\d{1,3}(\.\d{1,3}){3}$"#

extension XCUIElement {
    /// Waits for the element's label to match the regular expression `pattern`, returning the label, or nil on timeout.
    func waitForLabel(matching pattern: String, timeout: TimeInterval = 10) -> String? {
        let predicate = NSPredicate(format: "label MATCHES %@", pattern)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed ? label : nil
    }

    /// Waits for the element's value to equal `value`, e.g. "1" for a switch that is on.
    func waitForValue(_ value: String, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
