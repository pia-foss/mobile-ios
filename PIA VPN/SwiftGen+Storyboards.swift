// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
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

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<UINavigationController>(storyboard: Main.self)

    internal static let vpnPermissionViewController = SceneType<PIA_VPN.VPNPermissionViewController>(storyboard: Main.self, identifier: "VPNPermissionViewController")
  }
}

internal enum StoryboardSegue {
  internal enum Main: String, SegueType {
    case aboutSegueIdentifier = "AboutSegueIdentifier"
    case accountSegueIdentifier = "AccountSegueIdentifier"
    case contentBlockerSegueIdentifier = "ContentBlockerSegueIdentifier"
    case menuSegueIdentifier = "MenuSegueIdentifier"
    case selectRegionAnimatedSegueIdentifier = "SelectRegionAnimatedSegueIdentifier"
    case selectRegionSegueIdentifier = "SelectRegionSegueIdentifier"
    case settingsSegueIdentifier = "SettingsSegueIdentifier"
    case unwindContentBlockerSegueIdentifier = "UnwindContentBlockerSegueIdentifier"
    case unwindRegionsSegueIdentifier = "UnwindRegionsSegueIdentifier"
    case unwindWalkthroughSegueIdentifier = "UnwindWalkthroughSegueIdentifier"
    case walkthroughSegueIdentifier = "WalkthroughSegueIdentifier"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
