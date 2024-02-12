
import Foundation


class SelectedServerViewModel: ObservableObject {
    let selectedSeverSectionTitle = L10n.Localizable.Tiles.Region.title.uppercased()
    @Published var serverName: String = ""
    
    let useCase: SelectedServerUseCaseType
    
    init(useCase: SelectedServerUseCaseType) {
        self.useCase = useCase
        updateState()
    }
    
    private func updateState() {
        useCase.getSelectedServer()
            .map { $0.name }
            .assign(to: &$serverName)
    }
    
}
