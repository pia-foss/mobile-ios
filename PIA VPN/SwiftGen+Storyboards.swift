// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: Main.self)

    static let vpnPermissionViewController = SceneType<PIA_VPN.VPNPermissionViewController>(storyboard: Main.self, identifier: "VPNPermissionViewController")
  }
}

enum StoryboardSegue {
  enum Main: String, SegueType {
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
