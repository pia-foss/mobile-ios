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
}

