// swift-format-ignore-file
// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Cards {
    public enum WireGuard {
      public static let wgBackground = ImageAsset(name: "Cards/WireGuard/wg-background")
      public static let wgMain = ImageAsset(name: "Cards/WireGuard/wg-main")
    }
  }
  public enum Piax {
    public enum DarkMap {
      public static let darkMap = ImageAsset(name: "PIAX/DarkMap/Dark-Map")
    }
    public enum Dashboard {
      public static let vpnButton = ImageAsset(name: "PIAX/Dashboard/vpn-button")
    }
    public enum Global {
      public static let browserInactive = ImageAsset(name: "PIAX/Global/browser-inactive")
      public static let centeredMap = ImageAsset(name: "PIAX/Global/centered-map")
      public static let dragDropIndicator = ImageAsset(name: "PIAX/Global/drag-drop-indicator")
      public static let eyeActive = ImageAsset(name: "PIAX/Global/eye-active")
      public static let eyeInactive = ImageAsset(name: "PIAX/Global/eye-inactive")
      public static let favoriteGreen = ImageAsset(name: "PIAX/Global/favorite-green")
      public static let favoriteSelected = ImageAsset(name: "PIAX/Global/favorite-selected")
      public static let favoriteUnselected = ImageAsset(name: "PIAX/Global/favorite-unselected")
      public static let iconBack = ImageAsset(name: "PIAX/Global/icon-back")
      public static let iconCheck = ImageAsset(name: "PIAX/Global/icon-check")
      public static let iconCloseSmall = ImageAsset(name: "PIAX/Global/icon-close-small")
      public static let iconEditTile = ImageAsset(name: "PIAX/Global/icon-edit-tile")
      public static let iconFilter = ImageAsset(name: "PIAX/Global/icon-filter")
      public static let iconWarning = ImageAsset(name: "PIAX/Global/icon-warning")
      public static let killswitchActive = ImageAsset(name: "PIAX/Global/killswitch-active")
      public static let killswitchInactive = ImageAsset(name: "PIAX/Global/killswitch-inactive")
      public static let nmtActive = ImageAsset(name: "PIAX/Global/nmt-active")
      public static let nmtInactive = ImageAsset(name: "PIAX/Global/nmt-inactive")
      public static let planSelected = ImageAsset(name: "PIAX/Global/plan-selected")
      public static let planUnselected = ImageAsset(name: "PIAX/Global/plan-unselected")
      public static let regionSelected = ImageAsset(name: "PIAX/Global/region-selected")
      public static let scrollableMap = ImageAsset(name: "PIAX/Global/scrollableMap")
    }
    public enum Nmt {
      public static let iconAddRule = ImageAsset(name: "PIAX/NMT/icon-add-rule")
      public static let iconCustomWifiConnect = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-connect")
      public static let iconCustomWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-disconnect")
      public static let iconCustomWifiRetain = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-retain")
      public static let iconDisconnect = ImageAsset(name: "PIAX/NMT/icon-disconnect")
      public static let iconMobileDataConnect = ImageAsset(name: "PIAX/NMT/icon-mobile-data-connect")
      public static let iconMobileDataDisconnect = ImageAsset(name: "PIAX/NMT/icon-mobile-data-disconnect")
      public static let iconMobileDataRetain = ImageAsset(name: "PIAX/NMT/icon-mobile-data-retain")
      public static let iconNmtConnect = ImageAsset(name: "PIAX/NMT/icon-nmt-connect")
      public static let iconNmtWifi = ImageAsset(name: "PIAX/NMT/icon-nmt-wifi")
      public static let iconOpenWifiConnect = ImageAsset(name: "PIAX/NMT/icon-open-wifi-connect")
      public static let iconOpenWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-open-wifi-disconnect")
      public static let iconOpenWifiRetain = ImageAsset(name: "PIAX/NMT/icon-open-wifi-retain")
      public static let iconOptions = ImageAsset(name: "PIAX/NMT/icon-options")
      public static let iconRetain = ImageAsset(name: "PIAX/NMT/icon-retain")
      public static let iconSecureWifiConnect = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-connect")
      public static let iconSecureWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-disconnect")
      public static let iconSecureWifiRetain = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-retain")
    }
    public enum Regions {
      public static let noResults = ImageAsset(name: "PIAX/Regions/no-results")
    }
    public enum Settings {
      public static let iconAbout = ImageAsset(name: "PIAX/Settings/icon-about")
      public static let iconAutomation = ImageAsset(name: "PIAX/Settings/icon-automation")
      public static let iconGeneral = ImageAsset(name: "PIAX/Settings/icon-general")
      public static let iconNetwork = ImageAsset(name: "PIAX/Settings/icon-network")
      public static let iconPrivacy = ImageAsset(name: "PIAX/Settings/icon-privacy")
      public static let iconProtocols = ImageAsset(name: "PIAX/Settings/icon-protocols")
    }
    public enum Tiles {
      public enum ConnectionTile {
        public static let iconAuthentication = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-authentication")
        public static let iconEncryption = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-encryption")
        public static let iconHandshake = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-handshake")
        public static let iconPort = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-port")
        public static let iconProtocol = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-protocol")
        public static let iconSocket = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-socket")
      }
      public static let ipTriangle = ImageAsset(name: "PIAX/Tiles/ip-triangle")
      public static let openTileDetails = ImageAsset(name: "PIAX/Tiles/open-tile-details")
      public static let quickConnectPlaceholder = ImageAsset(name: "PIAX/Tiles/quick-connect-placeholder")
    }
  }
  public static let accessoryExpire = ImageAsset(name: "accessory-expire")
  public static let accessorySelected = ImageAsset(name: "accessory-selected")
  public static let buttonDown = ImageAsset(name: "button-down")
  public static let buttonUp = ImageAsset(name: "button-up")
  public static let dipBadge = ImageAsset(name: "dip-badge")
  public static let forceUpdateShield = ImageAsset(name: "force_update_shield")
  public static let icon3dtConnect = ImageAsset(name: "icon-3dt-connect")
  public static let icon3dtDisconnect = ImageAsset(name: "icon-3dt-disconnect")
  public static let icon3dtSelectRegion = ImageAsset(name: "icon-3dt-select-region")
  public static let iconAccount = ImageAsset(name: "icon-account")
  public static let iconAlert = ImageAsset(name: "icon-alert")
  public static let iconClose = ImageAsset(name: "icon-close")
  public static let iconContact = ImageAsset(name: "icon-contact")
  public static let iconDip = ImageAsset(name: "icon-dip")
  public static let iconGeoSelected = ImageAsset(name: "icon-geo-selected")
  public static let iconGeo = ImageAsset(name: "icon-geo")
  public static let iconHomepage = ImageAsset(name: "icon-homepage")
  public static let iconLogout = ImageAsset(name: "icon-logout")
  public static let iconRegion = ImageAsset(name: "icon-region")
  public static let iconSettings = ImageAsset(name: "icon-settings")
  public static let iconThumbsDown = ImageAsset(name: "icon-thumbs-down")
  public static let iconThumbsUp = ImageAsset(name: "icon-thumbs-up")
  public static let iconTrash = ImageAsset(name: "icon-trash")
  public static let iconWarning = ImageAsset(name: "icon-warning")
  public static let iconmenuAbout = ImageAsset(name: "iconmenu-about")
  public static let iconmenuPrivacy = ImageAsset(name: "iconmenu-privacy")
  public static let imageAccessCard = ImageAsset(name: "image-access-card")
  public static let imageAccountFailed = ImageAsset(name: "image-account-failed")
  public static let imageContentBlocker = ImageAsset(name: "image-content-blocker")
  public static let imageDocumentConsent = ImageAsset(name: "image-document-consent")
  public static let imageNoInternet = ImageAsset(name: "image-no-internet")
  public static let imagePurchaseSuccess = ImageAsset(name: "image-purchase-success")
  public static let imageRedeemClaimed = ImageAsset(name: "image-redeem-claimed")
  public static let imageRedeemInvalid = ImageAsset(name: "image-redeem-invalid")
  public static let imageRedeemSuccess = ImageAsset(name: "image-redeem-success")
  public static let imageRobot = ImageAsset(name: "image-robot")
  public static let imageVpnAllow = ImageAsset(name: "image-vpn-allow")
  public static let itemMenu = ImageAsset(name: "item-menu")
  public static let navLogo = ImageAsset(name: "nav-logo")
  public static let offlineServerIcon = ImageAsset(name: "offline-server-icon")
  public static let paywallHero = ImageAsset(name: "paywall-hero")
  public static let piaSpinner = ImageAsset(name: "pia-spinner")
  public static let welcomeBackHero = ImageAsset(name: "welcome-back-hero")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(watchOS 2.0, macOS 10.7, *)
  public var image: Image {
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
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
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

#if canImport(SwiftUI)
@available(watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
