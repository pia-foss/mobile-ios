// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let centeredDarkMap = ImageAsset(name: "centered-dark-map")
  internal static let centeredLightMap = ImageAsset(name: "centered-light-map")
  internal static let computerIcon = ImageAsset(name: "computer-icon")
  internal static let globeIcon = ImageAsset(name: "globe-icon")
  internal static let iconBack = ImageAsset(name: "icon-back")
  internal static let iconCamera = ImageAsset(name: "icon-camera")
  internal static let iconClose = ImageAsset(name: "icon-close")
  internal static let iconWarning = ImageAsset(name: "icon-warning")
  internal static let pagecontrolSelectedDot = ImageAsset(name: "pagecontrol-selected-dot")
  internal static let pagecontrolUnselectedDot = ImageAsset(name: "pagecontrol-unselected-dot")
  internal static let planSelected = ImageAsset(name: "plan-selected")
  internal static let planUnselected = ImageAsset(name: "plan-unselected")
  internal static let scrollableMapDark = ImageAsset(name: "scrollableMap-dark")
  internal static let scrollableMapLight = ImageAsset(name: "scrollableMap-light")
  internal static let shieldIcon = ImageAsset(name: "shield-icon")
  internal static let closeIcon = ImageAsset(name: "close-icon")
  internal static let imageAccountFailed = ImageAsset(name: "image-account-failed")
  internal static let imageDocumentConsent = ImageAsset(name: "image-document-consent")
  internal static let imageNoInternet = ImageAsset(name: "image-no-internet")
  internal static let imagePurchaseSuccess = ImageAsset(name: "image-purchase-success")
  internal static let imageReceiptBackground = ImageAsset(name: "image-receipt-background")
  internal static let imageRedeemClaimed = ImageAsset(name: "image-redeem-claimed")
  internal static let imageRedeemInvalid = ImageAsset(name: "image-redeem-invalid")
  internal static let imageRedeemSuccess = ImageAsset(name: "image-redeem-success")
  internal static let imageWalkthrough1 = ImageAsset(name: "image-walkthrough-1")
  internal static let imageWalkthrough2 = ImageAsset(name: "image-walkthrough-2")
  internal static let imageWalkthrough3 = ImageAsset(name: "image-walkthrough-3")
  internal static let navLogo = ImageAsset(name: "nav-logo")
  internal static let qrCode = ImageAsset(name: "qr-code")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
