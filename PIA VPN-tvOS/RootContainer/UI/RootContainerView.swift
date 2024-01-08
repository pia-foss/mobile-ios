
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
                // TODO: Replace this view with the Onboarding Vpn Profile installation view
                VStack {
                    Text("Show Onboarding vpn installation view")
                    Button {
                        viewModel.installVpnProfile()
                    } label: {
                        Text("Install Vpn profile")
                    }

                }
            case .activated:
                DashboardFactory.makeDashboardView()

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

