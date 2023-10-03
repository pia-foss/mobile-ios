
import XCTest

protocol WelcomeScreenElementsProvider {
  var goToLoginScreenButton: XCUIElement { get }
}

// MARK: WelcomeScreenElementsProvider

extension XCUIApplication: WelcomeScreenElementsProvider {
  var goToLoginScreenButton: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submitNew)
  }
}


protocol LoginScreenElementsProvider {
  var loginButton: XCUIElement { get }
  var willDisplayLoginErrorBanner: Bool { get }
  var isDisplayingLoginErrorBanner: Bool { get }
}

// MARK: LoginScreenElementsProvider

extension XCUIApplication: LoginScreenElementsProvider {
  var loginButton: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submit)
  }
  
  var willDisplayLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).waitForExistence(timeout: shortTimeout)
  }
  
  var isDisplayingLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).exists
  }
  
  var willDisplayVpnPermissionScreen: Bool {
    view(with: AccessibilityId.VPNPermission.screen).waitForExistence(timeout: shortTimeout)
  }
}
