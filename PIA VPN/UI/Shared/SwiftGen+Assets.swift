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
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Images {
    internal enum Cards {
      internal enum WireGuard {
        internal static let wgBackgroundDark = ImageAsset(name: "Cards/WireGuard/wg-background-dark")
        internal static let wgBackgroundLight = ImageAsset(name: "Cards/WireGuard/wg-background-light")
        internal static let wgMain = ImageAsset(name: "Cards/WireGuard/wg-main")
      }
    }
    internal enum Piax {
      internal enum DarkMap {
        internal static let darkMap = ImageAsset(name: "PIAX/DarkMap/Dark-Map")
      }
      internal enum Dashboard {
        internal static let vpnButton = ImageAsset(name: "PIAX/Dashboard/vpn-button")
      }
      internal enum Global {
        internal static let browserDarkInactive = ImageAsset(name: "PIAX/Global/browser-dark-inactive")
        internal static let browserLightInactive = ImageAsset(name: "PIAX/Global/browser-light-inactive")
        internal static let dragDropIndicatorDark = ImageAsset(name: "PIAX/Global/drag-drop-indicator-dark")
        internal static let dragDropIndicatorLight = ImageAsset(name: "PIAX/Global/drag-drop-indicator-light")
        internal static let eyeActiveDark = ImageAsset(name: "PIAX/Global/eye-active-dark")
        internal static let eyeActiveLight = ImageAsset(name: "PIAX/Global/eye-active-light")
        internal static let eyeInactiveDark = ImageAsset(name: "PIAX/Global/eye-inactive-dark")
        internal static let eyeInactiveLight = ImageAsset(name: "PIAX/Global/eye-inactive-light")
        internal static let favoriteGreen = ImageAsset(name: "PIAX/Global/favorite-green")
        internal static let favoriteSelected = ImageAsset(name: "PIAX/Global/favorite-selected")
        internal static let favoriteUnselectedDark = ImageAsset(name: "PIAX/Global/favorite-unselected-dark")
        internal static let favoriteUnselected = ImageAsset(name: "PIAX/Global/favorite-unselected")
        internal static let iconBack = ImageAsset(name: "PIAX/Global/icon-back")
        internal static let iconEditTile = ImageAsset(name: "PIAX/Global/icon-edit-tile")
        internal static let iconFilter = ImageAsset(name: "PIAX/Global/icon-filter")
        internal static let killswitchDarkActive = ImageAsset(name: "PIAX/Global/killswitch-dark-active")
        internal static let killswitchDarkInactive = ImageAsset(name: "PIAX/Global/killswitch-dark-inactive")
        internal static let killswitchLightInactive = ImageAsset(name: "PIAX/Global/killswitch-light-inactive")
        internal static let nmtDarkActive = ImageAsset(name: "PIAX/Global/nmt-dark-active")
        internal static let nmtDarkInactive = ImageAsset(name: "PIAX/Global/nmt-dark-inactive")
        internal static let nmtLightActive = ImageAsset(name: "PIAX/Global/nmt-light-active")
        internal static let nmtLightInactive = ImageAsset(name: "PIAX/Global/nmt-light-inactive")
        internal static let regionSelected = ImageAsset(name: "PIAX/Global/region-selected")
        internal static let themeDarkActive = ImageAsset(name: "PIAX/Global/theme-dark-active")
        internal static let themeDarkInactive = ImageAsset(name: "PIAX/Global/theme-dark-inactive")
        internal static let themeLightActive = ImageAsset(name: "PIAX/Global/theme-light-active")
        internal static let themeLightInactive = ImageAsset(name: "PIAX/Global/theme-light-inactive")
        internal static let trustedDarkIcon = ImageAsset(name: "PIAX/Global/trusted-dark-icon")
        internal static let trustedLightIcon = ImageAsset(name: "PIAX/Global/trusted-light-icon")
        internal static let untrustedDarkIcon = ImageAsset(name: "PIAX/Global/untrusted-dark-icon")
        internal static let untrustedLightIcon = ImageAsset(name: "PIAX/Global/untrusted-light-icon")
      }
      internal enum Nmt {
        internal static let iconAddRule = ImageAsset(name: "PIAX/NMT/icon-add-rule")
        internal static let iconCustomWifiConnect = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-connect")
        internal static let iconCustomWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-disconnect")
        internal static let iconCustomWifiRetain = ImageAsset(name: "PIAX/NMT/icon-custom-wifi-retain")
        internal static let iconDisconnect = ImageAsset(name: "PIAX/NMT/icon-disconnect")
        internal static let iconMobileDataConnect = ImageAsset(name: "PIAX/NMT/icon-mobile-data-connect")
        internal static let iconMobileDataDisconnect = ImageAsset(name: "PIAX/NMT/icon-mobile-data-disconnect")
        internal static let iconMobileDataRetain = ImageAsset(name: "PIAX/NMT/icon-mobile-data-retain")
        internal static let iconNmtConnect = ImageAsset(name: "PIAX/NMT/icon-nmt-connect")
        internal static let iconNmtWifi = ImageAsset(name: "PIAX/NMT/icon-nmt-wifi")
        internal static let iconOpenWifiConnect = ImageAsset(name: "PIAX/NMT/icon-open-wifi-connect")
        internal static let iconOpenWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-open-wifi-disconnect")
        internal static let iconOpenWifiRetain = ImageAsset(name: "PIAX/NMT/icon-open-wifi-retain")
        internal static let iconOptions = ImageAsset(name: "PIAX/NMT/icon-options")
        internal static let iconRetain = ImageAsset(name: "PIAX/NMT/icon-retain")
        internal static let iconSecureWifiConnect = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-connect")
        internal static let iconSecureWifiDisconnect = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-disconnect")
        internal static let iconSecureWifiRetain = ImageAsset(name: "PIAX/NMT/icon-secure-wifi-retain")
        internal static let iconSelect = ImageAsset(name: "PIAX/NMT/icon-select")
      }
      internal enum Regions {
        internal static let noResultsDark = ImageAsset(name: "PIAX/Regions/no-results-dark")
        internal static let noResultsLight = ImageAsset(name: "PIAX/Regions/no-results-light")
      }
      internal enum Settings {
        internal static let iconAbout = ImageAsset(name: "PIAX/Settings/icon-about")
        internal static let iconAutomation = ImageAsset(name: "PIAX/Settings/icon-automation")
        internal static let iconGeneral = ImageAsset(name: "PIAX/Settings/icon-general")
        internal static let iconNetwork = ImageAsset(name: "PIAX/Settings/icon-network")
        internal static let iconPrivacy = ImageAsset(name: "PIAX/Settings/icon-privacy")
        internal static let iconProtocols = ImageAsset(name: "PIAX/Settings/icon-protocols")
      }
      internal enum Splash {
        internal static let splash = ImageAsset(name: "PIAX/Splash/splash")
      }
      internal enum Tiles {
        internal enum ConnectionTile {
          internal static let iconAuthentication = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-authentication")
          internal static let iconEncryption = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-encryption")
          internal static let iconHandshake = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-handshake")
          internal static let iconPort = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-port")
          internal static let iconProtocol = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-protocol")
          internal static let iconSocket = ImageAsset(name: "PIAX/Tiles/ConnectionTile/icon-socket")
        }
        internal static let ipTriangle = ImageAsset(name: "PIAX/Tiles/ip-triangle")
        internal static let openTileDetails = ImageAsset(name: "PIAX/Tiles/open-tile-details")
        internal static let quickConnectPlaceholderDark = ImageAsset(name: "PIAX/Tiles/quick-connect-placeholder-dark")
        internal static let quickConnectPlaceholderLight = ImageAsset(name: "PIAX/Tiles/quick-connect-placeholder-light")
      }
    }
    internal static let accessoryExpire = ImageAsset(name: "accessory-expire")
    internal static let accessorySelected = ImageAsset(name: "accessory-selected")
    internal static let buttonDown = ImageAsset(name: "button-down")
    internal static let buttonUp = ImageAsset(name: "button-up")
    internal static let copyIcon = ImageAsset(name: "copy-icon")
    internal static let dipBadgeDark = ImageAsset(name: "dip-badge-dark")
    internal static let dipBadgeLight = ImageAsset(name: "dip-badge-light")
    internal enum Flags {
      internal static let flagAd = ImageAsset(name: "flags/flag-ad")
      internal static let flagAe = ImageAsset(name: "flags/flag-ae")
      internal static let flagAf = ImageAsset(name: "flags/flag-af")
      internal static let flagAg = ImageAsset(name: "flags/flag-ag")
      internal static let flagAi = ImageAsset(name: "flags/flag-ai")
      internal static let flagAl = ImageAsset(name: "flags/flag-al")
      internal static let flagAm = ImageAsset(name: "flags/flag-am")
      internal static let flagAo = ImageAsset(name: "flags/flag-ao")
      internal static let flagAq = ImageAsset(name: "flags/flag-aq")
      internal static let flagAr = ImageAsset(name: "flags/flag-ar")
      internal static let flagAs = ImageAsset(name: "flags/flag-as")
      internal static let flagAt = ImageAsset(name: "flags/flag-at")
      internal static let flagAu = ImageAsset(name: "flags/flag-au")
      internal static let flagAw = ImageAsset(name: "flags/flag-aw")
      internal static let flagAx = ImageAsset(name: "flags/flag-ax")
      internal static let flagAz = ImageAsset(name: "flags/flag-az")
      internal static let flagBa = ImageAsset(name: "flags/flag-ba")
      internal static let flagBb = ImageAsset(name: "flags/flag-bb")
      internal static let flagBd = ImageAsset(name: "flags/flag-bd")
      internal static let flagBe = ImageAsset(name: "flags/flag-be")
      internal static let flagBf = ImageAsset(name: "flags/flag-bf")
      internal static let flagBg = ImageAsset(name: "flags/flag-bg")
      internal static let flagBh = ImageAsset(name: "flags/flag-bh")
      internal static let flagBi = ImageAsset(name: "flags/flag-bi")
      internal static let flagBj = ImageAsset(name: "flags/flag-bj")
      internal static let flagBl = ImageAsset(name: "flags/flag-bl")
      internal static let flagBm = ImageAsset(name: "flags/flag-bm")
      internal static let flagBn = ImageAsset(name: "flags/flag-bn")
      internal static let flagBo = ImageAsset(name: "flags/flag-bo")
      internal static let flagBq = ImageAsset(name: "flags/flag-bq")
      internal static let flagBr = ImageAsset(name: "flags/flag-br")
      internal static let flagBs = ImageAsset(name: "flags/flag-bs")
      internal static let flagBt = ImageAsset(name: "flags/flag-bt")
      internal static let flagBv = ImageAsset(name: "flags/flag-bv")
      internal static let flagBw = ImageAsset(name: "flags/flag-bw")
      internal static let flagBy = ImageAsset(name: "flags/flag-by")
      internal static let flagBz = ImageAsset(name: "flags/flag-bz")
      internal static let flagCa = ImageAsset(name: "flags/flag-ca")
      internal static let flagCc = ImageAsset(name: "flags/flag-cc")
      internal static let flagCd = ImageAsset(name: "flags/flag-cd")
      internal static let flagCf = ImageAsset(name: "flags/flag-cf")
      internal static let flagCg = ImageAsset(name: "flags/flag-cg")
      internal static let flagCh = ImageAsset(name: "flags/flag-ch")
      internal static let flagCi = ImageAsset(name: "flags/flag-ci")
      internal static let flagCk = ImageAsset(name: "flags/flag-ck")
      internal static let flagCl = ImageAsset(name: "flags/flag-cl")
      internal static let flagCm = ImageAsset(name: "flags/flag-cm")
      internal static let flagCn = ImageAsset(name: "flags/flag-cn")
      internal static let flagCo = ImageAsset(name: "flags/flag-co")
      internal static let flagCr = ImageAsset(name: "flags/flag-cr")
      internal static let flagCu = ImageAsset(name: "flags/flag-cu")
      internal static let flagCv = ImageAsset(name: "flags/flag-cv")
      internal static let flagCw = ImageAsset(name: "flags/flag-cw")
      internal static let flagCx = ImageAsset(name: "flags/flag-cx")
      internal static let flagCy = ImageAsset(name: "flags/flag-cy")
      internal static let flagCz = ImageAsset(name: "flags/flag-cz")
      internal static let flagDe = ImageAsset(name: "flags/flag-de")
      internal static let flagDj = ImageAsset(name: "flags/flag-dj")
      internal static let flagDk = ImageAsset(name: "flags/flag-dk")
      internal static let flagDm = ImageAsset(name: "flags/flag-dm")
      internal static let flagDo = ImageAsset(name: "flags/flag-do")
      internal static let flagDz = ImageAsset(name: "flags/flag-dz")
      internal static let flagEc = ImageAsset(name: "flags/flag-ec")
      internal static let flagEe = ImageAsset(name: "flags/flag-ee")
      internal static let flagEg = ImageAsset(name: "flags/flag-eg")
      internal static let flagEh = ImageAsset(name: "flags/flag-eh")
      internal static let flagEr = ImageAsset(name: "flags/flag-er")
      internal static let flagEsCt = ImageAsset(name: "flags/flag-es-ct")
      internal static let flagEs = ImageAsset(name: "flags/flag-es")
      internal static let flagEt = ImageAsset(name: "flags/flag-et")
      internal static let flagEu = ImageAsset(name: "flags/flag-eu")
      internal static let flagFi = ImageAsset(name: "flags/flag-fi")
      internal static let flagFj = ImageAsset(name: "flags/flag-fj")
      internal static let flagFk = ImageAsset(name: "flags/flag-fk")
      internal static let flagFm = ImageAsset(name: "flags/flag-fm")
      internal static let flagFo = ImageAsset(name: "flags/flag-fo")
      internal static let flagFr = ImageAsset(name: "flags/flag-fr")
      internal static let flagGa = ImageAsset(name: "flags/flag-ga")
      internal static let flagGbEng = ImageAsset(name: "flags/flag-gb-eng")
      internal static let flagGbNir = ImageAsset(name: "flags/flag-gb-nir")
      internal static let flagGbSct = ImageAsset(name: "flags/flag-gb-sct")
      internal static let flagGbWls = ImageAsset(name: "flags/flag-gb-wls")
      internal static let flagGb = ImageAsset(name: "flags/flag-gb")
      internal static let flagGd = ImageAsset(name: "flags/flag-gd")
      internal static let flagGe = ImageAsset(name: "flags/flag-ge")
      internal static let flagGf = ImageAsset(name: "flags/flag-gf")
      internal static let flagGg = ImageAsset(name: "flags/flag-gg")
      internal static let flagGh = ImageAsset(name: "flags/flag-gh")
      internal static let flagGi = ImageAsset(name: "flags/flag-gi")
      internal static let flagGl = ImageAsset(name: "flags/flag-gl")
      internal static let flagGm = ImageAsset(name: "flags/flag-gm")
      internal static let flagGn = ImageAsset(name: "flags/flag-gn")
      internal static let flagGp = ImageAsset(name: "flags/flag-gp")
      internal static let flagGq = ImageAsset(name: "flags/flag-gq")
      internal static let flagGr = ImageAsset(name: "flags/flag-gr")
      internal static let flagGs = ImageAsset(name: "flags/flag-gs")
      internal static let flagGt = ImageAsset(name: "flags/flag-gt")
      internal static let flagGu = ImageAsset(name: "flags/flag-gu")
      internal static let flagGw = ImageAsset(name: "flags/flag-gw")
      internal static let flagGy = ImageAsset(name: "flags/flag-gy")
      internal static let flagHk = ImageAsset(name: "flags/flag-hk")
      internal static let flagHm = ImageAsset(name: "flags/flag-hm")
      internal static let flagHn = ImageAsset(name: "flags/flag-hn")
      internal static let flagHr = ImageAsset(name: "flags/flag-hr")
      internal static let flagHt = ImageAsset(name: "flags/flag-ht")
      internal static let flagHu = ImageAsset(name: "flags/flag-hu")
      internal static let flagId = ImageAsset(name: "flags/flag-id")
      internal static let flagIe = ImageAsset(name: "flags/flag-ie")
      internal static let flagIl = ImageAsset(name: "flags/flag-il")
      internal static let flagIm = ImageAsset(name: "flags/flag-im")
      internal static let flagIn = ImageAsset(name: "flags/flag-in")
      internal static let flagIo = ImageAsset(name: "flags/flag-io")
      internal static let flagIq = ImageAsset(name: "flags/flag-iq")
      internal static let flagIr = ImageAsset(name: "flags/flag-ir")
      internal static let flagIs = ImageAsset(name: "flags/flag-is")
      internal static let flagIt = ImageAsset(name: "flags/flag-it")
      internal static let flagJe = ImageAsset(name: "flags/flag-je")
      internal static let flagJm = ImageAsset(name: "flags/flag-jm")
      internal static let flagJo = ImageAsset(name: "flags/flag-jo")
      internal static let flagJp = ImageAsset(name: "flags/flag-jp")
      internal static let flagKe = ImageAsset(name: "flags/flag-ke")
      internal static let flagKg = ImageAsset(name: "flags/flag-kg")
      internal static let flagKh = ImageAsset(name: "flags/flag-kh")
      internal static let flagKi = ImageAsset(name: "flags/flag-ki")
      internal static let flagKm = ImageAsset(name: "flags/flag-km")
      internal static let flagKn = ImageAsset(name: "flags/flag-kn")
      internal static let flagKp = ImageAsset(name: "flags/flag-kp")
      internal static let flagKr = ImageAsset(name: "flags/flag-kr")
      internal static let flagKw = ImageAsset(name: "flags/flag-kw")
      internal static let flagKy = ImageAsset(name: "flags/flag-ky")
      internal static let flagKz = ImageAsset(name: "flags/flag-kz")
      internal static let flagLa = ImageAsset(name: "flags/flag-la")
      internal static let flagLb = ImageAsset(name: "flags/flag-lb")
      internal static let flagLc = ImageAsset(name: "flags/flag-lc")
      internal static let flagLi = ImageAsset(name: "flags/flag-li")
      internal static let flagLk = ImageAsset(name: "flags/flag-lk")
      internal static let flagLr = ImageAsset(name: "flags/flag-lr")
      internal static let flagLs = ImageAsset(name: "flags/flag-ls")
      internal static let flagLt = ImageAsset(name: "flags/flag-lt")
      internal static let flagLu = ImageAsset(name: "flags/flag-lu")
      internal static let flagLv = ImageAsset(name: "flags/flag-lv")
      internal static let flagLy = ImageAsset(name: "flags/flag-ly")
      internal static let flagMa = ImageAsset(name: "flags/flag-ma")
      internal static let flagMc = ImageAsset(name: "flags/flag-mc")
      internal static let flagMd = ImageAsset(name: "flags/flag-md")
      internal static let flagMe = ImageAsset(name: "flags/flag-me")
      internal static let flagMf = ImageAsset(name: "flags/flag-mf")
      internal static let flagMg = ImageAsset(name: "flags/flag-mg")
      internal static let flagMh = ImageAsset(name: "flags/flag-mh")
      internal static let flagMk = ImageAsset(name: "flags/flag-mk")
      internal static let flagMl = ImageAsset(name: "flags/flag-ml")
      internal static let flagMm = ImageAsset(name: "flags/flag-mm")
      internal static let flagMn = ImageAsset(name: "flags/flag-mn")
      internal static let flagMo = ImageAsset(name: "flags/flag-mo")
      internal static let flagMp = ImageAsset(name: "flags/flag-mp")
      internal static let flagMq = ImageAsset(name: "flags/flag-mq")
      internal static let flagMr = ImageAsset(name: "flags/flag-mr")
      internal static let flagMs = ImageAsset(name: "flags/flag-ms")
      internal static let flagMt = ImageAsset(name: "flags/flag-mt")
      internal static let flagMu = ImageAsset(name: "flags/flag-mu")
      internal static let flagMv = ImageAsset(name: "flags/flag-mv")
      internal static let flagMw = ImageAsset(name: "flags/flag-mw")
      internal static let flagMx = ImageAsset(name: "flags/flag-mx")
      internal static let flagMy = ImageAsset(name: "flags/flag-my")
      internal static let flagMz = ImageAsset(name: "flags/flag-mz")
      internal static let flagNa = ImageAsset(name: "flags/flag-na")
      internal static let flagNc = ImageAsset(name: "flags/flag-nc")
      internal static let flagNe = ImageAsset(name: "flags/flag-ne")
      internal static let flagNf = ImageAsset(name: "flags/flag-nf")
      internal static let flagNg = ImageAsset(name: "flags/flag-ng")
      internal static let flagNi = ImageAsset(name: "flags/flag-ni")
      internal static let flagNl = ImageAsset(name: "flags/flag-nl")
      internal static let flagNo = ImageAsset(name: "flags/flag-no")
      internal static let flagNp = ImageAsset(name: "flags/flag-np")
      internal static let flagNr = ImageAsset(name: "flags/flag-nr")
      internal static let flagNu = ImageAsset(name: "flags/flag-nu")
      internal static let flagNz = ImageAsset(name: "flags/flag-nz")
      internal static let flagOm = ImageAsset(name: "flags/flag-om")
      internal static let flagPa = ImageAsset(name: "flags/flag-pa")
      internal static let flagPe = ImageAsset(name: "flags/flag-pe")
      internal static let flagPf = ImageAsset(name: "flags/flag-pf")
      internal static let flagPg = ImageAsset(name: "flags/flag-pg")
      internal static let flagPh = ImageAsset(name: "flags/flag-ph")
      internal static let flagPk = ImageAsset(name: "flags/flag-pk")
      internal static let flagPl = ImageAsset(name: "flags/flag-pl")
      internal static let flagPm = ImageAsset(name: "flags/flag-pm")
      internal static let flagPn = ImageAsset(name: "flags/flag-pn")
      internal static let flagPr = ImageAsset(name: "flags/flag-pr")
      internal static let flagPs = ImageAsset(name: "flags/flag-ps")
      internal static let flagPt = ImageAsset(name: "flags/flag-pt")
      internal static let flagPw = ImageAsset(name: "flags/flag-pw")
      internal static let flagPy = ImageAsset(name: "flags/flag-py")
      internal static let flagQa = ImageAsset(name: "flags/flag-qa")
      internal static let flagRe = ImageAsset(name: "flags/flag-re")
      internal static let flagRo = ImageAsset(name: "flags/flag-ro")
      internal static let flagRs = ImageAsset(name: "flags/flag-rs")
      internal static let flagRu = ImageAsset(name: "flags/flag-ru")
      internal static let flagRw = ImageAsset(name: "flags/flag-rw")
      internal static let flagSa = ImageAsset(name: "flags/flag-sa")
      internal static let flagSb = ImageAsset(name: "flags/flag-sb")
      internal static let flagSc = ImageAsset(name: "flags/flag-sc")
      internal static let flagSd = ImageAsset(name: "flags/flag-sd")
      internal static let flagSe = ImageAsset(name: "flags/flag-se")
      internal static let flagSg = ImageAsset(name: "flags/flag-sg")
      internal static let flagSh = ImageAsset(name: "flags/flag-sh")
      internal static let flagSi = ImageAsset(name: "flags/flag-si")
      internal static let flagSj = ImageAsset(name: "flags/flag-sj")
      internal static let flagSk = ImageAsset(name: "flags/flag-sk")
      internal static let flagSl = ImageAsset(name: "flags/flag-sl")
      internal static let flagSm = ImageAsset(name: "flags/flag-sm")
      internal static let flagSn = ImageAsset(name: "flags/flag-sn")
      internal static let flagSo = ImageAsset(name: "flags/flag-so")
      internal static let flagSr = ImageAsset(name: "flags/flag-sr")
      internal static let flagSs = ImageAsset(name: "flags/flag-ss")
      internal static let flagSt = ImageAsset(name: "flags/flag-st")
      internal static let flagSv = ImageAsset(name: "flags/flag-sv")
      internal static let flagSx = ImageAsset(name: "flags/flag-sx")
      internal static let flagSy = ImageAsset(name: "flags/flag-sy")
      internal static let flagSz = ImageAsset(name: "flags/flag-sz")
      internal static let flagTc = ImageAsset(name: "flags/flag-tc")
      internal static let flagTd = ImageAsset(name: "flags/flag-td")
      internal static let flagTf = ImageAsset(name: "flags/flag-tf")
      internal static let flagTg = ImageAsset(name: "flags/flag-tg")
      internal static let flagTh = ImageAsset(name: "flags/flag-th")
      internal static let flagTj = ImageAsset(name: "flags/flag-tj")
      internal static let flagTk = ImageAsset(name: "flags/flag-tk")
      internal static let flagTl = ImageAsset(name: "flags/flag-tl")
      internal static let flagTm = ImageAsset(name: "flags/flag-tm")
      internal static let flagTn = ImageAsset(name: "flags/flag-tn")
      internal static let flagTo = ImageAsset(name: "flags/flag-to")
      internal static let flagTr = ImageAsset(name: "flags/flag-tr")
      internal static let flagTt = ImageAsset(name: "flags/flag-tt")
      internal static let flagTv = ImageAsset(name: "flags/flag-tv")
      internal static let flagTw = ImageAsset(name: "flags/flag-tw")
      internal static let flagTz = ImageAsset(name: "flags/flag-tz")
      internal static let flagUa = ImageAsset(name: "flags/flag-ua")
      internal static let flagUg = ImageAsset(name: "flags/flag-ug")
      internal static let flagUm = ImageAsset(name: "flags/flag-um")
      internal static let flagUn = ImageAsset(name: "flags/flag-un")
      internal static let flagUniversal = ImageAsset(name: "flags/flag-universal")
      internal static let flagUs = ImageAsset(name: "flags/flag-us")
      internal static let flagUy = ImageAsset(name: "flags/flag-uy")
      internal static let flagUz = ImageAsset(name: "flags/flag-uz")
      internal static let flagVa = ImageAsset(name: "flags/flag-va")
      internal static let flagVc = ImageAsset(name: "flags/flag-vc")
      internal static let flagVe = ImageAsset(name: "flags/flag-ve")
      internal static let flagVg = ImageAsset(name: "flags/flag-vg")
      internal static let flagVi = ImageAsset(name: "flags/flag-vi")
      internal static let flagVn = ImageAsset(name: "flags/flag-vn")
      internal static let flagVu = ImageAsset(name: "flags/flag-vu")
      internal static let flagWf = ImageAsset(name: "flags/flag-wf")
      internal static let flagWs = ImageAsset(name: "flags/flag-ws")
      internal static let flagYe = ImageAsset(name: "flags/flag-ye")
      internal static let flagYt = ImageAsset(name: "flags/flag-yt")
      internal static let flagZa = ImageAsset(name: "flags/flag-za")
      internal static let flagZm = ImageAsset(name: "flags/flag-zm")
      internal static let flagZw = ImageAsset(name: "flags/flag-zw")
    }
    internal static let forceUpdateShield = ImageAsset(name: "force_update_shield")
    internal static let icon3dtConnect = ImageAsset(name: "icon-3dt-connect")
    internal static let icon3dtDisconnect = ImageAsset(name: "icon-3dt-disconnect")
    internal static let icon3dtSelectRegion = ImageAsset(name: "icon-3dt-select-region")
    internal static let iconAbout1 = ImageAsset(name: "icon-about-1")
    internal static let iconAccount = ImageAsset(name: "icon-account")
    internal static let iconAdd = ImageAsset(name: "icon-add")
    internal static let iconAlert = ImageAsset(name: "icon-alert")
    internal static let iconAutomation = ImageAsset(name: "icon-automation")
    internal static let iconClose = ImageAsset(name: "icon-close")
    internal static let iconContact = ImageAsset(name: "icon-contact")
    internal static let iconDip = ImageAsset(name: "icon-dip")
    internal static let iconGeneral = ImageAsset(name: "icon-general")
    internal static let iconGeoDarkSelected = ImageAsset(name: "icon-geo-dark-selected")
    internal static let iconGeoDark = ImageAsset(name: "icon-geo-dark")
    internal static let iconGeoSelected = ImageAsset(name: "icon-geo-selected")
    internal static let iconGeo = ImageAsset(name: "icon-geo")
    internal static let iconHomepage = ImageAsset(name: "icon-homepage")
    internal static let iconLogout = ImageAsset(name: "icon-logout")
    internal static let iconNetwork = ImageAsset(name: "icon-network")
    internal static let iconPrivacy1 = ImageAsset(name: "icon-privacy-1")
    internal static let iconProtocols = ImageAsset(name: "icon-protocols")
    internal static let iconRegion = ImageAsset(name: "icon-region")
    internal static let iconRemove = ImageAsset(name: "icon-remove")
    internal static let iconSettings = ImageAsset(name: "icon-settings")
    internal static let iconThumbsDown = ImageAsset(name: "icon-thumbs-down")
    internal static let iconThumbsUp = ImageAsset(name: "icon-thumbs-up")
    internal static let iconTrashDark = ImageAsset(name: "icon-trash-dark")
    internal static let iconTrash = ImageAsset(name: "icon-trash")
    internal static let iconWarning = ImageAsset(name: "icon-warning")
    internal static let iconWifi = ImageAsset(name: "icon-wifi")
    internal static let iconmenuAbout = ImageAsset(name: "iconmenu-about")
    internal static let iconmenuPrivacy = ImageAsset(name: "iconmenu-privacy")
    internal static let imageAccessCard = ImageAsset(name: "image-access-card")
    internal static let imageContentBlocker = ImageAsset(name: "image-content-blocker")
    internal static let imagePurchaseSuccess = ImageAsset(name: "image-purchase-success")
    internal static let imageRobot = ImageAsset(name: "image-robot")
    internal static let imageVpnAllow = ImageAsset(name: "image-vpn-allow")
    internal static let itemMenu = ImageAsset(name: "item-menu")
    internal static let navLogoWhite = ImageAsset(name: "nav-logo-white")
    internal static let navLogo = ImageAsset(name: "nav-logo")
    internal static let offlineServerIcon = ImageAsset(name: "offline-server-icon")
    internal static let shareIcon = ImageAsset(name: "share-icon")
  }
  internal enum Ui {
    internal enum Piax {
      internal enum Global {
        internal static let centeredDarkMap = ImageAsset(name: "PIAX/Global/centered-dark-map")
        internal static let centeredLightMap = ImageAsset(name: "PIAX/Global/centered-light-map")
        internal static let computerIcon = ImageAsset(name: "PIAX/Global/computer-icon")
        internal static let globeIcon = ImageAsset(name: "PIAX/Global/globe-icon")
        internal static let iconBack = ImageAsset(name: "PIAX/Global/icon-back")
        internal static let iconCamera = ImageAsset(name: "PIAX/Global/icon-camera")
        internal static let iconClose = ImageAsset(name: "PIAX/Global/icon-close")
        internal static let iconWarning = ImageAsset(name: "PIAX/Global/icon-warning")
        internal static let pagecontrolSelectedDot = ImageAsset(name: "PIAX/Global/pagecontrol-selected-dot")
        internal static let pagecontrolUnselectedDot = ImageAsset(name: "PIAX/Global/pagecontrol-unselected-dot")
        internal static let planSelected = ImageAsset(name: "PIAX/Global/plan-selected")
        internal static let planUnselected = ImageAsset(name: "PIAX/Global/plan-unselected")
        internal static let scrollableMapDark = ImageAsset(name: "PIAX/Global/scrollableMap-dark")
        internal static let scrollableMapLight = ImageAsset(name: "PIAX/Global/scrollableMap-light")
        internal static let shieldIcon = ImageAsset(name: "PIAX/Global/shield-icon")
      }
    }
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
    internal static let piaSpinner = ImageAsset(name: "pia-spinner")
    internal static let qrCode = ImageAsset(name: "qr-code")
  }
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

  @available(watchOS 2.0, macOS 10.7, *)
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
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
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
internal extension SwiftUI.Image {
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
