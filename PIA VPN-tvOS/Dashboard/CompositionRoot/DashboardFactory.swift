
import Foundation
import PIALibrary

class DashboardFactory {
    
    static func makeDashboardView() -> DashboardView {
        return DashboardView(viewModel: makeDashboardViewModel())
    }
    
    static func makeDashboardViewModel() -> DashboardViewModel {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        return DashboardViewModel(accountProvider: defaultAccountProvider, appRouter: AppRouterFactory.makeAppRouter(), navigationDestination: RegionsDestinations.serversList)
    }
    
    static func makePIAConnectionButton(size: CGFloat = 160, lineWidth: CGFloat = 6) -> PIAConnectionButton {
        return PIAConnectionButton(
            size: size,
            lineWidth: lineWidth,
            viewModel: makePIAConnectionButtonViewModel()
        )
    }
    
}

// MARK: Private

extension DashboardFactory {
    private static func makePIAConnectionButtonViewModel() -> PIAConnectionButtonViewModel {
        return PIAConnectionButtonViewModel(useCase: makeVpnConnectionUseCase())
    }
    
    private static func makeVpnConnectionUseCase() -> VpnConnectionUseCaseType {
        return VpnConnectionUseCase(serverProvider: makeServerProvider())
    }
    
    private static func makeSelectedServerUserCase() -> SelectedServerUseCaseType {
        return SelectedServerUseCase(serverProvider: makeServerProvider(), clientPreferences: Client.preferences)
    }
    
    private static func makeSelectedServerViewModel() -> SelectedServerViewModel {
        return SelectedServerViewModel(useCase: makeSelectedServerUserCase())
    }
    
    internal static func makeSelectedServerView() -> SelectedServerView {
        SelectedServerView(viewModel: makeSelectedServerViewModel())
    }
    
}


// MARK: QuickConnect section

extension DashboardFactory {
    
    static func makeServerProvider() -> ServerProviderType {
        guard let defaultServerProvider: DefaultServerProvider =
                Client.providers.serverProvider as? DefaultServerProvider else {
            fatalError("Incorrect server provider type")
        }
        
        return defaultServerProvider
        
    }
    
    static internal func makeQuickConnectButtonViewModel(for server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) -> QuickConnectButtonViewModel {
        QuickConnectButtonViewModel(server: server, delegate: delegate)
    }
    
    static func makeQuickConnectButton(for server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) -> QuickConnectButton {
        QuickConnectButton(viewModel: makeQuickConnectButtonViewModel(for: server, delegate: delegate))
    }
    
    static internal func makeQuickConnectViewModel() -> QuickConnectViewModel {
        QuickConnectViewModel(connectUseCase: makeVpnConnectionUseCase(), selectedServerUseCase: makeSelectedServerUserCase())
    }
    
    static func makeQuickConnectView() -> QuickConnectView {
        QuickConnectView(viewModel: makeQuickConnectViewModel())
    }
    
}
