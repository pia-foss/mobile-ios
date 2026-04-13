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
  public static let connectInnerButton = ImageAsset(name: "connect-inner-button")
  public static let helpBgImage = ImageAsset(name: "help-bg-image")
  public static let configureRobots = ImageAsset(name: "configure-robots")
  public static let piaBrand = ImageAsset(name: "pia-brand")
  public static let signinWorld = ImageAsset(name: "signin-world")
  public static let signupCredentials = ImageAsset(name: "signup-credentials")
  public static let signupScreen = ImageAsset(name: "signup-screen")
  public static let statsTv = ImageAsset(name: "stats-tv")
  public static let emptySearchBgImage = ImageAsset(name: "empty-search-bg-image")
  public static let iconDipLocation = ImageAsset(name: "icon-dip-location")
  public static let iconSmartLocationHighlighted = ImageAsset(name: "icon-smart-location-highlighted")
  public static let iconSmartLocation = ImageAsset(name: "icon-smart-location")
  public static let settingsBgImage = ImageAsset(name: "settings-bg-image")
  public static let loadingPiaBrand = ImageAsset(name: "loading-pia-brand")
  public static let setupScreen = ImageAsset(name: "setup-screen")
  public static let favoriteFilledIcon = ImageAsset(name: "favorite-filled-icon")
  public static let favoriteStrokeIcon = ImageAsset(name: "favorite-stroke-icon")
  public static let flagAd = ImageAsset(name: "flag-ad")
  public static let flagAe = ImageAsset(name: "flag-ae")
  public static let flagAf = ImageAsset(name: "flag-af")
  public static let flagAg = ImageAsset(name: "flag-ag")
  public static let flagAi = ImageAsset(name: "flag-ai")
  public static let flagAl = ImageAsset(name: "flag-al")
  public static let flagAm = ImageAsset(name: "flag-am")
  public static let flagAo = ImageAsset(name: "flag-ao")
  public static let flagAr = ImageAsset(name: "flag-ar")
  public static let flagAs = ImageAsset(name: "flag-as")
  public static let flagAt = ImageAsset(name: "flag-at")
  public static let flagAu = ImageAsset(name: "flag-au")
  public static let flagAw = ImageAsset(name: "flag-aw")
  public static let flagAx = ImageAsset(name: "flag-ax")
  public static let flagAz = ImageAsset(name: "flag-az")
  public static let flagBa = ImageAsset(name: "flag-ba")
  public static let flagBb = ImageAsset(name: "flag-bb")
  public static let flagBd = ImageAsset(name: "flag-bd")
  public static let flagBe = ImageAsset(name: "flag-be")
  public static let flagBf = ImageAsset(name: "flag-bf")
  public static let flagBg = ImageAsset(name: "flag-bg")
  public static let flagBh = ImageAsset(name: "flag-bh")
  public static let flagBi = ImageAsset(name: "flag-bi")
  public static let flagBj = ImageAsset(name: "flag-bj")
  public static let flagBm = ImageAsset(name: "flag-bm")
  public static let flagBn = ImageAsset(name: "flag-bn")
  public static let flagBo = ImageAsset(name: "flag-bo")
  public static let flagBr = ImageAsset(name: "flag-br")
  public static let flagBs = ImageAsset(name: "flag-bs")
  public static let flagBt = ImageAsset(name: "flag-bt")
  public static let flagBw = ImageAsset(name: "flag-bw")
  public static let flagBy = ImageAsset(name: "flag-by")
  public static let flagBz = ImageAsset(name: "flag-bz")
  public static let flagCa = ImageAsset(name: "flag-ca")
  public static let flagCc = ImageAsset(name: "flag-cc")
  public static let flagCd = ImageAsset(name: "flag-cd")
  public static let flagCf = ImageAsset(name: "flag-cf")
  public static let flagCg = ImageAsset(name: "flag-cg")
  public static let flagCh = ImageAsset(name: "flag-ch")
  public static let flagCi = ImageAsset(name: "flag-ci")
  public static let flagCk = ImageAsset(name: "flag-ck")
  public static let flagCl = ImageAsset(name: "flag-cl")
  public static let flagCm = ImageAsset(name: "flag-cm")
  public static let flagCn = ImageAsset(name: "flag-cn")
  public static let flagCo = ImageAsset(name: "flag-co")
  public static let flagCr = ImageAsset(name: "flag-cr")
  public static let flagCu = ImageAsset(name: "flag-cu")
  public static let flagCv = ImageAsset(name: "flag-cv")
  public static let flagCw = ImageAsset(name: "flag-cw")
  public static let flagCx = ImageAsset(name: "flag-cx")
  public static let flagCy = ImageAsset(name: "flag-cy")
  public static let flagCz = ImageAsset(name: "flag-cz")
  public static let flagDe = ImageAsset(name: "flag-de")
  public static let flagDj = ImageAsset(name: "flag-dj")
  public static let flagDk = ImageAsset(name: "flag-dk")
  public static let flagDm = ImageAsset(name: "flag-dm")
  public static let flagDo = ImageAsset(name: "flag-do")
  public static let flagDz = ImageAsset(name: "flag-dz")
  public static let flagEc = ImageAsset(name: "flag-ec")
  public static let flagEe = ImageAsset(name: "flag-ee")
  public static let flagEg = ImageAsset(name: "flag-eg")
  public static let flagEh = ImageAsset(name: "flag-eh")
  public static let flagEr = ImageAsset(name: "flag-er")
  public static let flagEs = ImageAsset(name: "flag-es")
  public static let flagEt = ImageAsset(name: "flag-et")
  public static let flagEu = ImageAsset(name: "flag-eu")
  public static let flagFi = ImageAsset(name: "flag-fi")
  public static let flagFj = ImageAsset(name: "flag-fj")
  public static let flagFk = ImageAsset(name: "flag-fk")
  public static let flagFm = ImageAsset(name: "flag-fm")
  public static let flagFo = ImageAsset(name: "flag-fo")
  public static let flagFr = ImageAsset(name: "flag-fr")
  public static let flagGa = ImageAsset(name: "flag-ga")
  public static let flagGbEng = ImageAsset(name: "flag-gb-eng")
  public static let flagGbSct = ImageAsset(name: "flag-gb-sct")
  public static let flagGbWls = ImageAsset(name: "flag-gb-wls")
  public static let flagGb = ImageAsset(name: "flag-gb")
  public static let flagGd = ImageAsset(name: "flag-gd")
  public static let flagGe = ImageAsset(name: "flag-ge")
  public static let flagGg = ImageAsset(name: "flag-gg")
  public static let flagGh = ImageAsset(name: "flag-gh")
  public static let flagGi = ImageAsset(name: "flag-gi")
  public static let flagGl = ImageAsset(name: "flag-gl")
  public static let flagGm = ImageAsset(name: "flag-gm")
  public static let flagGn = ImageAsset(name: "flag-gn")
  public static let flagGq = ImageAsset(name: "flag-gq")
  public static let flagGr = ImageAsset(name: "flag-gr")
  public static let flagGt = ImageAsset(name: "flag-gt")
  public static let flagGu = ImageAsset(name: "flag-gu")
  public static let flagGw = ImageAsset(name: "flag-gw")
  public static let flagGy = ImageAsset(name: "flag-gy")
  public static let flagHk = ImageAsset(name: "flag-hk")
  public static let flagHn = ImageAsset(name: "flag-hn")
  public static let flagHr = ImageAsset(name: "flag-hr")
  public static let flagHt = ImageAsset(name: "flag-ht")
  public static let flagHu = ImageAsset(name: "flag-hu")
  public static let flagId = ImageAsset(name: "flag-id")
  public static let flagIe = ImageAsset(name: "flag-ie")
  public static let flagIl = ImageAsset(name: "flag-il")
  public static let flagIm = ImageAsset(name: "flag-im")
  public static let flagIn = ImageAsset(name: "flag-in")
  public static let flagIo = ImageAsset(name: "flag-io")
  public static let flagIq = ImageAsset(name: "flag-iq")
  public static let flagIr = ImageAsset(name: "flag-ir")
  public static let flagIs = ImageAsset(name: "flag-is")
  public static let flagIt = ImageAsset(name: "flag-it")
  public static let flagJe = ImageAsset(name: "flag-je")
  public static let flagJm = ImageAsset(name: "flag-jm")
  public static let flagJo = ImageAsset(name: "flag-jo")
  public static let flagJp = ImageAsset(name: "flag-jp")
  public static let flagKe = ImageAsset(name: "flag-ke")
  public static let flagKg = ImageAsset(name: "flag-kg")
  public static let flagKh = ImageAsset(name: "flag-kh")
  public static let flagKi = ImageAsset(name: "flag-ki")
  public static let flagKm = ImageAsset(name: "flag-km")
  public static let flagKn = ImageAsset(name: "flag-kn")
  public static let flagKp = ImageAsset(name: "flag-kp")
  public static let flagKr = ImageAsset(name: "flag-kr")
  public static let flagKw = ImageAsset(name: "flag-kw")
  public static let flagKy = ImageAsset(name: "flag-ky")
  public static let flagKz = ImageAsset(name: "flag-kz")
  public static let flagLa = ImageAsset(name: "flag-la")
  public static let flagLb = ImageAsset(name: "flag-lb")
  public static let flagLc = ImageAsset(name: "flag-lc")
  public static let flagLi = ImageAsset(name: "flag-li")
  public static let flagLk = ImageAsset(name: "flag-lk")
  public static let flagLr = ImageAsset(name: "flag-lr")
  public static let flagLs = ImageAsset(name: "flag-ls")
  public static let flagLt = ImageAsset(name: "flag-lt")
  public static let flagLu = ImageAsset(name: "flag-lu")
  public static let flagLv = ImageAsset(name: "flag-lv")
  public static let flagLy = ImageAsset(name: "flag-ly")
  public static let flagMa = ImageAsset(name: "flag-ma")
  public static let flagMc = ImageAsset(name: "flag-mc")
  public static let flagMd = ImageAsset(name: "flag-md")
  public static let flagMe = ImageAsset(name: "flag-me")
  public static let flagMg = ImageAsset(name: "flag-mg")
  public static let flagMh = ImageAsset(name: "flag-mh")
  public static let flagMk = ImageAsset(name: "flag-mk")
  public static let flagMl = ImageAsset(name: "flag-ml")
  public static let flagMm = ImageAsset(name: "flag-mm")
  public static let flagMn = ImageAsset(name: "flag-mn")
  public static let flagMo = ImageAsset(name: "flag-mo")
  public static let flagMp = ImageAsset(name: "flag-mp")
  public static let flagMq = ImageAsset(name: "flag-mq")
  public static let flagMr = ImageAsset(name: "flag-mr")
  public static let flagMs = ImageAsset(name: "flag-ms")
  public static let flagMt = ImageAsset(name: "flag-mt")
  public static let flagMu = ImageAsset(name: "flag-mu")
  public static let flagMv = ImageAsset(name: "flag-mv")
  public static let flagMw = ImageAsset(name: "flag-mw")
  public static let flagMx = ImageAsset(name: "flag-mx")
  public static let flagMy = ImageAsset(name: "flag-my")
  public static let flagMz = ImageAsset(name: "flag-mz")
  public static let flagNa = ImageAsset(name: "flag-na")
  public static let flagNe = ImageAsset(name: "flag-ne")
  public static let flagNf = ImageAsset(name: "flag-nf")
  public static let flagNg = ImageAsset(name: "flag-ng")
  public static let flagNi = ImageAsset(name: "flag-ni")
  public static let flagNl = ImageAsset(name: "flag-nl")
  public static let flagNo = ImageAsset(name: "flag-no")
  public static let flagNp = ImageAsset(name: "flag-np")
  public static let flagNr = ImageAsset(name: "flag-nr")
  public static let flagNz = ImageAsset(name: "flag-nz")
  public static let flagOm = ImageAsset(name: "flag-om")
  public static let flagPa = ImageAsset(name: "flag-pa")
  public static let flagPe = ImageAsset(name: "flag-pe")
  public static let flagPf = ImageAsset(name: "flag-pf")
  public static let flagPg = ImageAsset(name: "flag-pg")
  public static let flagPh = ImageAsset(name: "flag-ph")
  public static let flagPk = ImageAsset(name: "flag-pk")
  public static let flagPl = ImageAsset(name: "flag-pl")
  public static let flagPn = ImageAsset(name: "flag-pn")
  public static let flagPr = ImageAsset(name: "flag-pr")
  public static let flagPs = ImageAsset(name: "flag-ps")
  public static let flagPt = ImageAsset(name: "flag-pt")
  public static let flagPw = ImageAsset(name: "flag-pw")
  public static let flagPy = ImageAsset(name: "flag-py")
  public static let flagQa = ImageAsset(name: "flag-qa")
  public static let flagRo = ImageAsset(name: "flag-ro")
  public static let flagRs = ImageAsset(name: "flag-rs")
  public static let flagRu = ImageAsset(name: "flag-ru")
  public static let flagRw = ImageAsset(name: "flag-rw")
  public static let flagSa = ImageAsset(name: "flag-sa")
  public static let flagSb = ImageAsset(name: "flag-sb")
  public static let flagSc = ImageAsset(name: "flag-sc")
  public static let flagSd = ImageAsset(name: "flag-sd")
  public static let flagSe = ImageAsset(name: "flag-se")
  public static let flagSg = ImageAsset(name: "flag-sg")
  public static let flagSi = ImageAsset(name: "flag-si")
  public static let flagSk = ImageAsset(name: "flag-sk")
  public static let flagSl = ImageAsset(name: "flag-sl")
  public static let flagSm = ImageAsset(name: "flag-sm")
  public static let flagSn = ImageAsset(name: "flag-sn")
  public static let flagSo = ImageAsset(name: "flag-so")
  public static let flagSr = ImageAsset(name: "flag-sr")
  public static let flagSs = ImageAsset(name: "flag-ss")
  public static let flagSt = ImageAsset(name: "flag-st")
  public static let flagSv = ImageAsset(name: "flag-sv")
  public static let flagSx = ImageAsset(name: "flag-sx")
  public static let flagSy = ImageAsset(name: "flag-sy")
  public static let flagSz = ImageAsset(name: "flag-sz")
  public static let flagTc = ImageAsset(name: "flag-tc")
  public static let flagTd = ImageAsset(name: "flag-td")
  public static let flagTg = ImageAsset(name: "flag-tg")
  public static let flagTh = ImageAsset(name: "flag-th")
  public static let flagTj = ImageAsset(name: "flag-tj")
  public static let flagTk = ImageAsset(name: "flag-tk")
  public static let flagTm = ImageAsset(name: "flag-tm")
  public static let flagTn = ImageAsset(name: "flag-tn")
  public static let flagTo = ImageAsset(name: "flag-to")
  public static let flagTr = ImageAsset(name: "flag-tr")
  public static let flagTt = ImageAsset(name: "flag-tt")
  public static let flagTv = ImageAsset(name: "flag-tv")
  public static let flagTw = ImageAsset(name: "flag-tw")
  public static let flagTz = ImageAsset(name: "flag-tz")
  public static let flagUa = ImageAsset(name: "flag-ua")
  public static let flagUg = ImageAsset(name: "flag-ug")
  public static let flagUn = ImageAsset(name: "flag-un")
  public static let flagUs = ImageAsset(name: "flag-us")
  public static let flagUy = ImageAsset(name: "flag-uy")
  public static let flagUz = ImageAsset(name: "flag-uz")
  public static let flagVa = ImageAsset(name: "flag-va")
  public static let flagVc = ImageAsset(name: "flag-vc")
  public static let flagVe = ImageAsset(name: "flag-ve")
  public static let flagVg = ImageAsset(name: "flag-vg")
  public static let flagVn = ImageAsset(name: "flag-vn")
  public static let flagVu = ImageAsset(name: "flag-vu")
  public static let flagYe = ImageAsset(name: "flag-ye")
  public static let flagZa = ImageAsset(name: "flag-za")
  public static let flagZm = ImageAsset(name: "flag-zm")
  public static let flagZw = ImageAsset(name: "flag-zw")
  public static let termsAndConditions = ImageAsset(name: "terms-and-conditions")
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
