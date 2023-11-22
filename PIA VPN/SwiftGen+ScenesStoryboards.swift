// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import SideMenu
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:disable type_body_length type_name
internal enum StoryboardScene {
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Main.self)

    internal static let confirmVPNPlanViewController = SceneType<AddEmailToAccountViewController>(storyboard: Main.self, identifier: "ConfirmVPNPlanViewController")

    internal static let piaCardsViewController = SceneType<PIACardsViewController>(storyboard: Main.self, identifier: "PIACardsViewController")

    internal static let sideMenuNavigationController = SceneType<SideMenu.SideMenuNavigationController>(storyboard: Main.self, identifier: "SideMenuNavigationController")

    internal static let vpnPermissionViewController = SceneType<VPNPermissionViewController>(storyboard: Main.self, identifier: "VPNPermissionViewController")
  }
  internal enum Signup: StoryboardType {
    internal static let storyboardName = "Signup"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Signup.self)

    internal static let confirmVPNPlanViewController = SceneType<ConfirmVPNPlanViewController>(storyboard: Signup.self, identifier: "ConfirmVPNPlanViewController")

    internal static let gdprViewController = SceneType<GDPRViewController>(storyboard: Signup.self, identifier: "GDPRViewController")

    internal static let shareDataInformationViewController = SceneType<ShareDataInformationViewController>(storyboard: Signup.self, identifier: "ShareDataInformationViewController")

    internal static let signupSuccessViewController = SceneType<SignupSuccessViewController>(storyboard: Signup.self, identifier: "SignupSuccessViewController")
  }
  internal enum Welcome: StoryboardType {
    internal static let storyboardName = "Welcome"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Welcome.self)

    internal static let getStartedViewController = SceneType<GetStartedViewController>(storyboard: Welcome.self, identifier: "GetStartedViewController")

    internal static let loginViewController = SceneType<LoginViewController>(storyboard: Welcome.self, identifier: "LoginViewController")

    internal static let magicLinkLoginViewController = SceneType<MagicLinkLoginViewController>(storyboard: Welcome.self, identifier: "MagicLinkLoginViewController")

    internal static let piaWelcomeViewController = SceneType<PIAWelcomeViewController>(storyboard: Welcome.self, identifier: "PIAWelcomeViewController")

    internal static let purchaseViewController = SceneType<PurchaseViewController>(storyboard: Welcome.self, identifier: "PurchaseViewController")

    internal static let restoreSignupViewController = SceneType<RestoreSignupViewController>(storyboard: Welcome.self, identifier: "RestoreSignupViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:enable type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
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

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
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

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
