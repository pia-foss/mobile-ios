//
//  Common.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 19/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

extension XCUIApplication{
    func moveFocus(to element: XCUIElement, startingDirection: XCUIRemote.Button = .right) {
        var direction: XCUIRemote.Button = startingDirection
        var navigationCycle = NavigationCycle(startingDirection: startingDirection)
        var cycle = 0
        var attempts = 0
        let maxAttempts = 20
        
        while !element.hasFocus && attempts < maxAttempts {
            XCUIRemote.shared.press(direction)
            usleep(100000)
            
            if element.hasFocus {
                break;
            }
            
            if endOfScreenReached(direction) {
                direction = navigationCycle.nextDirection(currentDirection: direction, cycle: cycle)
                // Check if cycle needs to reset based on the navigation cycle
                if direction == startingDirection {
                    cycle += 1
                }
            }
            attempts += 1
        }
        
        if attempts >= maxAttempts {
            print("Failed to focus on the element after \(maxAttempts) attempts.")
        }
    }
    
    func endOfScreenReached(_ direction: XCUIRemote.Button) -> Bool {
        let initialElements = windows.firstMatch.descendants(matching: .any)
        let initialCoordinates = initialElements.allElementsBoundByIndex.map { $0.frame.origin }
        
        XCUIRemote.shared.press(direction)
        usleep(100000)
        
        let finalElements = windows.firstMatch.descendants(matching: .any)
        let finalCoordinates = finalElements.allElementsBoundByIndex.map { $0.frame.origin }
        
        return initialCoordinates == finalCoordinates
    }
}

struct NavigationCycle {
    var currentCycle: [XCUIRemote.Button]
    var alternateCycle: [XCUIRemote.Button]
    
    init(startingDirection: XCUIRemote.Button) {
        switch startingDirection {
        case .right:
            currentCycle = [.right, .up, .left, .down]
            alternateCycle = [.right, .down, .left, .up]
        case .up:
            currentCycle = [.up, .right, .down, .left]
            alternateCycle = [.up, .left, .down, .right]
        case .down:
            currentCycle = [.down, .left, .up, .right]
            alternateCycle = [.down, .right, .up, .left]
        case .left:
            currentCycle = [.left, .up, .right, .down]
            alternateCycle = [.left, .down, .right, .up]
        default:
            currentCycle = [.right, .down, .left, .up]
            alternateCycle = [.right, .up, .left, .down]
        }
    }
    
    mutating func nextDirection(currentDirection: XCUIRemote.Button, cycle: Int) -> XCUIRemote.Button {
        let cycleArray = cycle % 2 == 0 ? currentCycle : alternateCycle
        if let currentIndex = cycleArray.firstIndex(of: currentDirection), cycleArray.indices.contains(currentIndex + 1) {
            return cycleArray[currentIndex + 1]
        } else {
            return cycleArray.first!
        }
    }
}
