
import Foundation
import PIALibrary

class DashboardFactory {
    
    static func makeDashboardView() -> DashboardView {
        return DashboardView(
            viewModel: makeDashboardViewModel(), 
            connectionButton: makePIAConnectionButton()
        )
    }
    
    static func makeDashboardViewModel() -> DashboardViewModel {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        return DashboardViewModel(accountProvider: defaultAccountProvider)
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
        return VpnConnectionUseCase()
    }
    
}
