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

    // MARK: Retry-vs-give-up decision

    @Test("No internet always gives up, even mid cold-connect budget")
    func noInternetGivesUp() {
        #expect(
            policy.decision(afterFailedAttempts: 0, internetIsReachable: false, hasEstablishedConnection: false)
                == .giveUp
        )
        // Even with a connection to preserve, being fully offline gives up (kill-switch deadlock fix).
        #expect(
            policy.decision(afterFailedAttempts: 0, internetIsReachable: false, hasEstablishedConnection: true)
                == .giveUp
        )
    }

    @Test("An established connection keeps reconnecting indefinitely while online")
    func establishedConnectionNeverGivesUpWhileOnline() {
        // Past the cold-connect attempt cap, an established connection must still reconnect —
        // giving up here would silently expose the user to leaks after they chose to be protected.
        #expect(
            policy.decision(afterFailedAttempts: 3, internetIsReachable: true, hasEstablishedConnection: true)
                == .reconnect
        )
        #expect(
            policy.decision(afterFailedAttempts: 99, internetIsReachable: true, hasEstablishedConnection: true)
                == .reconnect
        )
    }

    @Test("A cold connect is bounded by the attempt cap while online")
    func coldConnectIsBoundedWhileOnline() {
        #expect(
            policy.decision(afterFailedAttempts: 1, internetIsReachable: true, hasEstablishedConnection: false)
                == .reconnect
        )
        #expect(
            policy.decision(afterFailedAttempts: 2, internetIsReachable: true, hasEstablishedConnection: false)
                == .reconnect
        )
        #expect(
            policy.decision(afterFailedAttempts: 3, internetIsReachable: true, hasEstablishedConnection: false)
                == .giveUp
        )
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

struct TerminalDisconnectPolicyTests {
    // MARK: Clean disconnect (no error reported)

    @Test("A clean failed connect attempt terminates the cycle")
    func cleanFailedConnectGivesUp() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: .connecting,
                isReconnecting: false,
                wasDisconnectedManually: false
            )
        )
    }

    @Test("The intermediate teardown of a forced reconnect does NOT terminate the cycle")
    func reconnectTeardownDoesNotGiveUpOnCleanDisconnect() {
        // Regression guard: `reconnect(forceDisconnect:)` is `disconnect { connect }`, so it drives
        // the tunnel through `.disconnected` while `isReconnecting == true` and `previousStatus`
        // still reads `.connecting`. Without the `isReconnecting` guard this returned true and the
        // 20/40/60 backoff gave up on its own first reconnect.
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: .connecting,
                isReconnecting: true,
                wasDisconnectedManually: false
            ) == false
        )
    }

    @Test("A manual disconnect does NOT terminate the cycle here")
    func manualDisconnectDoesNotGiveUpOnCleanDisconnect() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: .connecting,
                isReconnecting: false,
                wasDisconnectedManually: true
            ) == false
        )
    }

    @Test("A disconnect that was not preceded by connecting does NOT terminate the cycle")
    func nonConnectingCleanDisconnectDoesNotGiveUp() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnCleanDisconnect(
                previousStatus: .connected,
                isReconnecting: false,
                wasDisconnectedManually: false
            ) == false
        )
    }

    // MARK: Generic (non-connectivity) error

    @Test("A generic error on a genuine connect attempt terminates the cycle")
    func genericErrorFailedConnectGivesUp() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnGenericError(
                previousStatus: .connecting,
                isReconnecting: false
            )
        )
    }

    @Test("A generic error during a forced reconnect teardown does NOT terminate the cycle")
    func reconnectTeardownDoesNotGiveUpOnGenericError() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnGenericError(
                previousStatus: .connecting,
                isReconnecting: true
            ) == false
        )
    }

    @Test("A generic error while not connecting does NOT terminate the cycle")
    func nonConnectingGenericErrorDoesNotGiveUp() {
        #expect(
            TerminalDisconnectPolicy.shouldGiveUpOnGenericError(
                previousStatus: .disconnecting,
                isReconnecting: false
            ) == false
        )
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
