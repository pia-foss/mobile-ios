import SwiftUI
import StoreKit
@preconcurrency import PIALibrary

// MARK: - DebugMenuView

struct ReportResult: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

@available(iOS 16, *)
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
        List {
            appInfoSection
            accountSection
            receiptSection
            logsSection
            subscriptionSection
            supportSection
        }
        .alert(item: $reportResult) { result in
            Alert(
                title: Text(result.title),
                message: Text(result.message),
                dismissButton: .default(Text("OK"))
            )
        }
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
        .onAppear {
            logSnapshot = logs
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                guard !Task.isCancelled else { break }
                withAnimation(.spring(duration: 0.35, bounce: 0.1)) {
                    logSnapshot = logs
                }
            }
        }
        .navigationTitle("🪲 Debug Menu")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close", action: onDismiss)
            }

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
        }
    }

    // MARK: - Sections

    private var appInfoSection: some View {
        Section("App Info") {
            DebugInfoRow(label: "Version", value: appVersion)
            DebugInfoRow(label: "Environment", value: environment)
            DebugInfoRow(label: "Base URL", value: baseUrl)
        }
    }

    private var accountSection: some View {
        Section("Account and Subscription") {
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
        Section("Payment Receipt") {
            if let base64 = receiptBase64 {
                let preview = String(base64.prefix(300)) + "…"
                VStack(alignment: .leading, spacing: 2) {
                    Text("Receipt (preview)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .padding(.vertical, 2)
                HStack {
                    Button("Copy") {
                        UIPasteboard.general.string = base64
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    ShareLink(
                        item: DebugExportFile(
                            content: base64,
                            filename: "receipt_\(Int(Date().timeIntervalSince1970)).txt"
                        ),
                        preview: SharePreview("Receipt")
                    ) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderless)
                }
            } else {
                DebugInfoRow(label: "Receipt", value: "Not available")
            }
        }
    }

    private var logsSection: some View {
        Section("Logs") {
            let preview = logSnapshot.isEmpty ? "No logs" : String(logSnapshot.suffix(300))

            VStack(alignment: .leading, spacing: 2) {
                Text("Recent logs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(preview)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.primary)
                    .id(preview)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .move(edge: .top)
                    ))
            }
            .clipped()
            .padding(.vertical, 2)

            HStack {
                Button("Clear", role: .destructive) {
                    PIALogHandler.logStorage.clear()
                    withAnimation(.spring(duration: 0.35, bounce: 0.1)) {
                        logSnapshot = ""
                    }
                }
                .buttonStyle(.borderless)

                Spacer()

                ShareLink(
                    item: DebugExportFile(
                        content: logSnapshot,
                        filename: "logs_\(Int(Date().timeIntervalSince1970)).txt"
                    ),
                    preview: SharePreview("Logs")
                ) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
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
                        Text("Looking up transaction…")
                    }
                } else {
                    Text("Test Refund Request")
                }
            }
            .disabled(isLoadingRefundTransaction)
            .buttonStyle(.borderless)
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Button {
                isSendingReport = true
                Task { @MainActor in
                    defer {
                        isSendingReport = false
                    }

                    do {
                        let reportId = try await Client.submitDebugReport(
                            includePersistedData: true,
                            logs: logSnapshot
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
            } label: {
                if isSendingReport {
                    HStack {
                        ProgressView()
                        Text("Sending…")
                    }
                } else {
                    Text("Send to Support")
                }
            }
            .disabled(isSendingReport)
            .buttonStyle(.borderless)
        }
    }

    // MARK: - Init

    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }

}

@available(iOS 16, *)
#Preview {
    // If preview doesn't work, enable
    // Editor > Canvas > Use Legacy Previews Execution
    DebugMenuView()
}
