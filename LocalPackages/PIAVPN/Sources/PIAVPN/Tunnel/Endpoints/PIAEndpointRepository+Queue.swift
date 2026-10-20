import Foundation
import KapeVPN_PacketTunnel

extension PIAEndpointRepository {

    /// The configurations of the current batch not handed out yet.
    ///
    /// The session controller pulls one configuration per attempt, so the batch has to outlive a
    /// single `nextConfiguration()` call. Isolating it here keeps `PIAEndpointRepository` itself
    /// `Sendable`, like `LatestBatch`.
    actor ConfigurationQueue {
        /// Fresh batches built per call before giving up, so an empty or unauthorizable pool can't
        /// spin. `nil` is not terminal: the session controller backs off and asks again.
        static let maxRefillsPerCall = 2

        private var pending: [any VpnConfiguration] = []
        /// Bumped by `reset()`. A call that started under an older generation is superseded.
        private var generation = 0
        private let logger: PIATunnelLogger

        init(logger: PIATunnelLogger) {
            self.logger = logger
        }

        /// The next configuration that authorizes, refilling from `buildBatch` when the batch runs dry.
        ///
        /// - Parameters:
        ///   - buildBatch: Builds a fresh batch.
        ///   - authorize: Readies a configuration to connect. A failure skips that configuration only.
        ///   - didInstall: Called with each batch that becomes the queue, and only those.
        /// - Throws: `CancellationError` when the task is cancelled or `reset()` ran meanwhile: the
        ///   session controller doesn't wait for its run loop to wind down on `stop()`, so a call from
        ///   the previous session can still be building or authorizing after a location switch. It
        ///   must neither install that batch nor hand out its configurations. Otherwise the last
        ///   authorization error, when every configuration tried failed to authorize, so it isn't
        ///   reported as a bare `noEndpointsAvailable`.
        func next(
            buildBatch: @Sendable () async -> [any VpnConfiguration],
            authorize: @Sendable (any VpnConfiguration) async throws -> any VpnConfiguration,
            didInstall: @Sendable ([any VpnConfiguration]) async -> Void
        ) async throws -> (any VpnConfiguration)? {
            let startGeneration = generation
            var lastAuthorizationError: (any Error)?

            for refill in 0...Self.maxRefillsPerCall {
                if refill > 0 {
                    let batch = await buildBatch()
                    try checkCurrent(startGeneration)
                    // Another call may have installed and partly drained a batch while this one was
                    // building: taking it would hand its endpoints out twice.
                    if pending.isEmpty {
                        pending = batch
                        await didInstall(batch)
                    }
                }

                while !pending.isEmpty {
                    try checkCurrent(startGeneration)
                    let configuration = pending.removeFirst()
                    do {
                        let authorized = try await authorize(configuration)
                        try checkCurrent(startGeneration)
                        return authorized
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        logger.error("Authorization failed — skipping \(configuration.vpnProtocolName) endpoint: \(error)")
                        lastAuthorizationError = error
                    }
                }
            }

            if let lastAuthorizationError {
                throw lastAuthorizationError
            }
            return nil
        }

        /// Drops the rest of the batch, so the next call builds one for the current selection, and
        /// supersedes any call still in flight.
        func reset() {
            if !pending.isEmpty {
                logger.info("Dropping \(pending.count) queued configuration(s)")
            }
            pending.removeAll()
            generation += 1
        }

        private func checkCurrent(_ startGeneration: Int) throws {
            try Task.checkCancellation()
            guard generation == startGeneration else {
                logger.info("Selection changed while fetching a configuration — discarding it")
                throw CancellationError()
            }
        }
    }
}
