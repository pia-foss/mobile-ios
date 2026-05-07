import Foundation
import os

struct KPILogger: Sendable {
    private let isLoggingEnabled: @Sendable () -> Bool
    private let logger: Logger

    init(isLoggingEnabled: @Sendable @escaping () -> Bool) {
        self.isLoggingEnabled = isLoggingEnabled
        self.logger = Logger(subsystem: "com.privateinternetaccess.kpi", category: "PIAKPI")
    }

    func logInfo(tag: String, message: String) {
        guard isLoggingEnabled() else { return }
        logger.info("[\(tag, privacy: .public)] \(message, privacy: .public)")
    }

    func logDebug(tag: String, message: String) {
        guard isLoggingEnabled() else { return }
        logger.debug("[\(tag, privacy: .public)] \(message, privacy: .public)")
    }

    func logWarning(tag: String, message: String) {
        guard isLoggingEnabled() else { return }
        logger.warning("[\(tag, privacy: .public)] \(message, privacy: .public)")
    }

    func logError(tag: String, message: String) {
        guard isLoggingEnabled() else { return }
        logger.error("[\(tag, privacy: .public)] \(message, privacy: .public)")
    }

    func logWtf(tag: String, message: String) {
        guard isLoggingEnabled() else { return }
        logger.fault("[\(tag, privacy: .public)] \(message, privacy: .public)")
    }
}
