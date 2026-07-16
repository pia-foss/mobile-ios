import NetworkExtension
import Testing

@testable import PIALibrary

struct VPNFallbackPolicyTests {
    private let policy = VPNFallbackPolicy(
        initialDelay: 20,
        maximumDelay: 60,
        maximumAttempts: 3
    )

    @Test("Fallback delay grows exponentially and respects its cap")
    func delayBacksOffToCap() {
        #expect(policy.delay(afterFailedAttempts: 0) == 20)
        #expect(policy.delay(afterFailedAttempts: 1) == 40)
        #expect(policy.delay(afterFailedAttempts: 2) == 60)
        #expect(policy.delay(afterFailedAttempts: 3) == 60)
    }

    @Test("Negative attempt counts use the initial delay")
    func negativeAttemptsUseInitialDelay() {
        #expect(policy.delay(afterFailedAttempts: -1) == 20)
    }

    @Test("Retry permission ends at the configured attempt limit")
    func retryLimitIsInclusiveOfTerminalAttempt() {
        #expect(policy.shouldRetry(afterFailedAttempts: 0))
        #expect(policy.shouldRetry(afterFailedAttempts: 1))
        #expect(policy.shouldRetry(afterFailedAttempts: 2))
        #expect(policy.shouldRetry(afterFailedAttempts: 3) == false)
    }
}

struct TunnelRestartPolicyTests {
    @Test("Only settled Network Extension states can start a replacement tunnel")
    func onlySettledStatesCanStart() {
        #expect(TunnelRestartPolicy.canStartTunnel(from: .invalid))
        #expect(TunnelRestartPolicy.canStartTunnel(from: .disconnected))
        #expect(TunnelRestartPolicy.canStartTunnel(from: .connecting) == false)
        #expect(TunnelRestartPolicy.canStartTunnel(from: .connected) == false)
        #expect(TunnelRestartPolicy.canStartTunnel(from: .reasserting) == false)
        #expect(TunnelRestartPolicy.canStartTunnel(from: .disconnecting) == false)
    }
}

struct VPNGiveUpStateTests {
    @Test("Give-up completes when callback arrives before disconnected status")
    func callbackBeforeStatus() {
        var state = VPNGiveUpState()
        state.begin(connectionIsDisconnected: false)

        state.recordDisconnectCompletion(connectionIsSettled: false)
        #expect(state.isComplete == false)

        state.recordDisconnected()
        #expect(state.isComplete)
    }

    @Test("Give-up completes when disconnected status arrives before callback")
    func statusBeforeCallback() {
        var state = VPNGiveUpState()
        state.begin(connectionIsDisconnected: false)

        state.recordDisconnected()
        #expect(state.isComplete == false)

        state.recordDisconnectCompletion(connectionIsSettled: false)
        #expect(state.isComplete)
    }

    @Test("An already disconnected session completes with the disconnect callback")
    func alreadyDisconnected() {
        var state = VPNGiveUpState()
        state.begin(connectionIsDisconnected: true)

        state.recordDisconnectCompletion(connectionIsSettled: true)
        #expect(state.isComplete)
    }

    @Test("Reset prepares a completed state for a fresh connection cycle")
    func reset() {
        var state = VPNGiveUpState()
        state.begin(connectionIsDisconnected: true)
        state.recordDisconnectCompletion(connectionIsSettled: true)

        state.reset()

        #expect(state.isActive == false)
        #expect(state.disconnectCompleted == false)
        #expect(state.reachedDisconnected == false)
        #expect(state.isComplete == false)
    }
}
