
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
        return DashboardViewModel(accountProvider: Client.providers.accountProvider)
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
