
import Foundation

class DashboardFactory {
    
    static func makeDashboardView() -> DashboardView {
        return DashboardView(
            connectionButton: makePIAConnectionButton()
        )
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
