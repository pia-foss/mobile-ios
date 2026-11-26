import Foundation
@preconcurrency import PIALibrary
import StoreKit

extension DebugMenu.Dependencies {

    private static let refreshInterval: UInt64 = 5 * NSEC_PER_SEC

    /// What makes the attempt list change. The tunnel posts `connectionConfigurationsDidChange` when
    /// it generates a batch; `PIADaemonsDidUpdateVPNStatus` covers the disconnect, where no signal
    /// can arrive because the process that would post it is gone.
    private static let connectionConfigurationTriggers: [Notification.Name] = [
        PIATunnelSignal.connectionConfigurationsDidChange.notificationName,
        .PIADaemonsDidUpdateVPNStatus
    ]

    /// - Parameter emit: Receives the screen's outputs; `.dismiss` closes the menu.
    @MainActor
    public static func live(emit: @MainActor @escaping (DebugMenu.Output) -> Void) -> Self {
        Self(
            appInfo: {
                DebugMenu.AppInfo(
                    version: Macros.versionFullString() ?? "—",
                    environment: Client.environment.rawValue,
                    baseURL: Macros.baseUrl() ?? "—"
                )
            },
            currentAccount: {
                Client.providers.accountProvider.currentUser?.info.map(account(from:))
            },
            liveInfo: {
                DebugMenu.LiveInfo(
                    protocolName: protocolName(),
                    publicIP: Client.daemons.publicIP ?? "---",
                    vpnIP: Client.daemons.vpnIP ?? "---"
                )
            },
            logs: {
                PIALogHandler.logStorage.getAllLogs(includeDebug: true)
            },
            tunnelLog: {
                await Client.providers.vpnProvider.tunnelLog()
            },
            vpnConnection: {
                await VPNConnectionState.current()
            },
            ipifyAddress: {
                await IpifyAddress.current()
            },
            // Answered by the extension process, so this empties itself while the tunnel is down.
            connectionConfigurations: {
                await Client.providers.vpnProvider.connectionConfigurations()
            },
            connectionConfigurationChanges: {
                PIATunnelSignal.startObserving()
                return AsyncStream { continuation in
                    let task = Task {
                        await withTaskGroup(of: Void.self) { group in
                            for name in connectionConfigurationTriggers {
                                group.addTask {
                                    for await _ in NotificationCenter.default.notifications(named: name).map({ _ in () }) {
                                        continuation.yield()
                                    }
                                }
                            }
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            pollTicks: {
                AsyncStream { continuation in
                    let task = Task {
                        while !Task.isCancelled {
                            continuation.yield()
                            try? await Task.sleep(nanoseconds: refreshInterval)
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            },
            entitlementJWS: {
                await Client.store.currentSubscriptionReceipt()?.jws.value
            },
            currentEntitlements: {
                var transactions: [DebugMenu.RefundableTransaction] = []
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result {
                        transactions.append(.init(id: transaction.id, productID: transaction.productID))
                    }
                }
                return transactions
            },
            submitReport: { status, connectedVia in
                do {
                    let reportID = try await Client.submitDebugReport(
                        includeDebug: true,
                        redactIPs: false,
                        includeTunnelLog: true,
                        vpnConnection: VPNConnectionInformation(status: status, connectedVia: connectedVia)
                    )
                    return .sent(reportID: reportID)
                } catch {
                    return .failed
                }
            },
            emit: emit
        )
    }

    private static func account(from info: AccountInfo) -> DebugMenu.Account {
        DebugMenu.Account(
            username: info.username,
            plan: info.plan.rawValue,
            productId: info.productId ?? "—",
            expiration: formattedExpiration(info.expirationDate),
            isExpired: info.isExpired,
            isRenewable: info.isRenewable,
            isRecurring: info.isRecurring
        )
    }

    private static func formattedExpiration(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    @MainActor
    private static func protocolName() -> String {
        let name =
            switch Client.preferences.vpnType {
            case "PIAWG": "WireGuard"
            case "PIA": "OpenVPN"
            case "IPSec", "IKEv2": "IKEv2"
            case "PIAAutomatic": "Automatic"
            default: Client.preferences.vpnType
            }

        guard let obfuscation = activeObfuscation() else { return name }
        return "\(name) (\(obfuscation))"
    }

    private static func activeObfuscation() -> String? {
        guard
            let obfuscation = PIATunnelSharedState.readStatus().activeConnection?.obfuscation,
            obfuscation != "none"
        else {
            return nil
        }

        return obfuscation
    }
}
