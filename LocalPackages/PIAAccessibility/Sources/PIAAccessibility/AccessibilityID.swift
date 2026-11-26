/// Every accessibility identifier the apps set and the UI tests query.
///
/// This is the only place identifiers are defined: views set them from here and the UI tests find
/// elements through here, so the two cannot drift apart. Rules:
/// - Never reuse a value for two elements, even on different screens.
/// - New identifiers follow `id.<screen>.<element>`. Older values keep their historical spelling.
public enum AccessibilityID {
    public enum AccountDetails {
        public static let screen = "id.accountDetails.screen"
        public static let username = "id.accountDetails.username"
        public static let expiry = "id.accountDetails.expiry"
        public static let manageSubscription = "id.accountDetails.manageSubscription.button"
        public static let restore = "id.accountDetails.restore.button"
        public static let deleteAccount = "id.accountDetails.delete.button"
    }

    public enum AddEmail {
        public static let screen = "id.addEmail.screen"
        public static let email = "id.addEmail.email.field"
        public static let submit = "id.addEmail.submit.button"
        public static let signInWithApple = "id.addEmail.signInWithApple.button"
        public static let logout = "id.addEmail.logout.button"
        public static let successMessage = "id.addEmail.success.message"
        public static let username = "id.addEmail.username"
        public static let password = "id.addEmail.password"
        public static let close = "id.addEmail.close.button"
    }

    public enum Consent {
        public static let accept = "id.consent.accept"
        public static let noThanks = "id.consent.noThanks"
        public static let readMore = "id.consent.readMore"
        public static let readMoreClose = "id.consent.readMore.close"
    }

    public enum Dashboard {
        public static let menu = "id.dashboard.menu"
        public static let connectionButton = "id.dashboard.connection.button"
    }

    public enum DebugReport {
        public static let sendButton = "debugReportSendButton"
        public static let shareButton = "debugReportShareButton"

        /// The header of the report section with the given `id`.
        public static func section(_ id: String) -> String {
            "debugReportSection.\(id)"
        }
    }

    public enum DedicatedIP {
        public static let row = "DedicatedIpRow"
    }

    public enum Dialog {
        public static let destructive = "id.dialog.destructive.button"
    }

    public enum ForceUpdate {
        public static let screen = "ForceUpdateScreen"
        public static let updateButton = "ForceUpdateScreenUpdateButton"
        public static let vpnConnectedHint = "ForceUpdateScreenVPNConnectedHint"
    }

    public enum GDPR {
        public static let screen = "GDPRScreen"
        public static let acceptButton = "GDPRScreenAcceptButton"
        public static let closeButton = "GDPRScreenCloseButton"
    }

    public enum Login {
        public static let submit = "id.login.submit"
        public static let username = "id.login.username"
        public static let password = "id.login.password"
        public static let errorBanner = "id.login.error.banner"
    }

    /// One per side menu row.
    public enum Menu {
        public static let selectRegion = "id.menu.selectRegion"
        public static let account = "id.menu.account"
        public static let dedicatedIP = "id.menu.dedicatedIp"
        public static let settings = "id.menu.settings"
        public static let logout = "id.menu.logout"
        public static let homepage = "id.menu.homepage"
        public static let support = "id.menu.support"
        public static let about = "id.menu.about"
        public static let privacy = "id.menu.privacy"
        public static let version = "id.menu.version"
    }

    public enum Paywall {
        public static let subscribeButton = "id.paywall.subscribe"
        public static let otherPlansButton = "id.paywall.other_plans"
        public static let restoreButton = "id.paywall.restore"
        public static let loginButton = "id.paywall.login"
        public static let sheetSubscribeButton = "id.paywall.sheet.subscribe"
        public static let maybeLaterButton = "id.paywall.sheet.maybe_later"
    }

    public enum PlatformSDKMigration {
        public static let confirm = "id.platformSDKMigration.confirm"
    }

    public enum RegionList {
        public static let region = "uitests.regions.region_name"
        public static let emptyBackground = "empty set background image"
    }

    public enum RestoreSignup {
        public static let email = "id.restoreSignup.email"
        public static let submit = "id.restoreSignup.submit"
    }

    /// The dashboard tiles: each tile's view, and the collection view cell that hosts it.
    public enum Tiles {
        public static let connectionCell = "ConnectionTileCollectionViewCell"
        public static let favoriteServers = "FavoriteServersTile"
        public static let favoriteServersCell = "FavoriteServersTileCollectionViewCell"
        public static let feedback = "FeedbackTile"
        public static let feedbackCell = "FeedbackTileCollectionViewCell"
        public static let ip = "IPTile"
        public static let ipCell = "IPTileCollectionViewCell"
        public static let promoOffer = "PromoOfferTile"
        public static let promoOfferCell = "PromoOfferTileCollectionViewCell"
        public static let quickConnectCell = "QuickConnectTileCollectionViewCell"
        public static let quickSettingsCell = "QuickSettingsTileCollectionViewCell"
        public static let region = "RegionTile"
        public static let regionCell = "RegionTileCollectionViewCell"
        public static let subscription = "SubscriptionTile"
        public static let subscriptionCell = "SubscriptionTileCollectionViewCell"
        public static let usage = "UsageTile"
        public static let usageCell = "UsageTileCollectionViewCell"
    }

    public enum ValidateQRLogin {
        /// Its value is the current phase: `idle`, `confirming`, `validating`, `failed` or `finished`.
        public static let screenBackground = "ValidateQRLoginScreenBackground"
        public static let loadingIndicator = "ValidateQRLoginScreenLoadingIndicator"
        public static let confirmButton = "ValidateQRLoginScreenConfirmButton"
        public static let cancelButton = "ValidateQRLoginScreenCancelButton"
        public static let errorDismissButton = "ValidateQRLoginScreenErrorDismissButton"
    }

    public enum VPNPermission {
        public static let screen = "id.vpnPermission.screen"
        public static let submit = "id.vpnPermission.ok.button"
    }

    public enum WelcomeBack {
        public static let appStoreButton = "id.welcome_back.app_store"
        public static let credentialsButton = "id.welcome_back.credentials"
        public static let qrCodeButton = "id.welcome_back.qr_code"
        public static let closeButton = "id.welcome_back.close"
    }
}
