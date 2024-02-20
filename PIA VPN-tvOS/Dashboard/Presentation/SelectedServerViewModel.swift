
import Foundation
import PIALibrary
import Combine


class SelectedServerViewModel: ObservableObject {

    private let useCase: SelectedServerUseCaseType
    private let optimalLocationUseCase: OptimalLocationUseCaseType
    private let regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType
    
    let routerAction: AppRouter.Actions
    @Published var selectedServer: ServerType?
    private var cancellables = Set<AnyCancellable>()
    
    var selectedSeverTitle: String  {
        let genericTitle = L10n.Localizable.LocationSelection.AnyOtherLocation.title
        guard let selectedServer else {
            return genericTitle
        }
        if selectedServer.isAutomatic {
            return L10n.Localizable.LocationSelection.OptimalLocation.title
        } else {
            return genericTitle
        }
    }
    
    @Published var selectedServerSubtitle = ""
    
    init(useCase: SelectedServerUseCaseType, optimalLocationUseCase: OptimalLocationUseCaseType, regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType,
         routerAction: AppRouter.Actions) {
        self.useCase = useCase
        self.optimalLocationUseCase = optimalLocationUseCase
        self.regionsDisplayNameUseCase = regionsDisplayNameUseCase
        self.routerAction = routerAction
        updateState()
    }
    
    private var focusedAutomaticServerIconName: String {
        .smart_location_icon_highlighted_name
    }
    
    private var unfocusedAutomaticServerIconName: String {
        .smart_location_icon_name
    }
    
    func iconImageNameFor(focused: Bool) -> String {
        guard let currentServer = selectedServer else { return "" }
        if currentServer.isAutomatic {
          let autoIcon =  focused ? focusedAutomaticServerIconName : unfocusedAutomaticServerIconName
            return autoIcon
        } else {
            return "flag-\(currentServer.country.lowercased())"
        }
    }
    
    func selectedServerSectionWasTapped() {
        routerAction.callAsFunction()
    }
    
    private func updateState() {
        useCase.getSelectedServer()
            .combineLatest(optimalLocationUseCase.getTargetLocaionForOptimalLocation()) { (newSelectedServer, newTargetLocation) in
            return (selectedServer: newSelectedServer, targetLocation: newTargetLocation)
        }
        .receive(on: RunLoop.main)
        .sink { [weak self] result in
            guard let self else { return }
            self.selectedServer = result.selectedServer
            self.updateSelectedServerSubtitle(for: result.selectedServer, targetLocation: result.targetLocation)
        }.store(in: &cancellables)
        
    }
    
    private func updateSelectedServerSubtitle(for selectedServer: ServerType, targetLocation: ServerType?) {
        if selectedServer.isAutomatic {
            let displayName = regionsDisplayNameUseCase.getDisplayNameForOptimalLocation(with: targetLocation)
            selectedServerSubtitle = displayName.subtitle
        } else {
            self.selectedServerSubtitle = regionsDisplayNameUseCase.getDisplayName(for: selectedServer).subtitle
        }
    }
    
    
}
