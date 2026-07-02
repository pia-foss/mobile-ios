import Combine
import Foundation
import PIAAssetsTV
import PIADashboard
import PIALibrary
import PIALocalizations
import SwiftUI

final class SelectedServerViewModel: ObservableObject {

    private let useCase: SelectedServerUseCaseType
    private let optimalLocationUseCase: OptimalLocationUseCaseType
    private let regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType
    private let getDedicatedIpUseCase: GetDedicatedIpUseCaseType

    let routerAction: AppRouter.Actions
    @Published var selectedServer: ServerType?
    private var cancellables = Set<AnyCancellable>()

    var selectedServerTitle: String {
        let genericTitle = L10n.LocationSelection.AnyOtherLocation.title
        guard let selectedServer else {
            return genericTitle
        }
        if selectedServer.isAutomatic {
            return L10n.LocationSelection.OptimalLocation.title
        } else {
            return genericTitle
        }
    }

    @Published var selectedServerSubtitle = ""

    init(
        useCase: SelectedServerUseCaseType, optimalLocationUseCase: OptimalLocationUseCaseType, regionsDisplayNameUseCase: RegionsDisplayNameUseCaseType, getDedicatedIpUseCase: GetDedicatedIpUseCaseType,
        routerAction: AppRouter.Actions
    ) {
        self.useCase = useCase
        self.optimalLocationUseCase = optimalLocationUseCase
        self.regionsDisplayNameUseCase = regionsDisplayNameUseCase
        self.getDedicatedIpUseCase = getDedicatedIpUseCase
        self.routerAction = routerAction
        updateState()
    }

    func iconImageFor(focused: Bool) -> Image {
        guard let currentServer = selectedServer else { return Asset.iconSmartLocation.swiftUIImage }

        if getDedicatedIpUseCase.isDedicatedIp(currentServer) {
            return Asset.iconDipLocation.swiftUIImage
        }

        if currentServer.isAutomatic {
            return focused ? Asset.iconSmartLocationHighlighted.swiftUIImage : Asset.iconSmartLocation.swiftUIImage
        } else {
            return Asset.flag(forCountry: currentServer.country) ?? Asset.iconSmartLocation.swiftUIImage
        }
    }

    func selectedServerSectionWasTapped() {
        routerAction.callAsFunction()
    }

    private func updateState() {
        useCase.getSelectedServer()
            .combineLatest(
                optimalLocationUseCase.getTargetLocaionForOptimalLocation(),
                actualConnectedServerPublisher()
            ) { (newSelectedServer, newTargetLocation, actualServer) in
                // While connected through the PlatformSDK tunnel, display the server the tunnel
                // actually connected to (e.g. the fastest region resolved under "Automatic");
                // otherwise show the user's selection. Display-only — the selection is untouched.
                return (
                    selectedServer: actualServer ?? newSelectedServer,
                    targetLocation: newTargetLocation
                )
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self else { return }
                self.selectedServer = result.selectedServer
                self.updateSelectedServerSubtitle(for: result.selectedServer, targetLocation: result.targetLocation)
            }.store(in: &cancellables)

    }

    /// Emits the server the PlatformSDK tunnel actually connected to (or `nil` when not applicable),
    /// refreshing on VPN status changes. Mirrors how the iOS tiles read
    /// `vpnProvider.actualConnection?.server`.
    ///
    /// Also refreshes on `PIATunnelSharedState.didChangeNotification`: an in-place region switch on
    /// an active tunnel (`KapePlatformSDKTunnelProfile.connect`) deliberately produces no
    /// `NEVPNStatus` transition, so the extension's cross-process write-back of the resolved server
    /// is the only signal that the region changed. Without observing it, the tvOS label would stay
    /// stuck on the previous region after a switch. Mirrors the iOS `RegionTile`/`ConnectionTile`.
    private func actualConnectedServerPublisher() -> AnyPublisher<ServerType?, Never> {
        PIATunnelSharedState.startObserving()
        return Publishers.Merge(
            NotificationCenter.default.publisher(for: .PIADaemonsDidUpdateVPNStatus),
            NotificationCenter.default.publisher(for: PIATunnelSharedState.didChangeNotification)
        )
        .map { _ in () }  // both notifications just mean "re-read"
        .prepend(())  // seed an initial read so combineLatest emits without waiting
        .map {
            Client.providers.vpnProvider.actualConnection?.server as ServerType?
        }
        .eraseToAnyPublisher()
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
