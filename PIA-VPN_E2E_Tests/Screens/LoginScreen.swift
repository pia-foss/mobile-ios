
import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement {
        button(with: PIALibraryAccessibility.Id.Login.submit)
    }
  
    var loginUsernameTextField: XCUIElement {
        textField(with: PIALibraryAccessibility.Id.Login.username)
    }
    
    var loginPasswordTextField: XCUIElement {
        secureTextField(with: PIALibraryAccessibility.Id.Login.password)
    }
    
    var loginErrorMessage: XCUIElement {
        view(with: PIALibraryAccessibility.Id.Login.Error.banner)
    }
}
