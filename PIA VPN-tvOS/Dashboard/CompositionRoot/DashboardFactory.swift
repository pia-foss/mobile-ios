
import Foundation
import PIALibrary

class DashboardFactory {
    
    static func makeDashboardView() -> DashboardView {
        return DashboardView(viewModel: makeDashboardViewModel())
    }
    
    static func makeDashboardViewModel() -> DashboardViewModel {
        return DashboardViewModel(connectionStateMonitor: StateMonitorsFactory.makeConnectionStateMonitor)
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
    

    static var makeSelectedServerUserCase: SelectedServerUseCaseType = {
        return SelectedServerUseCase(serverProvider: VpnConnectionFactory.makeServerProvider(), clientPreferences: RegionsSelectionFactory.makeClientPreferences)
    }()
    
    private static func makeSelectedServerViewModel() -> SelectedServerViewModel {
        return SelectedServerViewModel(
            useCase: makeSelectedServerUserCase,
            optimalLocationUseCase: RegionsSelectionFactory.makeOptimalLocationUseCase,
            regionsDisplayNameUseCase: RegionsSelectionFactory.makeRegionsDisplayNameUseCase(), getDedicatedIpUseCase: DedicatedIPFactory.makeGetDedicatedIpUseCase(),
            routerAction: .navigate(router: AppRouterFactory.makeAppRouter(), destination: RegionsDestinations.serversList))
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
        QuickConnectViewModel(selectedServerUseCase: makeSelectedServerUserCase, regionsUseCase: RegionsSelectionFactory.makeRegionsListUseCase())
    }
    
    static func makeQuickConnectView() -> QuickConnectView {
        QuickConnectView(viewModel: makeQuickConnectViewModel())
    }
    
}
