@preconcurrency import PIALibrary
import StoreKit
import SwiftUI

import struct PIABase.JWS

struct ReportResult: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@available(iOS 16, tvOS 17, *)
@MainActor
final class DebugMenuViewModel: ObservableObject {
    @Published var logSnapshot: String = ""
    @Published var tunnelLogSnapshot: String = ""
    @Published var entitlementJWS: JWS? = nil
    @Published var isSendingReport = false
    @Published var reportResult: ReportResult? = nil
    @Published var isPresentingManageSubscriptions = false
    @Published var isLoadingRefundTransaction = false
    @Published var refundTransactionId: UInt64 = 0
    @Published var isRefundSheetPresented = false
    @Published var availableTransactions: [StoreKit.Transaction] = []
    @Published var isTransactionPickerPresented = false
    @Published private(set) var vpnConnection: VPNConnectionState = .unknown

    private static let refreshInterval: UInt64 = 5 * NSEC_PER_SEC
    private var refreshTask: Task<Void, Never>?

    // MARK: - Lifecycle

    func onAppear() {
        guard refreshTask == nil else { return }

        refreshTask = Task { [weak self] in
            await self?.loadEntitlementJWSIfNeeded()

            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(nanoseconds: Self.refreshInterval)
            }
        }
    }

    func onDisappear() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    // MARK: - Actions

    func presentManageSubscriptions() {
        isPresentingManageSubscriptions = true
    }

    func sendReportToSupport() async {
        isSendingReport = true
        defer {
            isSendingReport = false
        }

        do {
            let reportId = try await Client.submitDebugReport(
                includeDebug: true,
                redactIPs: false,
                includeTunnelLog: true,
                vpnConnection: VPNConnectionInformation(status: vpnStatus, connectedVia: connectedVia)
            )
            reportResult = ReportResult(
                title: "Debug information submitted",
                message: "Report ID: \(reportId)\nPlease note this ID — support will need it to locate your submission."
            )
        } catch {
            reportResult = ReportResult(
                title: "Submission failed",
                message: "Debug information could not be submitted."
            )
        }
    }

    func requestRefund() async {
        isLoadingRefundTransaction = true
        defer {
            isLoadingRefundTransaction = false
        }

        var transactions: [StoreKit.Transaction] = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                transactions.append(transaction)
            }
        }

        switch transactions.count {
        case 0:
            reportResult = ReportResult(
                title: "No Transaction Found",
                message: "No active transaction found to request a refund for."
            )
        case 1:
            refundTransactionId = transactions[0].id
            isRefundSheetPresented = true
        default:
            availableTransactions = transactions
            isTransactionPickerPresented = true
        }
    }

    func selectTransaction(_ transaction: StoreKit.Transaction) {
        isTransactionPickerPresented = false
        refundTransactionId = transaction.id
        isRefundSheetPresented = true
    }

    #if os(iOS)
        func handleRefundResult(
            _ result: Result<StoreKit.Transaction.RefundRequestStatus, StoreKit.Transaction.RefundRequestError>
        ) {
            switch result {
            case .success(let status):
                if status == .success {
                    reportResult = ReportResult(
                        title: "Refund Requested",
                        message: "Your refund request was submitted to the App Store."
                    )
                }
            case .failure(let error):
                reportResult = ReportResult(
                    title: "Refund Request Failed",
                    message: error.localizedDescription
                )
            }
        }
    #endif

    // MARK: - Refresh

    private func loadEntitlementJWSIfNeeded() async {
        guard entitlementJWS == nil else { return }
        entitlementJWS = await Client.store.currentSubscriptionReceipt()?.jws
    }

    private func refresh() async {
        updateLogSnapshotIfNeeded()
        await updateVPNConnectionIfNeeded()
        await refreshTunnelLog()
    }

    private func updateVPNConnectionIfNeeded() async {
        let current = await VPNConnectionState.current()
        if current != vpnConnection {
            vpnConnection = current
        }
    }

    private func updateLogSnapshotIfNeeded() {
        let current = logs
        if current != logSnapshot {
            logSnapshot = current
        }
    }

    private func refreshTunnelLog() async {
        // On WireGuard the extension returns only the entries since the previous fetch, so this
        // poll and the fetch performed while submitting a CSI report compete for the same cursor.
        guard !isSendingReport else {
            return
        }

        guard let content = await Client.providers.vpnProvider.tunnelLog(), !content.isEmpty else {
            return
        }

        if content != tunnelLogSnapshot {
            tunnelLogSnapshot = content
        }
    }
}
