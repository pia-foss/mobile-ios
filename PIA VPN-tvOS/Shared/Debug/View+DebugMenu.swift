import SwiftUI
import PIADebugMenu
import PIALibrary

@available(tvOS 17, *)
private struct DebugMenuModifier: ViewModifier {
    @State private var showingDebugMenu = false

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .fullScreenCover(isPresented: $showingDebugMenu) {
                    NavigationStack {
                        DebugMenuView(onDismiss: { showingDebugMenu = false })
                    }
                }
                .onPlayPauseCommand { showingDebugMenu = true }
        } else {
            content
        }
    }

    private var isEnabled: Bool {
        #if DEVELOPMENT || STAGING
        return true
        #else
        return TestFlightDetector.shared.isTestFlight
        #endif
    }
}

extension View {
    func withDebugMenu() -> some View {
        modifier(DebugMenuModifier())
    }
}
