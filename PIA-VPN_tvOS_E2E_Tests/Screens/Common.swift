//
//  Common.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension  XCUIApplication{
    
    func moveFocus(to element: XCUIElement) {
         var direction: XCUIRemote.Button = .up // Start with a default direction
         
         while !element.hasFocus {
             if element.hasFocus {
                 return
             }
             
             if endOfScreenReached(direction) {
                 direction = nextDirection(direction)
             }
         }
     }
    
    func endOfScreenReached(_ direction: XCUIRemote.Button) -> Bool {
        let initialElements = windows.firstMatch.descendants(matching: .any)
        let initialCoordinates = initialElements.allElementsBoundByIndex.map { $0.frame.origin }

        XCUIRemote.shared.press(direction)
            
        let finalElements = windows.firstMatch.descendants(matching: .any)
        let finalCoordinates = finalElements.allElementsBoundByIndex.map { $0.frame.origin }
            
        return initialCoordinates == finalCoordinates
        }
    
    func nextDirection(_ currentDirection: XCUIRemote.Button) -> XCUIRemote.Button {
           switch currentDirection {
           case .up:
               return .right
           case .right:
               return .down
           case .down:
               return .left
           case .left:
               return .up
           default:
               return .up
           }
       }
     
}
