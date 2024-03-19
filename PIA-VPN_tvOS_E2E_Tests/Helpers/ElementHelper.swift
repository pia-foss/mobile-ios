//
//  ElementHelper.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 26/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var defaultTimeout: TimeInterval { 10.0 }
    var shortTimeout: TimeInterval { 5.0 }
    
    func navigationBar(with id: String) -> XCUIElement {
        return navigationBars[id]
    }
    
    func button(with id: String) -> XCUIElement {
        return buttons[id]
    }
    
    func textField(with id: String) -> XCUIElement {
        return textFields[id]
    }
    
    func secureTextField(with id: String) -> XCUIElement {
        return secureTextFields[id]
    }
    
    func staticText(with id: String) -> XCUIElement{
        return staticTexts[id]
    }
    
    func alert(with id: String) -> XCUIElement{
        return alerts[id]
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
    
    func dialog(with id: String) -> XCUIElement {
        return switches[id]
    }
    
    func group(with id: String) -> XCUIElement {
        return groups[id]
    }
    
    func findElementWithPartialText(_ partialText: String, elementType: XCUIElementQuery) -> XCUIElement? {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", partialText)
        let element = elementType
        let matchingStaticTexts = element.matching(predicate)
        
        return matchingStaticTexts.firstMatch
    }
}
