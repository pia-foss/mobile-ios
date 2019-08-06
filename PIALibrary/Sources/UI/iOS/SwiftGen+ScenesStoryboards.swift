// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Signup: StoryboardType {
    internal static let storyboardName = "Signup"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Signup.self)
  }
  internal enum Welcome: StoryboardType {
    internal static let storyboardName = "Welcome"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Welcome.self)

    internal static let loginViewController = SceneType<PIALibrary.LoginViewController>(storyboard: Welcome.self, identifier: "LoginViewController")

    internal static let purchaseViewController = SceneType<PIALibrary.PurchaseViewController>(storyboard: Welcome.self, identifier: "PurchaseViewController")
    
    internal static let purchaseTrialViewController = SceneType<PIALibrary.PurchaseTrialViewController>(storyboard: Welcome.self, identifier: "PurchaseTrialViewController")

    internal static let redeemViewController = SceneType<PIALibrary.RedeemViewController>(storyboard: Welcome.self, identifier: "RedeemViewController")
    internal static let restoreViewController = SceneType<PIALibrary.RestoreSignupViewController>(storyboard: Welcome.self, identifier: "RestoreSignupViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
