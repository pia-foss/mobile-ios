
import Foundation


class SelectedServerViewModel: ObservableObject {

    
    let useCase: SelectedServerUseCaseType
    let routerAction: AppRouter.Actions
    @Published var selectedServer: ServerType?
    
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
    
    var selectedServerSubtitle: String {
        guard let selectedServer else { return "" }
        return selectedServer.name
    }
    
    init(useCase: SelectedServerUseCaseType, routerAction: AppRouter.Actions) {
        self.useCase = useCase
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
            .map{ $0 }
            .assign(to: &$selectedServer)
    }
    
}
