
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
    
    static func makePIAConnectionButton() -> PIAConnectionButton {
        return PIAConnectionButton(
            viewModel: makePIAConnectionButtonViewModel()
        )
    }
    
}

// MARK: Private

extension DashboardFactory {
    private static func makePIAConnectionButtonViewModel() -> PIAConnectionButtonViewModel {
        return PIAConnectionButtonViewModel(useCase: VpnConnectionFactory.makeVpnConnectionUseCase, connectionStateMonitor: StateMonitorsFactory.makeConnectionStateMonitor)
    }
    

    
    private static func makeSelectedServerUserCase() -> SelectedServerUseCaseType {
        return SelectedServerUseCase(serverProvider: VpnConnectionFactory.makeServerProvider(), clientPreferences: RegionsSelectionFactory.makeClientPreferences)
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
    

    
    static internal func makeQuickConnectButtonViewModel(for server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) -> QuickConnectButtonViewModel {
        QuickConnectButtonViewModel(server: server, delegate: delegate)
    }
    
    static func makeQuickConnectButton(for server: ServerType, delegate: QuickConnectButtonViewModelDelegate?) -> QuickConnectButton {
        QuickConnectButton(viewModel: makeQuickConnectButtonViewModel(for: server, delegate: delegate))
    }
    
    static internal func makeQuickConnectViewModel() -> QuickConnectViewModel {
        QuickConnectViewModel(connectUseCase: VpnConnectionFactory.makeVpnConnectionUseCase, selectedServerUseCase: makeSelectedServerUserCase())
    }
    
    static func makeQuickConnectView() -> QuickConnectView {
        QuickConnectView(viewModel: makeQuickConnectViewModel())
    }
    
}
