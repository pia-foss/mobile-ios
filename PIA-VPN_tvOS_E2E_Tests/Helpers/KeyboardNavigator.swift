//
//  KeyboardNavigator.swift
//  PIA-VPN_tvOS_E2E_Tests
//
//  Created by Geneva Parayno on 22/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import XCTest

enum KeyboardState {
    case uppercase
    case lowercase
    case punctuation
}

struct TargetInfo {
    var row: Int
    var column: Int
    var state: KeyboardState
}

class KeyboardNavigator {
    var currentState: KeyboardState = .lowercase
    var currentRow: Int = 0
    var currentPosition: Int = 0

    func navigateToCharacter(_ character: Character) {
        let targetInfo = determineTarget(character: character)

        // Toggle state if needed
        if currentState != targetInfo.state {
            toggleState(targetState: targetInfo.state, currentState: &currentState, currentRow: &currentRow, currentPosition: &currentPosition)
        }

        // Navigate to the correct row if needed
        if currentRow != targetInfo.row {
            navigateToRow(targetRow: targetInfo.row, currentRow: &currentRow)
            if(currentRow==0) {
                moveToFirstPositionInAlphabetRow()
            }
            else if (currentRow==1) {
                moveToFirstPositionInNumericsRow()
            }
            else {
                moveToFirstPositionStateRow()
            }
            currentPosition=0
        }

        // Navigate within the row to the correct position
        navigateWithinRow(targetPosition: targetInfo.column, currentPosition: &currentPosition)
        XCUIRemote.shared.press(.select)
    }
    
    func determineTarget(character: Character) -> TargetInfo {
        let strChar = String(character).lowercased()
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let numerics = "1234567890.-_!@#$%^&*"

        if alphabet.contains(strChar) {
            let column: Int
            if let index = alphabet.firstIndex(of: Character(strChar)) {
                column = alphabet.distance(from: alphabet.startIndex, to: index)
            } else {
                column = 0
            }
            let state: KeyboardState = character.isUppercase ? .uppercase : .lowercase
            return TargetInfo(row: 0, column: column, state: state)
        }
        else if numerics.contains(strChar) {
            let column: Int
            if let index = numerics.firstIndex(of: character) {
                column = numerics.distance(from: numerics.startIndex, to: index)
            } else {
                column = 0
            }
            return TargetInfo(row: 1, column: column, state: currentState)
        }
        else {
            let symbols = "`'\";:~=+,?|/\\()[]{}<>"
            let column: Int
            if let index = symbols.firstIndex(of: character) {
                column = symbols.distance(from: symbols.startIndex, to: index)
            } else {
                column = 0
            }
            return TargetInfo(row: 0, column: column, state: .punctuation)
        }
       }
    
    
    func navigateToRow(targetRow: Int, currentRow: inout Int) {
        let difference = targetRow - currentRow
        if difference > 0 {
            // If difference is positive, move down
            for _ in 0..<difference {
                XCUIRemote.shared.press(.down)
            }
        } else if difference < 0 {
            // If difference is negative, move up
            for _ in 0..<abs(difference) {
                XCUIRemote.shared.press(.up)
            }
        }
        currentRow = targetRow
    }
    
    func navigateWithinRow(targetPosition: Int, currentPosition: inout Int) {
        let difference = targetPosition - currentPosition
        if difference > 0 {
            // If difference is positive, move right
            for _ in 0..<difference {
                XCUIRemote.shared.press(.right)
            }
        } else if difference < 0 {
            // If difference is positive, move left
            for _ in 0..<abs(difference) {
                XCUIRemote.shared.press(.left)
            }
        }
        currentPosition = targetPosition
    }
    
    func toggleState(targetState: KeyboardState, currentState: inout KeyboardState, currentRow: inout Int, currentPosition: inout Int) {
        if currentRow != 2 {
            navigateToRow(targetRow: 2, currentRow: &currentRow)
            moveToFirstPositionStateRow()
            currentPosition=0
        }
        
        let targetButtonPosition: Int
        switch targetState {
        case .uppercase:
            targetButtonPosition = 0
        case .lowercase:
            targetButtonPosition = 1
        case .punctuation:
            targetButtonPosition = 2
        }
        
        navigateWithinRow(targetPosition: targetButtonPosition, currentPosition: &currentPosition)
        XCUIRemote.shared.press(.select)
        currentState = targetState
    }
    
    func typeText(_ text: String) {
        for character in text {
            navigateToCharacter(character)
        }
    }
    
    func resetKeyboardPosition() {
        if !(currentRow == 0) {
            navigateToRow(targetRow: 0, currentRow: &currentRow)
        }
        moveToFirstPositionInAlphabetRow()
    }
    
    func moveToFirstPositionInAlphabetRow() {
        for _ in 1...27 {
            XCUIRemote.shared.press(.left)
        }
        XCUIRemote.shared.press(.right)
    }
    
    func moveToFirstPositionInNumericsRow() {
        for _ in 1...22 {
            XCUIRemote.shared.press(.left)
        }
    }
    
    func moveToFirstPositionStateRow() {
        for _ in 1...3 {
            XCUIRemote.shared.press(.left)
        }
    }
    
    func clickNext() {
        let targetInfo = TargetInfo(row: 3, column: 0, state: currentState)
        if currentRow != targetInfo.row {
            navigateToRow(targetRow: targetInfo.row, currentRow: &currentRow)
        }
        XCUIRemote.shared.press(.select)
        currentRow=0
        moveToFirstPositionInAlphabetRow()
    }
}
