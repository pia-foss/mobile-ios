
import Foundation
import PIALibrary

class RootContainerFactory {
  static func makeRootContainerView() -> RootContainerView {
    RootContainerView(viewModel: makeRootContainerViewModel())
  }
  
  private static func makeRootContainerViewModel() -> RootContainerViewModel {
    return RootContainerViewModel(accountProvider: Client.providers.accountProvider)
  }
}
