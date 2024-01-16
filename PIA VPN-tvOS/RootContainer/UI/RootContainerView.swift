
import Foundation
import SwiftUI

struct RootContainerView: View {
    @ObservedObject var viewModel: RootContainerViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .splash:
                VStack {
                    // TODO: Add Splash screen here
                }
            case .notActivated:
                LoginFactory.makeLoginView()
            case .activatedNotOnboarded:
                VPNConfigurationInstallingFactory.makeVPNConfigurationInstallingView()
            case .activated:
                UserActivatedContainerFactory.makeUSerActivatedContainerView()
            }
        }.onChange(of: scenePhase) { newPhase in
            
            if newPhase == .active {
                NSLog(">>> Active")
                viewModel.phaseDidBecomeActive()
            } else if newPhase == .inactive {
                NSLog(">>> Inactive")
            } else if newPhase == .background {
                NSLog(">>> Background")
            }
        }
    }
}

