import PIADebugMenu
import PIALibrary
import SwiftUI

@available(tvOS 17, *)
private struct DebugMenuModifier: ViewModifier {
    @State private var showingDebugMenu = false

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .fullScreenCover(isPresented: $showingDebugMenu) {
                    NavigationStack {
                        DebugMenuView(
                            dependencies: .live(emit: { output in
                                switch output {
                                case .dismiss: showingDebugMenu = false
                                }
                            })
                        )
                    }
                }
                .onPlayPauseCommand { showingDebugMenu = true }
        } else {
            content
        }
    }

    private var isEnabled: Bool {
        #if DEBUG || STAGING
            return true
        #else
            return TestFlightDetector.isTestFlight
        #endif
    }
}

extension View {
    func withDebugMenu() -> some View {
        modifier(DebugMenuModifier())
    }
}
