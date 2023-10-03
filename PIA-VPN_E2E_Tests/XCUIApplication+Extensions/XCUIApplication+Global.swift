
import XCTest

extension XCUIApplication {
    var defaultTimeout: TimeInterval { 10.0 }
    var shortTimeout: TimeInterval { 5.0 }
    
    func view(with id: String) -> XCUIElement {
        return otherElements[id]
    }
    
    func button(with id: String) -> XCUIElement {
        return buttons[id]
    }
    
    func textField(with id: String) -> XCUIElement {
        return textFields[id]
    }
    
    func cell(with id: String) -> XCUIElement {
        return cells[id]
    }
    
    func secureTextField(with id: String) -> XCUIElement {
        return secureTextFields[id]
    }
}


extension XCUIApplication {
    // Logs out from the Dashboard screen
    // If the app is showing other view, then this flow does not work
    func logOutIfNeeded() {
        let menuButton =  navigationBars.buttons[PIALibraryAccessibility.Id.Dashboard.menu]
        
        guard menuButton.exists else { return }
        
        menuButton.tap()
        
        let logOutButton = cell(with: PIALibraryAccessibility.Id.Menu.logout)
        
        if logOutButton.waitForExistence(timeout: shortTimeout) {
            logOutButton.tap()
            
            let confirmationDialogButton = button(with: PIALibraryAccessibility.Id.Dialog.destructive)
            
            if confirmationDialogButton.waitForExistence(timeout: shortTimeout) {
                confirmationDialogButton.tap()
            }
        }
    }
}
