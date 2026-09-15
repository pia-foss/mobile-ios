//
//  View+SwitchToAutomaticPrompt.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

private struct SwitchToAutomaticPromptModifier: ViewModifier {
    @StateObject private var viewModel: SwitchToAutomaticPromptViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: SwitchToAutomaticPromptViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    func body(content: Content) -> some View {
        content
            .alert(viewModel.title, isPresented: $viewModel.isPresented) {
                Button(viewModel.dismissTitle, role: .cancel) {
                    viewModel.promptWasDismissed()
                }
                Button(viewModel.acceptTitle, role: .none) {
                    viewModel.switchToAutomaticWasTapped()
                }
            } message: {
                Text(viewModel.message)
            }
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                if newPhase == .active {
                    viewModel.sceneDidBecomeActive()
                } else {
                    viewModel.sceneDidBecomeInactive()
                }
            }
    }
}

extension View {
    @MainActor
    func withSwitchToAutomaticPrompt() -> some View {
        modifier(SwitchToAutomaticPromptModifier(viewModel: SwitchToAutomaticPromptFactory.makePromptViewModel))
    }
}
