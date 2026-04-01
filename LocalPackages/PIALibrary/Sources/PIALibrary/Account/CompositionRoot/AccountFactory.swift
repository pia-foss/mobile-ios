
import Foundation

public class AccountFactory {
    public static func makeLoginUseCase() -> LoginUseCaseType {
        LoginUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), apiTokenProvider: makeAPITokenProvider(), refreshVpnTokenUseCase: makeRefreshVpnTokenUseCase())
    }
    
    public static func makeGenerateQRLoginUseCase() -> GenerateQRLoginUseCaseType {
        GenerateQRLoginUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient())
    }
    
    public static func makeLogoutUseCase() -> LogoutUseCaseType {
        LogoutUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), apiTokenProvider: makeAPITokenProvider(), vpnTokenProvider: makeVpnTokenProvider(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker())
    }
    
    public static func makeAccountDetailsUseCase() -> AccountDetailsUseCaseType {
        
        AccountDetailsUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker(), accountInforDecoder: makeAccountInfoDecoder())
    }
    
    public static func makeSignupUseCase() -> SignupUseCaseType {
        SignupUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(),
                      signupInformationDataCoverter: SignupInformationDataCoverter())
    }
    
    public static func makeUpdateAccountUseCase() -> UpdateAccountUseCaseType {
        UpdateAccountUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker())
    }
    
    static func makePaymentUseCase() -> PaymentUseCaseType {
        PaymentUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), paymentInformationDataConverter: makePaymentInformationDataConverter())
    }
    
    static func makeSubscriptionsUseCase() -> SubscriptionsUseCaseType {
        SubscriptionsUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker())
    }
    
    static func makeNativeAccountProvider(with webServices: WebServices? = nil) -> NativeAccountProvider {
        NativeAccountProvider(
            webServices: webServices,
            logoutUseCase: makeLogoutUseCase(),
            loginUseCase: makeLoginUseCase(),
            signupUseCase: makeSignupUseCase(),
            apiTokenProvider: makeAPITokenProvider(),
            vpnTokenProvider: makeVpnTokenProvider(),
            accountDetailsUseCase: makeAccountDetailsUseCase(),
            updateAccountUseCase: makeUpdateAccountUseCase(),
            paymentUseCase: makePaymentUseCase(),
            subscriptionsUseCase: makeSubscriptionsUseCase(),
            deleteAccountUseCase: makeDeleteAccountUseCase(),
            featureFlagsUseCase: makeFeatureFlagsUseCase()
        )
    }
    
    static func makeDefaultAccountProvider(with webServices: WebServices? = nil) -> DefaultAccountProvider {
        DefaultAccountProvider(apiTokenProvider: makeAPITokenProvider(), 
                               vpnTokenProvider: makeVpnTokenProvider())
    }
    
    
    
    static func makeRefreshAPITokenUseCase() -> RefreshAPITokenUseCaseType {
        RefreshAPITokenUseCase(apiTokenProvider: makeAPITokenProvider(), networkClient: NetworkRequestFactory.maketNetworkRequestClient())
    }
    
    static func makeRefreshVpnTokenUseCase() -> RefreshVpnTokenUseCaseType {
        RefreshVpnTokenUseCase(vpnTokenProvider: makeVpnTokenProvider(), networkClient: NetworkRequestFactory.maketNetworkRequestClient())
        
    }
    
    static func makeAPITokenProvider() -> APITokenProviderType {
        apitokenProviderShared
    }
    
    static func makeVpnTokenProvider() -> VpnTokenProviderType {
        vpnTokenProviderShared
    }
    
    static func makeRefreshAuthTokensChecker() -> RefreshAuthTokensCheckerType {
        refreshAuthTokensCheckerShared
    }
    
    static func makeFeatureFlagsUseCase() -> FeatureFlagsUseCaseType {
        FeatureFlagsUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker())
    }
    
    public static func makeClientStatusUseCase() -> ClientStatusUseCaseType {
        ClientStatusUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokensChecker: makeRefreshAuthTokensChecker(), clientStatusDecoder: makeClientStatusInfoDecoder())
    }
}

// MARK: - Private

private extension AccountFactory {
    
    static var apitokenProviderShared: APITokenProviderType = {
        APITokenProvider(keychainStore: makeSecureStore(), tokenSerializer: makeAuthTokenSerializer())
    }()
    
    static var vpnTokenProviderShared: VpnTokenProviderType = {
        VpnTokenProvider(keychainStore: makeSecureStore(), tokenSerializer: makeAuthTokenSerializer())
    }()
    
    static var secureStoreShared: SecureStore = {
        KeychainStore(team: Client.Configuration.teamId, group: Client.Configuration.appGroup)
    }()
    
    static var refreshAuthTokensCheckerShared: RefreshAuthTokensCheckerType = {
        RefreshAuthTokensChecker(apiTokenProvider: makeAPITokenProvider(), vpnTokenProvier: makeVpnTokenProvider(), refreshAPITokenUseCase: makeRefreshAPITokenUseCase(), refreshVpnTokenUseCase: makeRefreshVpnTokenUseCase())
    }()
    
    static func makeSecureStore() -> SecureStore {
        secureStoreShared
    }
    
    static func makeAuthTokenSerializer() -> AuthTokenSerializerType {
        AuthTokenSerializer()
    }
    
    static func makeAccountInfoDecoder() -> AccountInfoDecoderType {
        AccountInfoDecoder()
    }
    
    static func makeClientStatusInfoDecoder() -> ClientStatusInformationDecoderType {
        ClientStatusInformationDecoder()
    }
    
    static func makePaymentInformationDataConverter() -> PaymentInformationDataConverterType {
        PaymentInformationDataConverter()
    }
    
    static func makeDeleteAccountUseCase() -> DeleteAccountUseCaseType {
        DeleteAccountUseCase(networkClient: NetworkRequestFactory.maketNetworkRequestClient(), refreshAuthTokenChecker: makeRefreshAuthTokensChecker(), apiTokenProvider: makeAPITokenProvider(), vpnTokenProvider: makeVpnTokenProvider())
    }
    
}
