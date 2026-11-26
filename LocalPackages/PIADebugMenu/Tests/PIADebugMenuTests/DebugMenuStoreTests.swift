import CoreArchitecture
import Foundation
import PIALibrary
import Testing

@testable import PIADebugMenu

@MainActor
struct DebugMenuStoreTests {

    private let spy = DebugMenuDependencySpy()

    private func makeStore(
        state: DebugMenu.State = .stub()
    ) -> TestStore<DebugMenu.State, DebugMenu.Action> {
        TestStore(
            initial: state,
            reduce: DebugMenu.Reducer(dependencies: spy.makeDependencies()).reduce
        )
    }

    /// Receives `count` actions produced by concurrent effects, whose arrival order is not part of
    /// the contract.
    private func receive(
        _ count: Int,
        from sut: TestStore<DebugMenu.State, DebugMenu.Action>
    ) async throws -> [DebugMenu.Action] {
        var actions: [DebugMenu.Action] = []
        for _ in 0..<count {
            actions.append(try #require(await sut.receive()))
        }
        return actions
    }

    // MARK: Appearing

    @Test("Appearing loads the entitlement, the ipify address and the connection configurations")
    func appearingLoads() async throws {
        spy.connectionConfigurations = [.stub()]
        let sut = makeStore()

        sut.send(.onAppear)
        let actions = try await receive(3, from: sut)
        spy.finishStreams()
        await sut.finish()

        #expect(actions.contains(.entitlementLoaded("jws")))
        #expect(actions.contains(.ipifyResolved("198.51.100.7")))
        #expect(actions.contains(.connectionConfigurationsUpdated([.stub()])))
        #expect(sut.state.transactionJWS == "jws")
        #expect(sut.state.ipifyIP == "198.51.100.7")
        #expect(sut.state.connectionConfigurations == [.stub()])
    }

    @Test("Re-appearing does not reload an entitlement already loaded")
    func reappearingSkipsEntitlement() async throws {
        var state = DebugMenu.State.stub()
        state.transactionJWS = "loaded"
        let sut = makeStore(state: state)

        sut.send(.onAppear)
        _ = try await receive(2, from: sut)
        spy.finishStreams()
        await sut.finish()

        #expect(spy.entitlementCallCount == 0)
        #expect(sut.state.transactionJWS == "loaded")
    }

    @Test("A failed ipify lookup reads as unavailable")
    func ipifyUnavailable() {
        let sut = makeStore()

        sut.send(.ipifyResolved(nil))

        #expect(sut.state.ipifyIP == "unavailable")
    }

    // MARK: Polling

    @Test("A tick refreshes logs, account, live info, VPN connection and tunnel log")
    func tickRefreshes() async throws {
        let sut = makeStore()
        spy.logs = "new log"
        spy.account = .stub(username: "p7654321")
        spy.liveInfo = .stub(protocolName: "OpenVPN")
        spy.tunnelLog = "new tunnel line"

        sut.send(.pollTick)
        _ = try await receive(5, from: sut)
        await sut.finish()

        #expect(sut.state.logSnapshot == "new log")
        #expect(sut.state.account == .stub(username: "p7654321"))
        #expect(sut.state.liveInfo == .stub(protocolName: "OpenVPN"))
        #expect(sut.state.tunnelLogSnapshot == "new tunnel line")
        #expect(sut.unconsumedActionCount == 0)
    }

    @Test("Polling ticks drive refreshes while the screen is shown")
    func pollingStreamSendsTicks() async throws {
        var state = DebugMenu.State.stub()
        state.transactionJWS = "loaded"
        let sut = makeStore(state: state)
        sut.send(.onAppear)
        _ = try await receive(2, from: sut)

        spy.ticks.yield()
        let tick = try #require(await sut.receive())
        _ = try await receive(5, from: sut)
        spy.finishStreams()
        await sut.finish()

        #expect(tick == .pollTick)
        #expect(spy.tunnelLogCallCount == 1)
    }

    @Test("The tunnel log is not polled while a report is being sent")
    func tickSkipsTunnelLogWhileSending() async throws {
        var state = DebugMenu.State.stub()
        state.isSendingReport = true
        let sut = makeStore(state: state)

        sut.send(.pollTick)
        _ = try await receive(4, from: sut)
        await sut.finish()

        #expect(spy.tunnelLogCallCount == 0)
        #expect(sut.unconsumedActionCount == 0)
    }

    @Test("A tick does not start a second tunnel log fetch while one is in flight")
    func tickSkipsTunnelLogWhileFetching() async throws {
        let sut = makeStore()

        sut.send(.pollTick)
        #expect(sut.state.isFetchingTunnelLog)
        sut.send(.pollTick)
        _ = try await receive(9, from: sut)
        await sut.finish()

        #expect(spy.tunnelLogCallCount == 1)
        #expect(!sut.state.isFetchingTunnelLog)
        #expect(sut.unconsumedActionCount == 0)
    }

    @Test("An empty or missing tunnel log keeps the last snapshot")
    func emptyTunnelLogIgnored() {
        var state = DebugMenu.State.stub()
        state.tunnelLogSnapshot = "kept"
        let sut = makeStore(state: state)

        sut.send(.tunnelLogUpdated(nil))
        sut.send(.tunnelLogUpdated(""))

        #expect(sut.state.tunnelLogSnapshot == "kept")
    }

    @Test("Disappearing stops polling and observing")
    func disappearingStops() async throws {
        var state = DebugMenu.State.stub()
        state.transactionJWS = "loaded"
        let sut = makeStore(state: state)
        sut.send(.onAppear)
        _ = try await receive(2, from: sut)

        sut.send(.onDisappear)
        spy.ticks.yield()
        spy.configurationChanges.yield()

        #expect(await sut.receive(timeout: 0.2) == nil)
        await sut.finish()
    }

    // MARK: ipify

    @Test("A VPN connection change looks up the ipify address again")
    func vpnChangeRefreshesIpify() async throws {
        let sut = makeStore()
        spy.ipifyAddress = "192.0.2.9"

        sut.send(.vpnConnectionUpdated(.piaConnected))
        let action = try #require(await sut.receive())
        await sut.finish()

        #expect(action == .ipifyResolved("192.0.2.9"))
        #expect(sut.state.vpnConnection == .piaConnected)
        #expect(sut.state.ipifyIP == "192.0.2.9")
    }

    @Test("An unchanged VPN connection does not look up the ipify address")
    func unchangedVPNSkipsIpify() async {
        let sut = makeStore()

        sut.send(.vpnConnectionUpdated(.unknown))
        await sut.finish()

        #expect(spy.ipifyCallCount == 0)
    }

    // MARK: Connection configurations

    @Test("A change signal reloads the connection configurations")
    func configurationChangeReloads() async throws {
        var state = DebugMenu.State.stub()
        state.transactionJWS = "loaded"
        let sut = makeStore(state: state)
        sut.send(.onAppear)
        _ = try await receive(2, from: sut)

        spy.connectionConfigurations = [.stub(), .stub(vpnProtocol: "openvpn-udp", port: 8080)]
        spy.configurationChanges.yield()
        let action = try #require(await sut.receive())
        spy.finishStreams()
        await sut.finish()

        #expect(action == .connectionConfigurationsUpdated(spy.connectionConfigurations))
        #expect(sut.state.connectionConfigurations.count == 2)
    }

    // MARK: Report

    @Test("Sending a report submits the current VPN state and shows the report ID")
    func reportSucceeds() async throws {
        var state = DebugMenu.State.stub()
        state.vpnConnection = .piaConnected
        let sut = makeStore(state: state)

        sut.send(.sendReportTapped)
        #expect(sut.state.isSendingReport)
        let action = try #require(await sut.receive())
        await sut.finish()

        #expect(action == .reportFinished(.sent(reportID: "ABC12")))
        #expect(spy.submittedReports.map(\.status) == ["connected"])
        #expect(spy.submittedReports.map(\.connectedVia) == ["PIA"])
        #expect(!sut.state.isSendingReport)
        #expect(sut.state.alert?.title == "Debug information submitted")
        #expect(sut.state.alert?.message.contains("ABC12") == true)
    }

    @Test("A failed report shows a failure alert")
    func reportFails() async throws {
        spy.reportResult = .failed
        let sut = makeStore()

        sut.send(.sendReportTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.alert?.title == "Submission failed")
    }

    @Test("Tapping send again while a report is in flight is ignored")
    func reportNotDuplicated() async throws {
        let sut = makeStore()

        sut.send(.sendReportTapped)
        sut.send(.sendReportTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(spy.submittedReports.count == 1)
        #expect(sut.unconsumedActionCount == 0)
    }

    // MARK: Refund

    @Test("No entitlement shows an alert instead of the refund sheet")
    func refundWithoutTransactions() async throws {
        let sut = makeStore()

        sut.send(.refundTapped)
        #expect(sut.state.isLoadingRefundTransaction)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(!sut.state.isLoadingRefundTransaction)
        #expect(!sut.state.isRefundSheetPresented)
        #expect(sut.state.alert?.title == "No Transaction Found")
    }

    @Test("A single entitlement opens the refund sheet for it")
    func refundWithOneTransaction() async throws {
        spy.entitlements = [.stub(id: 42)]
        let sut = makeStore()

        sut.send(.refundTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.refundTransactionId == 42)
        #expect(sut.state.isRefundSheetPresented)
        #expect(!sut.state.isTransactionPickerPresented)
    }

    @Test("Several entitlements open the picker, and picking one opens the refund sheet")
    func refundWithSeveralTransactions() async throws {
        let transactions: [DebugMenu.RefundableTransaction] = [.stub(id: 1), .stub(id: 2, productID: "monthly")]
        spy.entitlements = transactions
        let sut = makeStore()

        sut.send(.refundTapped)
        _ = try #require(await sut.receive())
        await sut.finish()

        #expect(sut.state.availableTransactions == transactions)
        #expect(sut.state.isTransactionPickerPresented)
        #expect(!sut.state.isRefundSheetPresented)

        sut.send(.transactionSelected(transactions[1]))

        #expect(!sut.state.isTransactionPickerPresented)
        #expect(sut.state.refundTransactionId == 2)
        #expect(sut.state.isRefundSheetPresented)
    }

    @Test(
        "Refund outcomes",
        arguments: [
            (DebugMenu.RefundOutcome.submitted, "Refund Requested" as String?),
            (.notSubmitted, nil),
            (.failed(message: "Nope"), "Refund Request Failed")
        ])
    func refundOutcome(outcome: DebugMenu.RefundOutcome, alertTitle: String?) {
        let sut = makeStore()

        sut.send(.refundFinished(outcome))

        #expect(sut.state.alert?.title == alertTitle)
    }

    // MARK: Bindings and output

    @Test("Bindings and dismissing the alert update state")
    func bindings() {
        var state = DebugMenu.State.stub()
        state.alert = .init(title: "t", message: "m")
        let sut = makeStore(state: state)

        sut.send(.alertDismissed)
        sut.send(.manageSubscriptionsTapped)
        #expect(sut.state.isPresentingManageSubscriptions)
        sut.send(.manageSubscriptionsPresented(false))
        sut.send(.refundSheetPresented(true))
        sut.send(.transactionPickerPresented(true))

        #expect(sut.state.alert == nil)
        #expect(!sut.state.isPresentingManageSubscriptions)
        #expect(sut.state.isRefundSheetPresented)
        #expect(sut.state.isTransactionPickerPresented)
    }

    @Test("Close asks the host to dismiss")
    func closeEmitsDismiss() async {
        let sut = makeStore()

        sut.send(.closeTapped)
        await sut.finish()

        #expect(spy.emittedOutputs == [.dismiss])
    }

    // MARK: Values

    @Test("The export lists every section")
    func exportContent() {
        var state = DebugMenu.State.stub(logSnapshot: "app log")
        state.connectionConfigurations = [.stub()]
        state.tunnelLogSnapshot = "tunnel log"
        state.transactionJWS = "jws-value"

        let content = state.exportContent

        for expected in [
            "=== App Info ===", "Version: 4.0.0 (1234)", "=== VPN ===", "Protocol: WireGuard",
            "WireGuard  10.0.0.1:1337", "Username: p1234567", "Is Expired: No", "jws-value",
            "=== App Logs ===\napp log", "=== Tunnel Log ===\ntunnel log"
        ] {
            #expect(content.contains(expected), "missing \(expected)")
        }
    }

    @Test("Without a tunnel or an account the export says so")
    func exportContentWhenEmpty() {
        let state = DebugMenu.State.stub(account: nil)

        let content = state.exportContent

        #expect(content.contains("Tunnel not running"))
        #expect(content.contains("Username: —"))
        #expect(content.contains("=== Transaction (JWS) ===\nNot available"))
        #expect(content.contains("=== Tunnel Log ===\nNo tunnel log"))
    }

    @Test("Log previews show the newest lines first, capped")
    func logPreview() {
        let lines = (1...40).map { "line \($0)" }
        let state = DebugMenu.State.stub(logSnapshot: lines.joined(separator: "\n"))

        let preview = state.logPreview.components(separatedBy: "\n")

        #expect(preview.count == DebugMenu.previewLineCount)
        #expect(preview.first == "line 40")
        #expect(DebugMenu.State.stub(logSnapshot: "").logPreview == "No logs")
    }
}
