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
      public static let iconEditTile = ImageAsset(name: "PIAX/Global/icon-edit-tile")
      public static let iconFilter = ImageAsset(name: "PIAX/Global/icon-filter")
      public static let iconWarning = ImageAsset(name: "PIAX/Global/icon-warning")
      public static let killswitchActive = ImageAsset(name: "PIAX/Global/killswitch-active")
      public static let killswitchInactive = ImageAsset(name: "PIAX/Global/killswitch-inactive")
      public static let nmtActive = ImageAsset(name: "PIAX/Global/nmt-active")
      public static let nmtInactive = ImageAsset(name: "PIAX/Global/nmt-inactive")
      public static let pagecontrolSelectedDot = ImageAsset(name: "PIAX/Global/pagecontrol-selected-dot")
      public static let pagecontrolUnselectedDot = ImageAsset(name: "PIAX/Global/pagecontrol-unselected-dot")
      public static let planSelected = ImageAsset(name: "PIAX/Global/plan-selected")
      public static let planUnselected = ImageAsset(name: "PIAX/Global/plan-unselected")
      public static let regionSelected = ImageAsset(name: "PIAX/Global/region-selected")
      public static let scrollableMap = ImageAsset(name: "PIAX/Global/scrollableMap")
      public static let themeActive = ImageAsset(name: "PIAX/Global/theme-active")
      public static let themeInactive = ImageAsset(name: "PIAX/Global/theme-inactive")
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
  public enum Flags {
    public static let flagAd = ImageAsset(name: "flags/flag-ad")
    public static let flagAe = ImageAsset(name: "flags/flag-ae")
    public static let flagAf = ImageAsset(name: "flags/flag-af")
    public static let flagAg = ImageAsset(name: "flags/flag-ag")
    public static let flagAi = ImageAsset(name: "flags/flag-ai")
    public static let flagAl = ImageAsset(name: "flags/flag-al")
    public static let flagAm = ImageAsset(name: "flags/flag-am")
    public static let flagAo = ImageAsset(name: "flags/flag-ao")
    public static let flagAq = ImageAsset(name: "flags/flag-aq")
    public static let flagAr = ImageAsset(name: "flags/flag-ar")
    public static let flagAs = ImageAsset(name: "flags/flag-as")
    public static let flagAt = ImageAsset(name: "flags/flag-at")
    public static let flagAu = ImageAsset(name: "flags/flag-au")
    public static let flagAw = ImageAsset(name: "flags/flag-aw")
    public static let flagAx = ImageAsset(name: "flags/flag-ax")
    public static let flagAz = ImageAsset(name: "flags/flag-az")
    public static let flagBa = ImageAsset(name: "flags/flag-ba")
    public static let flagBb = ImageAsset(name: "flags/flag-bb")
    public static let flagBd = ImageAsset(name: "flags/flag-bd")
    public static let flagBe = ImageAsset(name: "flags/flag-be")
    public static let flagBf = ImageAsset(name: "flags/flag-bf")
    public static let flagBg = ImageAsset(name: "flags/flag-bg")
    public static let flagBh = ImageAsset(name: "flags/flag-bh")
    public static let flagBi = ImageAsset(name: "flags/flag-bi")
    public static let flagBj = ImageAsset(name: "flags/flag-bj")
    public static let flagBl = ImageAsset(name: "flags/flag-bl")
    public static let flagBm = ImageAsset(name: "flags/flag-bm")
    public static let flagBn = ImageAsset(name: "flags/flag-bn")
    public static let flagBo = ImageAsset(name: "flags/flag-bo")
    public static let flagBq = ImageAsset(name: "flags/flag-bq")
    public static let flagBr = ImageAsset(name: "flags/flag-br")
    public static let flagBs = ImageAsset(name: "flags/flag-bs")
    public static let flagBt = ImageAsset(name: "flags/flag-bt")
    public static let flagBv = ImageAsset(name: "flags/flag-bv")
    public static let flagBw = ImageAsset(name: "flags/flag-bw")
    public static let flagBy = ImageAsset(name: "flags/flag-by")
    public static let flagBz = ImageAsset(name: "flags/flag-bz")
    public static let flagCa = ImageAsset(name: "flags/flag-ca")
    public static let flagCc = ImageAsset(name: "flags/flag-cc")
    public static let flagCd = ImageAsset(name: "flags/flag-cd")
    public static let flagCf = ImageAsset(name: "flags/flag-cf")
    public static let flagCg = ImageAsset(name: "flags/flag-cg")
    public static let flagCh = ImageAsset(name: "flags/flag-ch")
    public static let flagCi = ImageAsset(name: "flags/flag-ci")
    public static let flagCk = ImageAsset(name: "flags/flag-ck")
    public static let flagCl = ImageAsset(name: "flags/flag-cl")
    public static let flagCm = ImageAsset(name: "flags/flag-cm")
    public static let flagCn = ImageAsset(name: "flags/flag-cn")
    public static let flagCo = ImageAsset(name: "flags/flag-co")
    public static let flagCr = ImageAsset(name: "flags/flag-cr")
    public static let flagCu = ImageAsset(name: "flags/flag-cu")
    public static let flagCv = ImageAsset(name: "flags/flag-cv")
    public static let flagCw = ImageAsset(name: "flags/flag-cw")
    public static let flagCx = ImageAsset(name: "flags/flag-cx")
    public static let flagCy = ImageAsset(name: "flags/flag-cy")
    public static let flagCz = ImageAsset(name: "flags/flag-cz")
    public static let flagDe = ImageAsset(name: "flags/flag-de")
    public static let flagDj = ImageAsset(name: "flags/flag-dj")
    public static let flagDk = ImageAsset(name: "flags/flag-dk")
    public static let flagDm = ImageAsset(name: "flags/flag-dm")
    public static let flagDo = ImageAsset(name: "flags/flag-do")
    public static let flagDz = ImageAsset(name: "flags/flag-dz")
    public static let flagEc = ImageAsset(name: "flags/flag-ec")
    public static let flagEe = ImageAsset(name: "flags/flag-ee")
    public static let flagEg = ImageAsset(name: "flags/flag-eg")
    public static let flagEh = ImageAsset(name: "flags/flag-eh")
    public static let flagEr = ImageAsset(name: "flags/flag-er")
    public static let flagEsCt = ImageAsset(name: "flags/flag-es-ct")
    public static let flagEs = ImageAsset(name: "flags/flag-es")
    public static let flagEt = ImageAsset(name: "flags/flag-et")
    public static let flagEu = ImageAsset(name: "flags/flag-eu")
    public static let flagFi = ImageAsset(name: "flags/flag-fi")
    public static let flagFj = ImageAsset(name: "flags/flag-fj")
    public static let flagFk = ImageAsset(name: "flags/flag-fk")
    public static let flagFm = ImageAsset(name: "flags/flag-fm")
    public static let flagFo = ImageAsset(name: "flags/flag-fo")
    public static let flagFr = ImageAsset(name: "flags/flag-fr")
    public static let flagGa = ImageAsset(name: "flags/flag-ga")
    public static let flagGbEng = ImageAsset(name: "flags/flag-gb-eng")
    public static let flagGbNir = ImageAsset(name: "flags/flag-gb-nir")
    public static let flagGbSct = ImageAsset(name: "flags/flag-gb-sct")
    public static let flagGbWls = ImageAsset(name: "flags/flag-gb-wls")
    public static let flagGb = ImageAsset(name: "flags/flag-gb")
    public static let flagGd = ImageAsset(name: "flags/flag-gd")
    public static let flagGe = ImageAsset(name: "flags/flag-ge")
    public static let flagGf = ImageAsset(name: "flags/flag-gf")
    public static let flagGg = ImageAsset(name: "flags/flag-gg")
    public static let flagGh = ImageAsset(name: "flags/flag-gh")
    public static let flagGi = ImageAsset(name: "flags/flag-gi")
    public static let flagGl = ImageAsset(name: "flags/flag-gl")
    public static let flagGm = ImageAsset(name: "flags/flag-gm")
    public static let flagGn = ImageAsset(name: "flags/flag-gn")
    public static let flagGp = ImageAsset(name: "flags/flag-gp")
    public static let flagGq = ImageAsset(name: "flags/flag-gq")
    public static let flagGr = ImageAsset(name: "flags/flag-gr")
    public static let flagGs = ImageAsset(name: "flags/flag-gs")
    public static let flagGt = ImageAsset(name: "flags/flag-gt")
    public static let flagGu = ImageAsset(name: "flags/flag-gu")
    public static let flagGw = ImageAsset(name: "flags/flag-gw")
    public static let flagGy = ImageAsset(name: "flags/flag-gy")
    public static let flagHk = ImageAsset(name: "flags/flag-hk")
    public static let flagHm = ImageAsset(name: "flags/flag-hm")
    public static let flagHn = ImageAsset(name: "flags/flag-hn")
    public static let flagHr = ImageAsset(name: "flags/flag-hr")
    public static let flagHt = ImageAsset(name: "flags/flag-ht")
    public static let flagHu = ImageAsset(name: "flags/flag-hu")
    public static let flagId = ImageAsset(name: "flags/flag-id")
    public static let flagIe = ImageAsset(name: "flags/flag-ie")
    public static let flagIl = ImageAsset(name: "flags/flag-il")
    public static let flagIm = ImageAsset(name: "flags/flag-im")
    public static let flagIn = ImageAsset(name: "flags/flag-in")
    public static let flagIo = ImageAsset(name: "flags/flag-io")
    public static let flagIq = ImageAsset(name: "flags/flag-iq")
    public static let flagIr = ImageAsset(name: "flags/flag-ir")
    public static let flagIs = ImageAsset(name: "flags/flag-is")
    public static let flagIt = ImageAsset(name: "flags/flag-it")
    public static let flagJe = ImageAsset(name: "flags/flag-je")
    public static let flagJm = ImageAsset(name: "flags/flag-jm")
    public static let flagJo = ImageAsset(name: "flags/flag-jo")
    public static let flagJp = ImageAsset(name: "flags/flag-jp")
    public static let flagKe = ImageAsset(name: "flags/flag-ke")
    public static let flagKg = ImageAsset(name: "flags/flag-kg")
    public static let flagKh = ImageAsset(name: "flags/flag-kh")
    public static let flagKi = ImageAsset(name: "flags/flag-ki")
    public static let flagKm = ImageAsset(name: "flags/flag-km")
    public static let flagKn = ImageAsset(name: "flags/flag-kn")
    public static let flagKp = ImageAsset(name: "flags/flag-kp")
    public static let flagKr = ImageAsset(name: "flags/flag-kr")
    public static let flagKw = ImageAsset(name: "flags/flag-kw")
    public static let flagKy = ImageAsset(name: "flags/flag-ky")
    public static let flagKz = ImageAsset(name: "flags/flag-kz")
    public static let flagLa = ImageAsset(name: "flags/flag-la")
    public static let flagLb = ImageAsset(name: "flags/flag-lb")
    public static let flagLc = ImageAsset(name: "flags/flag-lc")
    public static let flagLi = ImageAsset(name: "flags/flag-li")
    public static let flagLk = ImageAsset(name: "flags/flag-lk")
    public static let flagLr = ImageAsset(name: "flags/flag-lr")
    public static let flagLs = ImageAsset(name: "flags/flag-ls")
    public static let flagLt = ImageAsset(name: "flags/flag-lt")
    public static let flagLu = ImageAsset(name: "flags/flag-lu")
    public static let flagLv = ImageAsset(name: "flags/flag-lv")
    public static let flagLy = ImageAsset(name: "flags/flag-ly")
    public static let flagMa = ImageAsset(name: "flags/flag-ma")
    public static let flagMc = ImageAsset(name: "flags/flag-mc")
    public static let flagMd = ImageAsset(name: "flags/flag-md")
    public static let flagMe = ImageAsset(name: "flags/flag-me")
    public static let flagMf = ImageAsset(name: "flags/flag-mf")
    public static let flagMg = ImageAsset(name: "flags/flag-mg")
    public static let flagMh = ImageAsset(name: "flags/flag-mh")
    public static let flagMk = ImageAsset(name: "flags/flag-mk")
    public static let flagMl = ImageAsset(name: "flags/flag-ml")
    public static let flagMm = ImageAsset(name: "flags/flag-mm")
    public static let flagMn = ImageAsset(name: "flags/flag-mn")
    public static let flagMo = ImageAsset(name: "flags/flag-mo")
    public static let flagMp = ImageAsset(name: "flags/flag-mp")
    public static let flagMq = ImageAsset(name: "flags/flag-mq")
    public static let flagMr = ImageAsset(name: "flags/flag-mr")
    public static let flagMs = ImageAsset(name: "flags/flag-ms")
    public static let flagMt = ImageAsset(name: "flags/flag-mt")
    public static let flagMu = ImageAsset(name: "flags/flag-mu")
    public static let flagMv = ImageAsset(name: "flags/flag-mv")
    public static let flagMw = ImageAsset(name: "flags/flag-mw")
    public static let flagMx = ImageAsset(name: "flags/flag-mx")
    public static let flagMy = ImageAsset(name: "flags/flag-my")
    public static let flagMz = ImageAsset(name: "flags/flag-mz")
    public static let flagNa = ImageAsset(name: "flags/flag-na")
    public static let flagNc = ImageAsset(name: "flags/flag-nc")
    public static let flagNe = ImageAsset(name: "flags/flag-ne")
    public static let flagNf = ImageAsset(name: "flags/flag-nf")
    public static let flagNg = ImageAsset(name: "flags/flag-ng")
    public static let flagNi = ImageAsset(name: "flags/flag-ni")
    public static let flagNl = ImageAsset(name: "flags/flag-nl")
    public static let flagNo = ImageAsset(name: "flags/flag-no")
    public static let flagNp = ImageAsset(name: "flags/flag-np")
    public static let flagNr = ImageAsset(name: "flags/flag-nr")
    public static let flagNu = ImageAsset(name: "flags/flag-nu")
    public static let flagNz = ImageAsset(name: "flags/flag-nz")
    public static let flagOm = ImageAsset(name: "flags/flag-om")
    public static let flagPa = ImageAsset(name: "flags/flag-pa")
    public static let flagPe = ImageAsset(name: "flags/flag-pe")
    public static let flagPf = ImageAsset(name: "flags/flag-pf")
    public static let flagPg = ImageAsset(name: "flags/flag-pg")
    public static let flagPh = ImageAsset(name: "flags/flag-ph")
    public static let flagPk = ImageAsset(name: "flags/flag-pk")
    public static let flagPl = ImageAsset(name: "flags/flag-pl")
    public static let flagPm = ImageAsset(name: "flags/flag-pm")
    public static let flagPn = ImageAsset(name: "flags/flag-pn")
    public static let flagPr = ImageAsset(name: "flags/flag-pr")
    public static let flagPs = ImageAsset(name: "flags/flag-ps")
    public static let flagPt = ImageAsset(name: "flags/flag-pt")
    public static let flagPw = ImageAsset(name: "flags/flag-pw")
    public static let flagPy = ImageAsset(name: "flags/flag-py")
    public static let flagQa = ImageAsset(name: "flags/flag-qa")
    public static let flagRe = ImageAsset(name: "flags/flag-re")
    public static let flagRo = ImageAsset(name: "flags/flag-ro")
    public static let flagRs = ImageAsset(name: "flags/flag-rs")
    public static let flagRu = ImageAsset(name: "flags/flag-ru")
    public static let flagRw = ImageAsset(name: "flags/flag-rw")
    public static let flagSa = ImageAsset(name: "flags/flag-sa")
    public static let flagSb = ImageAsset(name: "flags/flag-sb")
    public static let flagSc = ImageAsset(name: "flags/flag-sc")
    public static let flagSd = ImageAsset(name: "flags/flag-sd")
    public static let flagSe = ImageAsset(name: "flags/flag-se")
    public static let flagSg = ImageAsset(name: "flags/flag-sg")
    public static let flagSh = ImageAsset(name: "flags/flag-sh")
    public static let flagSi = ImageAsset(name: "flags/flag-si")
    public static let flagSj = ImageAsset(name: "flags/flag-sj")
    public static let flagSk = ImageAsset(name: "flags/flag-sk")
    public static let flagSl = ImageAsset(name: "flags/flag-sl")
    public static let flagSm = ImageAsset(name: "flags/flag-sm")
    public static let flagSn = ImageAsset(name: "flags/flag-sn")
    public static let flagSo = ImageAsset(name: "flags/flag-so")
    public static let flagSr = ImageAsset(name: "flags/flag-sr")
    public static let flagSs = ImageAsset(name: "flags/flag-ss")
    public static let flagSt = ImageAsset(name: "flags/flag-st")
    public static let flagSv = ImageAsset(name: "flags/flag-sv")
    public static let flagSx = ImageAsset(name: "flags/flag-sx")
    public static let flagSy = ImageAsset(name: "flags/flag-sy")
    public static let flagSz = ImageAsset(name: "flags/flag-sz")
    public static let flagTc = ImageAsset(name: "flags/flag-tc")
    public static let flagTd = ImageAsset(name: "flags/flag-td")
    public static let flagTf = ImageAsset(name: "flags/flag-tf")
    public static let flagTg = ImageAsset(name: "flags/flag-tg")
    public static let flagTh = ImageAsset(name: "flags/flag-th")
    public static let flagTj = ImageAsset(name: "flags/flag-tj")
    public static let flagTk = ImageAsset(name: "flags/flag-tk")
    public static let flagTl = ImageAsset(name: "flags/flag-tl")
    public static let flagTm = ImageAsset(name: "flags/flag-tm")
    public static let flagTn = ImageAsset(name: "flags/flag-tn")
    public static let flagTo = ImageAsset(name: "flags/flag-to")
    public static let flagTr = ImageAsset(name: "flags/flag-tr")
    public static let flagTt = ImageAsset(name: "flags/flag-tt")
    public static let flagTv = ImageAsset(name: "flags/flag-tv")
    public static let flagTw = ImageAsset(name: "flags/flag-tw")
    public static let flagTz = ImageAsset(name: "flags/flag-tz")
    public static let flagUa = ImageAsset(name: "flags/flag-ua")
    public static let flagUg = ImageAsset(name: "flags/flag-ug")
    public static let flagUm = ImageAsset(name: "flags/flag-um")
    public static let flagUn = ImageAsset(name: "flags/flag-un")
    public static let flagUniversal = ImageAsset(name: "flags/flag-universal")
    public static let flagUs = ImageAsset(name: "flags/flag-us")
    public static let flagUy = ImageAsset(name: "flags/flag-uy")
    public static let flagUz = ImageAsset(name: "flags/flag-uz")
    public static let flagVa = ImageAsset(name: "flags/flag-va")
    public static let flagVc = ImageAsset(name: "flags/flag-vc")
    public static let flagVe = ImageAsset(name: "flags/flag-ve")
    public static let flagVg = ImageAsset(name: "flags/flag-vg")
    public static let flagVi = ImageAsset(name: "flags/flag-vi")
    public static let flagVn = ImageAsset(name: "flags/flag-vn")
    public static let flagVu = ImageAsset(name: "flags/flag-vu")
    public static let flagWf = ImageAsset(name: "flags/flag-wf")
    public static let flagWs = ImageAsset(name: "flags/flag-ws")
    public static let flagYe = ImageAsset(name: "flags/flag-ye")
    public static let flagYt = ImageAsset(name: "flags/flag-yt")
    public static let flagZa = ImageAsset(name: "flags/flag-za")
    public static let flagZm = ImageAsset(name: "flags/flag-zm")
    public static let flagZw = ImageAsset(name: "flags/flag-zw")
  }
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
  public static let imageWalkthrough2 = ImageAsset(name: "image-walkthrough-2")
  public static let itemMenu = ImageAsset(name: "item-menu")
  public static let navLogo = ImageAsset(name: "nav-logo")
  public static let offlineServerIcon = ImageAsset(name: "offline-server-icon")
  public static let piaSpinner = ImageAsset(name: "pia-spinner")
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
