// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate(set) var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  enum Piax {
    enum Dashboard {
      static let vpnButton = ImageAsset(name: "vpn-button")
    }
    enum Global {
      static let favoriteGreen = ImageAsset(name: "favorite-green")
      static let favoriteSelected = ImageAsset(name: "favorite-selected")
      static let favoriteUnselectedDark = ImageAsset(name: "favorite-unselected-dark")
      static let favoriteUnselected = ImageAsset(name: "favorite-unselected")
      static let iconBack = ImageAsset(name: "icon-back")
      static let iconFilter = ImageAsset(name: "icon-filter")
      static let pagecontrolSelectedDot = ImageAsset(name: "pagecontrol-selected-dot")
      static let pagecontrolUnselectedDot = ImageAsset(name: "pagecontrol-unselected-dot")
      static let regionSelected = ImageAsset(name: "region-selected")
      static let scrollableMapDark = ImageAsset(name: "scrollableMap-dark")
      static let scrollableMapLight = ImageAsset(name: "scrollableMap-light")
    }
    enum Regions {
      static let noResultsDark = ImageAsset(name: "no-results-dark")
      static let noResultsLight = ImageAsset(name: "no-results-light")
    }
    enum Splash {
      static let darkSplash = ImageAsset(name: "dark-splash")
      static let lightSplash = ImageAsset(name: "light-splash")
    }
    enum Tiles {
      static let ipTriangle = ImageAsset(name: "ip-triangle")
    }
  }
  static let accessoryExpire = ImageAsset(name: "accessory-expire")
  static let accessorySelected = ImageAsset(name: "accessory-selected")
  static let buttonBackgroundToggleConnected = ImageAsset(name: "button-background-toggle-connected")
  static let buttonBackgroundToggleConnecting = ImageAsset(name: "button-background-toggle-connecting")
  static let buttonBackgroundToggleDisconnected = ImageAsset(name: "button-background-toggle-disconnected")
  static let buttonDown = ImageAsset(name: "button-down")
  static let buttonToggleConnected = ImageAsset(name: "button-toggle-connected")
  static let buttonToggleConnecting = ImageAsset(name: "button-toggle-connecting")
  static let buttonToggleDisconnected = ImageAsset(name: "button-toggle-disconnected")
  static let buttonUp = ImageAsset(name: "button-up")
  enum Flags {
    static let flagAd = ImageAsset(name: "flag-ad")
    static let flagAe = ImageAsset(name: "flag-ae")
    static let flagAf = ImageAsset(name: "flag-af")
    static let flagAg = ImageAsset(name: "flag-ag")
    static let flagAi = ImageAsset(name: "flag-ai")
    static let flagAl = ImageAsset(name: "flag-al")
    static let flagAm = ImageAsset(name: "flag-am")
    static let flagAn = ImageAsset(name: "flag-an")
    static let flagAo = ImageAsset(name: "flag-ao")
    static let flagAq = ImageAsset(name: "flag-aq")
    static let flagAr = ImageAsset(name: "flag-ar")
    static let flagAs = ImageAsset(name: "flag-as")
    static let flagAt = ImageAsset(name: "flag-at")
    static let flagAu = ImageAsset(name: "flag-au")
    static let flagAw = ImageAsset(name: "flag-aw")
    static let flagAz = ImageAsset(name: "flag-az")
    static let flagBa = ImageAsset(name: "flag-ba")
    static let flagBb = ImageAsset(name: "flag-bb")
    static let flagBd = ImageAsset(name: "flag-bd")
    static let flagBe = ImageAsset(name: "flag-be")
    static let flagBf = ImageAsset(name: "flag-bf")
    static let flagBg = ImageAsset(name: "flag-bg")
    static let flagBh = ImageAsset(name: "flag-bh")
    static let flagBi = ImageAsset(name: "flag-bi")
    static let flagBj = ImageAsset(name: "flag-bj")
    static let flagBm = ImageAsset(name: "flag-bm")
    static let flagBn = ImageAsset(name: "flag-bn")
    static let flagBo = ImageAsset(name: "flag-bo")
    static let flagBr = ImageAsset(name: "flag-br")
    static let flagBs = ImageAsset(name: "flag-bs")
    static let flagBt = ImageAsset(name: "flag-bt")
    static let flagBw = ImageAsset(name: "flag-bw")
    static let flagBy = ImageAsset(name: "flag-by")
    static let flagBz = ImageAsset(name: "flag-bz")
    static let flagCa = ImageAsset(name: "flag-ca")
    static let flagCf = ImageAsset(name: "flag-cf")
    static let flagCg = ImageAsset(name: "flag-cg")
    static let flagCh = ImageAsset(name: "flag-ch")
    static let flagCi = ImageAsset(name: "flag-ci")
    static let flagCk = ImageAsset(name: "flag-ck")
    static let flagCl = ImageAsset(name: "flag-cl")
    static let flagCm = ImageAsset(name: "flag-cm")
    static let flagCn = ImageAsset(name: "flag-cn")
    static let flagCo = ImageAsset(name: "flag-co")
    static let flagCr = ImageAsset(name: "flag-cr")
    static let flagCu = ImageAsset(name: "flag-cu")
    static let flagCv = ImageAsset(name: "flag-cv")
    static let flagCx = ImageAsset(name: "flag-cx")
    static let flagCy = ImageAsset(name: "flag-cy")
    static let flagCz = ImageAsset(name: "flag-cz")
    static let flagDe = ImageAsset(name: "flag-de")
    static let flagDj = ImageAsset(name: "flag-dj")
    static let flagDk = ImageAsset(name: "flag-dk")
    static let flagDm = ImageAsset(name: "flag-dm")
    static let flagDo = ImageAsset(name: "flag-do")
    static let flagDz = ImageAsset(name: "flag-dz")
    static let flagEc = ImageAsset(name: "flag-ec")
    static let flagEe = ImageAsset(name: "flag-ee")
    static let flagEg = ImageAsset(name: "flag-eg")
    static let flagEh = ImageAsset(name: "flag-eh")
    static let flagEr = ImageAsset(name: "flag-er")
    static let flagEs = ImageAsset(name: "flag-es")
    static let flagEt = ImageAsset(name: "flag-et")
    static let flagFi = ImageAsset(name: "flag-fi")
    static let flagFj = ImageAsset(name: "flag-fj")
    static let flagFm = ImageAsset(name: "flag-fm")
    static let flagFo = ImageAsset(name: "flag-fo")
    static let flagFr = ImageAsset(name: "flag-fr")
    static let flagGa = ImageAsset(name: "flag-ga")
    static let flagGb = ImageAsset(name: "flag-gb")
    static let flagGd = ImageAsset(name: "flag-gd")
    static let flagGe = ImageAsset(name: "flag-ge")
    static let flagGh = ImageAsset(name: "flag-gh")
    static let flagGi = ImageAsset(name: "flag-gi")
    static let flagGl = ImageAsset(name: "flag-gl")
    static let flagGm = ImageAsset(name: "flag-gm")
    static let flagGn = ImageAsset(name: "flag-gn")
    static let flagGr = ImageAsset(name: "flag-gr")
    static let flagGs = ImageAsset(name: "flag-gs")
    static let flagGu = ImageAsset(name: "flag-gu")
    static let flagGw = ImageAsset(name: "flag-gw")
    static let flagGy = ImageAsset(name: "flag-gy")
    static let flagHk = ImageAsset(name: "flag-hk")
    static let flagId = ImageAsset(name: "flag-id")
    static let flagIe = ImageAsset(name: "flag-ie")
    static let flagIl = ImageAsset(name: "flag-il")
    static let flagIn = ImageAsset(name: "flag-in")
    static let flagIo = ImageAsset(name: "flag-io")
    static let flagIq = ImageAsset(name: "flag-iq")
    static let flagIr = ImageAsset(name: "flag-ir")
    static let flagIs = ImageAsset(name: "flag-is")
    static let flagIt = ImageAsset(name: "flag-it")
    static let flagJm = ImageAsset(name: "flag-jm")
    static let flagJo = ImageAsset(name: "flag-jo")
    static let flagJp = ImageAsset(name: "flag-jp")
    static let flagKe = ImageAsset(name: "flag-ke")
    static let flagKg = ImageAsset(name: "flag-kg")
    static let flagKh = ImageAsset(name: "flag-kh")
    static let flagKi = ImageAsset(name: "flag-ki")
    static let flagKm = ImageAsset(name: "flag-km")
    static let flagKn = ImageAsset(name: "flag-kn")
    static let flagKp = ImageAsset(name: "flag-kp")
    static let flagKr = ImageAsset(name: "flag-kr")
    static let flagKw = ImageAsset(name: "flag-kw")
    static let flagKy = ImageAsset(name: "flag-ky")
    static let flagKz = ImageAsset(name: "flag-kz")
    static let flagLb = ImageAsset(name: "flag-lb")
    static let flagLc = ImageAsset(name: "flag-lc")
    static let flagLi = ImageAsset(name: "flag-li")
    static let flagLk = ImageAsset(name: "flag-lk")
    static let flagLr = ImageAsset(name: "flag-lr")
    static let flagLs = ImageAsset(name: "flag-ls")
    static let flagLt = ImageAsset(name: "flag-lt")
    static let flagLu = ImageAsset(name: "flag-lu")
    static let flagLv = ImageAsset(name: "flag-lv")
    static let flagMa = ImageAsset(name: "flag-ma")
    static let flagMc = ImageAsset(name: "flag-mc")
    static let flagMd = ImageAsset(name: "flag-md")
    static let flagMg = ImageAsset(name: "flag-mg")
    static let flagMh = ImageAsset(name: "flag-mh")
    static let flagMl = ImageAsset(name: "flag-ml")
    static let flagMm = ImageAsset(name: "flag-mm")
    static let flagMn = ImageAsset(name: "flag-mn")
    static let flagMo = ImageAsset(name: "flag-mo")
    static let flagMp = ImageAsset(name: "flag-mp")
    static let flagMr = ImageAsset(name: "flag-mr")
    static let flagMs = ImageAsset(name: "flag-ms")
    static let flagMt = ImageAsset(name: "flag-mt")
    static let flagMu = ImageAsset(name: "flag-mu")
    static let flagMv = ImageAsset(name: "flag-mv")
    static let flagMw = ImageAsset(name: "flag-mw")
    static let flagMx = ImageAsset(name: "flag-mx")
    static let flagMy = ImageAsset(name: "flag-my")
    static let flagMz = ImageAsset(name: "flag-mz")
    static let flagNa = ImageAsset(name: "flag-na")
    static let flagNe = ImageAsset(name: "flag-ne")
    static let flagNf = ImageAsset(name: "flag-nf")
    static let flagNg = ImageAsset(name: "flag-ng")
    static let flagNi = ImageAsset(name: "flag-ni")
    static let flagNl = ImageAsset(name: "flag-nl")
    static let flagNo = ImageAsset(name: "flag-no")
    static let flagNp = ImageAsset(name: "flag-np")
    static let flagNr = ImageAsset(name: "flag-nr")
    static let flagNu = ImageAsset(name: "flag-nu")
    static let flagNz = ImageAsset(name: "flag-nz")
    static let flagOm = ImageAsset(name: "flag-om")
    static let flagPa = ImageAsset(name: "flag-pa")
    static let flagPe = ImageAsset(name: "flag-pe")
    static let flagPf = ImageAsset(name: "flag-pf")
    static let flagPg = ImageAsset(name: "flag-pg")
    static let flagPh = ImageAsset(name: "flag-ph")
    static let flagPk = ImageAsset(name: "flag-pk")
    static let flagPm = ImageAsset(name: "flag-pm")
    static let flagPn = ImageAsset(name: "flag-pn")
    static let flagPr = ImageAsset(name: "flag-pr")
    static let flagPt = ImageAsset(name: "flag-pt")
    static let flagPw = ImageAsset(name: "flag-pw")
    static let flagPy = ImageAsset(name: "flag-py")
    static let flagQa = ImageAsset(name: "flag-qa")
    static let flagRo = ImageAsset(name: "flag-ro")
    static let flagRu = ImageAsset(name: "flag-ru")
    static let flagRw = ImageAsset(name: "flag-rw")
    static let flagSa = ImageAsset(name: "flag-sa")
    static let flagSb = ImageAsset(name: "flag-sb")
    static let flagSc = ImageAsset(name: "flag-sc")
    static let flagSd = ImageAsset(name: "flag-sd")
    static let flagSe = ImageAsset(name: "flag-se")
    static let flagSg = ImageAsset(name: "flag-sg")
    static let flagSh = ImageAsset(name: "flag-sh")
    static let flagSi = ImageAsset(name: "flag-si")
    static let flagSk = ImageAsset(name: "flag-sk")
    static let flagSl = ImageAsset(name: "flag-sl")
    static let flagSm = ImageAsset(name: "flag-sm")
    static let flagSn = ImageAsset(name: "flag-sn")
    static let flagSo = ImageAsset(name: "flag-so")
    static let flagSr = ImageAsset(name: "flag-sr")
    static let flagSt = ImageAsset(name: "flag-st")
    static let flagSy = ImageAsset(name: "flag-sy")
    static let flagSz = ImageAsset(name: "flag-sz")
    static let flagTc = ImageAsset(name: "flag-tc")
    static let flagTd = ImageAsset(name: "flag-td")
    static let flagTf = ImageAsset(name: "flag-tf")
    static let flagTg = ImageAsset(name: "flag-tg")
    static let flagTh = ImageAsset(name: "flag-th")
    static let flagTj = ImageAsset(name: "flag-tj")
    static let flagTk = ImageAsset(name: "flag-tk")
    static let flagTm = ImageAsset(name: "flag-tm")
    static let flagTn = ImageAsset(name: "flag-tn")
    static let flagTo = ImageAsset(name: "flag-to")
    static let flagTp = ImageAsset(name: "flag-tp")
    static let flagTr = ImageAsset(name: "flag-tr")
    static let flagTt = ImageAsset(name: "flag-tt")
    static let flagTv = ImageAsset(name: "flag-tv")
    static let flagTw = ImageAsset(name: "flag-tw")
    static let flagTz = ImageAsset(name: "flag-tz")
    static let flagUa = ImageAsset(name: "flag-ua")
    static let flagUg = ImageAsset(name: "flag-ug")
    static let flagUniversal = ImageAsset(name: "flag-universal")
    static let flagUs = ImageAsset(name: "flag-us")
    static let flagUy = ImageAsset(name: "flag-uy")
    static let flagUz = ImageAsset(name: "flag-uz")
    static let flagVa = ImageAsset(name: "flag-va")
    static let flagVc = ImageAsset(name: "flag-vc")
    static let flagVe = ImageAsset(name: "flag-ve")
    static let flagVn = ImageAsset(name: "flag-vn")
    static let flagVu = ImageAsset(name: "flag-vu")
    static let flagWs = ImageAsset(name: "flag-ws")
    static let flagYe = ImageAsset(name: "flag-ye")
    static let flagZa = ImageAsset(name: "flag-za")
    static let flagZm = ImageAsset(name: "flag-zm")
    static let flagZw = ImageAsset(name: "flag-zw")
  }
  static let icon3dtConnect = ImageAsset(name: "icon-3dt-connect")
  static let icon3dtDisconnect = ImageAsset(name: "icon-3dt-disconnect")
  static let icon3dtSelectRegion = ImageAsset(name: "icon-3dt-select-region")
  static let iconAbout = ImageAsset(name: "icon-about")
  static let iconAccount = ImageAsset(name: "icon-account")
  static let iconContact = ImageAsset(name: "icon-contact")
  static let iconDownload = ImageAsset(name: "icon-download")
  static let iconEye = ImageAsset(name: "icon-eye")
  static let iconHomepage = ImageAsset(name: "icon-homepage")
  static let iconInfo = ImageAsset(name: "icon-info")
  static let iconLogout = ImageAsset(name: "icon-logout")
  static let iconPrivacy = ImageAsset(name: "icon-privacy")
  static let iconRegion = ImageAsset(name: "icon-region")
  static let iconSelectedWhite = ImageAsset(name: "icon-selected-white")
  static let iconSelected = ImageAsset(name: "icon-selected")
  static let iconSettings = ImageAsset(name: "icon-settings")
  static let iconUnselectedWhite = ImageAsset(name: "icon-unselected-white")
  static let iconUnselected = ImageAsset(name: "icon-unselected")
  static let iconUpload = ImageAsset(name: "icon-upload")
  static let iconWarning = ImageAsset(name: "icon-warning")
  static let imageContentBlocker = ImageAsset(name: "image-content-blocker")
  static let imageRobot = ImageAsset(name: "image-robot")
  static let imageRobotside = ImageAsset(name: "image-robotside")
  static let imageVpnAllow = ImageAsset(name: "image-vpn-allow")
  static let imageWalkthrough1 = ImageAsset(name: "image-walkthrough-1")
  static let imageWalkthrough2 = ImageAsset(name: "image-walkthrough-2")
  static let imageWalkthrough3 = ImageAsset(name: "image-walkthrough-3")
  static let itemMenu = ImageAsset(name: "item-menu")
  static let navLogoWhite = ImageAsset(name: "nav-logo-white")
  static let navLogo = ImageAsset(name: "nav-logo")

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    Piax.Dashboard.vpnButton,
    Piax.Global.favoriteGreen,
    Piax.Global.favoriteSelected,
    Piax.Global.favoriteUnselectedDark,
    Piax.Global.favoriteUnselected,
    Piax.Global.iconBack,
    Piax.Global.iconFilter,
    Piax.Global.pagecontrolSelectedDot,
    Piax.Global.pagecontrolUnselectedDot,
    Piax.Global.regionSelected,
    Piax.Global.scrollableMapDark,
    Piax.Global.scrollableMapLight,
    Piax.Regions.noResultsDark,
    Piax.Regions.noResultsLight,
    Piax.Splash.darkSplash,
    Piax.Splash.lightSplash,
    Piax.Tiles.ipTriangle,
    accessoryExpire,
    accessorySelected,
    buttonBackgroundToggleConnected,
    buttonBackgroundToggleConnecting,
    buttonBackgroundToggleDisconnected,
    buttonDown,
    buttonToggleConnected,
    buttonToggleConnecting,
    buttonToggleDisconnected,
    buttonUp,
    Flags.flagAd,
    Flags.flagAe,
    Flags.flagAf,
    Flags.flagAg,
    Flags.flagAi,
    Flags.flagAl,
    Flags.flagAm,
    Flags.flagAn,
    Flags.flagAo,
    Flags.flagAq,
    Flags.flagAr,
    Flags.flagAs,
    Flags.flagAt,
    Flags.flagAu,
    Flags.flagAw,
    Flags.flagAz,
    Flags.flagBa,
    Flags.flagBb,
    Flags.flagBd,
    Flags.flagBe,
    Flags.flagBf,
    Flags.flagBg,
    Flags.flagBh,
    Flags.flagBi,
    Flags.flagBj,
    Flags.flagBm,
    Flags.flagBn,
    Flags.flagBo,
    Flags.flagBr,
    Flags.flagBs,
    Flags.flagBt,
    Flags.flagBw,
    Flags.flagBy,
    Flags.flagBz,
    Flags.flagCa,
    Flags.flagCf,
    Flags.flagCg,
    Flags.flagCh,
    Flags.flagCi,
    Flags.flagCk,
    Flags.flagCl,
    Flags.flagCm,
    Flags.flagCn,
    Flags.flagCo,
    Flags.flagCr,
    Flags.flagCu,
    Flags.flagCv,
    Flags.flagCx,
    Flags.flagCy,
    Flags.flagCz,
    Flags.flagDe,
    Flags.flagDj,
    Flags.flagDk,
    Flags.flagDm,
    Flags.flagDo,
    Flags.flagDz,
    Flags.flagEc,
    Flags.flagEe,
    Flags.flagEg,
    Flags.flagEh,
    Flags.flagEr,
    Flags.flagEs,
    Flags.flagEt,
    Flags.flagFi,
    Flags.flagFj,
    Flags.flagFm,
    Flags.flagFo,
    Flags.flagFr,
    Flags.flagGa,
    Flags.flagGb,
    Flags.flagGd,
    Flags.flagGe,
    Flags.flagGh,
    Flags.flagGi,
    Flags.flagGl,
    Flags.flagGm,
    Flags.flagGn,
    Flags.flagGr,
    Flags.flagGs,
    Flags.flagGu,
    Flags.flagGw,
    Flags.flagGy,
    Flags.flagHk,
    Flags.flagId,
    Flags.flagIe,
    Flags.flagIl,
    Flags.flagIn,
    Flags.flagIo,
    Flags.flagIq,
    Flags.flagIr,
    Flags.flagIs,
    Flags.flagIt,
    Flags.flagJm,
    Flags.flagJo,
    Flags.flagJp,
    Flags.flagKe,
    Flags.flagKg,
    Flags.flagKh,
    Flags.flagKi,
    Flags.flagKm,
    Flags.flagKn,
    Flags.flagKp,
    Flags.flagKr,
    Flags.flagKw,
    Flags.flagKy,
    Flags.flagKz,
    Flags.flagLb,
    Flags.flagLc,
    Flags.flagLi,
    Flags.flagLk,
    Flags.flagLr,
    Flags.flagLs,
    Flags.flagLt,
    Flags.flagLu,
    Flags.flagLv,
    Flags.flagMa,
    Flags.flagMc,
    Flags.flagMd,
    Flags.flagMg,
    Flags.flagMh,
    Flags.flagMl,
    Flags.flagMm,
    Flags.flagMn,
    Flags.flagMo,
    Flags.flagMp,
    Flags.flagMr,
    Flags.flagMs,
    Flags.flagMt,
    Flags.flagMu,
    Flags.flagMv,
    Flags.flagMw,
    Flags.flagMx,
    Flags.flagMy,
    Flags.flagMz,
    Flags.flagNa,
    Flags.flagNe,
    Flags.flagNf,
    Flags.flagNg,
    Flags.flagNi,
    Flags.flagNl,
    Flags.flagNo,
    Flags.flagNp,
    Flags.flagNr,
    Flags.flagNu,
    Flags.flagNz,
    Flags.flagOm,
    Flags.flagPa,
    Flags.flagPe,
    Flags.flagPf,
    Flags.flagPg,
    Flags.flagPh,
    Flags.flagPk,
    Flags.flagPm,
    Flags.flagPn,
    Flags.flagPr,
    Flags.flagPt,
    Flags.flagPw,
    Flags.flagPy,
    Flags.flagQa,
    Flags.flagRo,
    Flags.flagRu,
    Flags.flagRw,
    Flags.flagSa,
    Flags.flagSb,
    Flags.flagSc,
    Flags.flagSd,
    Flags.flagSe,
    Flags.flagSg,
    Flags.flagSh,
    Flags.flagSi,
    Flags.flagSk,
    Flags.flagSl,
    Flags.flagSm,
    Flags.flagSn,
    Flags.flagSo,
    Flags.flagSr,
    Flags.flagSt,
    Flags.flagSy,
    Flags.flagSz,
    Flags.flagTc,
    Flags.flagTd,
    Flags.flagTf,
    Flags.flagTg,
    Flags.flagTh,
    Flags.flagTj,
    Flags.flagTk,
    Flags.flagTm,
    Flags.flagTn,
    Flags.flagTo,
    Flags.flagTp,
    Flags.flagTr,
    Flags.flagTt,
    Flags.flagTv,
    Flags.flagTw,
    Flags.flagTz,
    Flags.flagUa,
    Flags.flagUg,
    Flags.flagUniversal,
    Flags.flagUs,
    Flags.flagUy,
    Flags.flagUz,
    Flags.flagVa,
    Flags.flagVc,
    Flags.flagVe,
    Flags.flagVn,
    Flags.flagVu,
    Flags.flagWs,
    Flags.flagYe,
    Flags.flagZa,
    Flags.flagZm,
    Flags.flagZw,
    icon3dtConnect,
    icon3dtDisconnect,
    icon3dtSelectRegion,
    iconAbout,
    iconAccount,
    iconContact,
    iconDownload,
    iconEye,
    iconHomepage,
    iconInfo,
    iconLogout,
    iconPrivacy,
    iconRegion,
    iconSelectedWhite,
    iconSelected,
    iconSettings,
    iconUnselectedWhite,
    iconUnselected,
    iconUpload,
    iconWarning,
    imageContentBlocker,
    imageRobot,
    imageRobotside,
    imageVpnAllow,
    imageWalkthrough1,
    imageWalkthrough2,
    imageWalkthrough3,
    itemMenu,
    navLogoWhite,
    navLogo,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
