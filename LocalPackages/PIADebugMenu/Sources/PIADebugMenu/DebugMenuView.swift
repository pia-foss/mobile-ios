@preconcurrency import PIALibrary
import StoreKit
import SwiftUI

// MARK: - DebugMenuView

struct ReportResult: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@available(iOS 16, tvOS 17, *)
public struct DebugMenuView: View {
    private let onDismiss: () -> Void
    @State private var logSnapshot: String = ""
    @State private var isSendingReport = false
    @State private var reportResult: ReportResult? = nil
    @State private var isLoadingRefundTransaction = false
    @State private var refundTransactionId: UInt64 = 0
    @State private var isRefundSheetPresented = false
    @State private var availableTransactions: [StoreKit.Transaction] = []
    @State private var isTransactionPickerPresented = false

    public var body: some View {
        mainContent
            .alert(item: $reportResult) { result in
                Alert(
                    title: Text(result.title),
                    message: Text(result.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            #if os(iOS)
                .refundRequestSheet(for: refundTransactionId, isPresented: $isRefundSheetPresented) { @MainActor result in
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
                .sheet(isPresented: $isTransactionPickerPresented) {
                    List {
                        Section("Select a transaction to refund") {
                            ForEach(availableTransactions, id: \.id) { transaction in
                                Button(transaction.productID) {
                                    isTransactionPickerPresented = false
                                    refundTransactionId = transaction.id
                                    isRefundSheetPresented = true
                                }
                            }
                        }
                    }
                }
            #endif
            .navigationTitle("Debug Menu")
            .onAppear {
                logSnapshot = logs
            }
            .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
                logSnapshot = logs
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close", action: onDismiss)
                }

                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(
                            item: DebugExportFile(
                                content: buildExportContent(),
                                filename: "debug_\(Int(Date().timeIntervalSince1970)).txt"
                            ),
                            preview: SharePreview("Debug Export")
                        ) {
                            Text("Export All")
                        }
                    }
                #endif
            }
            #if os(tvOS)
                .background(Color.black.ignoresSafeArea())
            #endif
    }

    @ViewBuilder
    private var mainContent: some View {
        #if os(tvOS)
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    appInfoSection
                        .focusable()
                    vpnSection
                        .focusable()
                    accountSection
                        .focusable()
                    receiptSection
                        .focusable()
                    logsSection
                        .focusable()
                    supportSection
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
        #else
            List {
                appInfoSection
                accountSection
                receiptSection
                logsSection
                subscriptionSection
                supportSection
            }
        #endif
    }

    // MARK: - Sections

    private var appInfoSection: some View {
        DebugSection("App Info") {
            DebugInfoRow(label: "Version", value: appVersion)
            DebugInfoRow(label: "Environment", value: environment)
            DebugInfoRow(label: "Base URL", value: baseUrl)
        }
    }

    private var vpnSection: some View {
        DebugSection("VPN") {
            DebugInfoRow(label: "Status", value: Client.daemons.vpnStatus.rawValue)
            DebugInfoRow(label: "Protocol", value: Client.preferences.vpnType)
            DebugInfoRow(label: "Local IP", value: Client.daemons.publicIP ?? "---")
            DebugInfoRow(label: "VPN IP", value: Client.daemons.vpnIP ?? "---")
        }
    }

    private var accountSection: some View {
        DebugSection("Account and Subscription") {
            DebugInfoRow(label: "Username", value: username)
            DebugInfoRow(label: "Plan", value: plan)
            DebugInfoRow(label: "Product ID", value: productId)
            DebugInfoRow(label: "Expiration Date", value: expirationFormatted)
            DebugInfoRow(label: "Is Expired", value: isExpired)
            DebugInfoRow(label: "Is Renewable", value: isRenewable)
            DebugInfoRow(label: "Is Recurring", value: isRecurring)
        }
    }

    private var receiptSection: some View {
        DebugSection("Payment Receipt") {
            if let base64 = receiptBase64 {
                let preview = String(base64.prefix(300)) + "..."
                VStack(alignment: .leading, spacing: 2) {
                    Text("Receipt (preview)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                #if os(tvOS)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                #else
                    .padding(.vertical, 2)
                #endif

                #if os(iOS)
                    ShareLink(
                        item: DebugExportFile(
                            content: base64,
                            filename: "receipt_\(Int(Date().timeIntervalSince1970)).txt"
                        ),
                        preview: SharePreview("Receipt")
                    ) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                #endif
            } else {
                DebugInfoRow(label: "Receipt", value: "Not available")
            }
        }
    }

    private var logsSection: some View {
        DebugSection("Logs") {
            let preview = logSnapshot.isEmpty ? "No logs" : logSnapshot.components(separatedBy: "\n").reversed().joined(separator: "\n")

            VStack(alignment: .leading, spacing: 2) {
                Text("Recent logs (newest on top)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ScrollView {
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 300)
            }
            #if os(tvOS)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            #else
                .padding(.vertical, 2)
            #endif

            #if os(iOS)
                ShareLink(
                    item: DebugExportFile(
                        content: logs,
                        filename: "logs_\(Int(Date().timeIntervalSince1970)).txt"
                    ),
                    preview: SharePreview("Logs")
                ) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            #endif
        }
    }

    private var subscriptionSection: some View {
        DebugSection("Subscription") {
            Button {
                isLoadingRefundTransaction = true
                Task { @MainActor in
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
            } label: {
                if isLoadingRefundTransaction {
                    HStack {
                        ProgressView()
                        Text("Looking up transaction...")
                    }
                } else {
                    Text("Test Refund Request")
                }
            }
            .disabled(isLoadingRefundTransaction)
        }
    }

    private var supportSection: some View {
        DebugSection("Support") {
            Button {
                isSendingReport = true
                Task { @MainActor in
                    defer {
                        isSendingReport = false
                    }

                    do {
                        let reportId = try await Client.submitDebugReport(includeDebug: true, redactIPs: false)
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
            } label: {
                if isSendingReport {
                    HStack {
                        ProgressView()
                        Text("Sending...")
                    }
                } else {
                    Text("Send to Support (CSI)")
                }
            }
            .disabled(isSendingReport)
        }
    }

    // MARK: - Init

    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }

}

@available(iOS 16, tvOS 17, *)
#Preview {
    // If preview doesn't work, enable
    // Editor > Canvas > Use Legacy Previews Execution
    DebugMenuView()
}
