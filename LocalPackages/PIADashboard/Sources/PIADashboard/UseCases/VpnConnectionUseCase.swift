import Combine
import Foundation
import PIALibrary

private let log = PIALogger.logger(for: VpnConnectionUseCase.self)

public protocol VpnConnectionUseCaseType {
    func connect() async throws
    func disconnect() async throws
    func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Never>
}

public enum VpnConnectionIntent: Equatable {
    case none
    case connect
    case disconnect
}

public final class VpnConnectionUseCase: VpnConnectionUseCaseType {

    internal var connectionIntent: CurrentValueSubject<VpnConnectionIntent, Never>

    let serverProvider: ServerProviderType
    let vpnProvider: VPNStatusProviderType
    let vpnStatusMonitor: VPNStatusMonitorType
    private var clientPreferences: ClientPreferencesType
    private var cancellables = Set<AnyCancellable>()

    /// When the most recent connect was requested. Used to tell a *fresh* tunnel write-back from a
    /// stale pre-switch one when clearing the connect intent (see `subscribeToActiveConnectionWriteBack`).
    private var connectRequestedAt: Date?
    /// Retains the cross-process shared-state observer for the write-back-driven intent reset.
    private var activeConnectionObserver: NSObjectProtocol?

    public init(serverProvider: ServerProviderType, vpnProvider: VPNStatusProviderType, vpnStatusMonitor: VPNStatusMonitorType, clientPreferences: ClientPreferencesType) {
        self.serverProvider = serverProvider
        self.vpnProvider = vpnProvider
        self.vpnStatusMonitor = vpnStatusMonitor
        self.clientPreferences = clientPreferences
        self.connectionIntent = CurrentValueSubject(.none)

        subscribeToVpnStatusState()
        subscribeToActiveConnectionWriteBack()
    }

    deinit {
        if let activeConnectionObserver {
            NotificationCenter.default.removeObserver(activeConnectionObserver)
        }
    }

    public func connect() async throws {

        log.info("VPN connect requested")
        connectRequestedAt = Date()
        connectionIntent.send(.connect)

        return try await withCheckedThrowingContinuation { continuation in
            // `changeServer` connects when disconnected and switches in place when already connected
            // (on the PlatformSDK tunnel tvOS runs), so the same call covers first connect and region
            // change without this use case needing to know the tunnel stack.
            vpnProvider.changeServer { error in
                if let error = error {
                    log.error("VPN connect failed: \(error.localizedDescription)")
                    self.connectionIntent.send(.none)
                    continuation.resume(throwing: error)
                } else {
                    log.info("VPN connect call succeeded")
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func disconnect() async throws {

        log.info("VPN disconnect requested")
        connectionIntent.send(.disconnect)

        return try await withCheckedThrowingContinuation { continuation in
            vpnProvider.disconnect { error in
                if let error = error {
                    log.error("VPN disconnect failed: \(error.localizedDescription)")
                    self.connectionIntent.send(.none)
                    continuation.resume(throwing: error)
                } else {
                    log.info("VPN disconnect call succeeded")
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func getConnectionIntent() -> AnyPublisher<VpnConnectionIntent, Never> {
        return connectionIntent.eraseToAnyPublisher()
    }
}

// MARK: - VPN Status subscription

extension VpnConnectionUseCase {
    func subscribeToVpnStatusState() {
        vpnStatusMonitor.getStatus()
            .receive(on: RunLoop.main)
            .sink { [weak self] newVpnStatus in
                guard let self else { return }

                let currentConnectionIntent = self.connectionIntent.value

                switch (currentConnectionIntent, newVpnStatus) {
                case (.connect, .connected):
                    // Update the lastConnectedRegion when the connection has succeeded
                    self.clientPreferences.lastConnectedServer = try? serverProvider.targetServerType

                    // The vpn connection has succeeded, then put back the connection intent to none
                    log.info("VPN connected successfully")
                    self.connectionIntent.send(.none)
                case (.disconnect, .disconnected):
                    // The vpn disconnect has succeeded, then put back the connection intent to none
                    log.info("VPN disconnected successfully")
                    self.connectionIntent.send(.none)
                default:
                    break

                }
            }.store(in: &cancellables)

    }

    /// Clears the `.connect` intent once the tunnel writes back a freshly-resolved connected endpoint
    /// (see `PIATunnelSharedState.hasFreshActiveConnection(since:)`).
    ///
    /// Needed for the PlatformSDK in-place region switch: switching region on an already-connected
    /// tunnel keeps `NEVPNStatus` at `.connected`, so `subscribeToVpnStatusState` — which only reacts
    /// to VPN status transitions — never fires, and the intent (and therefore the "Connecting" UI on
    /// tvOS, see `ConnectionStateMonitor`) would stick forever. Inert for non-PlatformSDK tunnels,
    /// which never write this back.
    func subscribeToActiveConnectionWriteBack() {
        activeConnectionObserver = PIATunnelSharedState.observe { [weak self] _ in
            guard let self,
                self.connectionIntent.value == .connect,
                let requestedAt = self.connectRequestedAt,
                PIATunnelSharedState.hasFreshActiveConnection(since: requestedAt)
            else { return }

            log.info("Tunnel reported a fresh connected endpoint — clearing connect intent")
            self.connectionIntent.send(.none)
        }
    }
}
