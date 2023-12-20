
import Foundation
import PIALibrary

class RootContainerFactory {
    static func makeRootContainerView() -> RootContainerView {
        RootContainerView(viewModel: makeRootContainerViewModel())
    }
    
    private static func makeRootContainerViewModel() -> RootContainerViewModel {
        guard let defaultAccountProvider = Client.providers.accountProvider as? DefaultAccountProvider else {
            fatalError("Incorrect account provider type")
        }
        return RootContainerViewModel(accountProvider: defaultAccountProvider)
    }
}
