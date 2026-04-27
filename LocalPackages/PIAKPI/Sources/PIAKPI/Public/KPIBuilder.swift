import Foundation

public final class KPIBuilder: @unchecked Sendable {
    public static let defaultEventsBatchSize: Int = 20
    public static let defaultEventsHistorySize: Int = 50
    public static let defaultRequestTimeoutMs: Int64 = 3_000

    private var kpiClientStateProvider: KPIClientStateProvider?
    private var kpiSendEventMode: KPISendEventsMode?
    private var userAgent: String?
    private var certificate: String?
    private var preferenceName: String?
    private var isLoggingEnabled: Bool = false
    private var requestFormat: KPIRequestFormat = .kape
    private var httpLogLevel: KPIHttpLogLevel = .none
    private var eventsBatchSize: Int = KPIBuilder.defaultEventsBatchSize
    private var eventsHistorySize: Int = KPIBuilder.defaultEventsHistorySize
    private var requestTimeoutMs: Int64 = KPIBuilder.defaultRequestTimeoutMs
    private var eventTimeRoundGranularity: KTimeUnit = .milliseconds
    private var eventTimeSendGranularity: KTimeUnit = .milliseconds

    public init() {}

    @discardableResult
    public func setUserAgent(_ userAgent: String?) -> KPIBuilder {
        self.userAgent = userAgent
        return self
    }

    @discardableResult
    public func setKPIClientStateProvider(_ provider: KPIClientStateProvider) -> KPIBuilder {
        self.kpiClientStateProvider = provider
        return self
    }

    @discardableResult
    public func setFlushEventMode(_ mode: KPISendEventsMode) -> KPIBuilder {
        self.kpiSendEventMode = mode
        return self
    }

    @discardableResult
    public func setCertificate(_ certificate: String) -> KPIBuilder {
        self.certificate = certificate
        return self
    }

    @discardableResult
    public func setRequestFormat(_ format: KPIRequestFormat) -> KPIBuilder {
        self.requestFormat = format
        return self
    }

    @discardableResult
    public func setEventTimeRoundGranularity(_ unit: KTimeUnit) -> KPIBuilder {
        self.eventTimeRoundGranularity = unit
        return self
    }

    @discardableResult
    public func setEventTimeSendGranularity(_ unit: KTimeUnit) -> KPIBuilder {
        self.eventTimeSendGranularity = unit
        return self
    }

    @discardableResult
    public func setPreferenceName(_ name: String) -> KPIBuilder {
        self.preferenceName = name
        return self
    }

    @discardableResult
    public func setLoggingEnabled(_ enabled: Bool) -> KPIBuilder {
        self.isLoggingEnabled = enabled
        return self
    }

    @discardableResult
    public func setHttpLogLevel(_ level: KPIHttpLogLevel) -> KPIBuilder {
        self.httpLogLevel = level
        return self
    }

    @discardableResult
    public func setEventsBatchSize(_ size: Int) -> KPIBuilder {
        self.eventsBatchSize = size
        return self
    }

    @discardableResult
    public func setEventsHistorySize(_ size: Int) -> KPIBuilder {
        self.eventsHistorySize = size
        return self
    }

    @discardableResult
    public func setRequestTimeoutMs(_ timeout: Int64) -> KPIBuilder {
        self.requestTimeoutMs = timeout
        return self
    }

    public func build() -> any KPIAPI {
        guard let kpiClientStateProvider else {
            fatalError("KPI client state provider missing.")
        }
        guard let kpiSendEventMode else {
            fatalError("KPI events send mode missing.")
        }
        guard let preferenceName else {
            fatalError("KPI preferences scope name missing.")
        }
        precondition(eventsBatchSize >= 1, "KPI events batch size invalid. Minimum supported is 1.")
        precondition(eventsHistorySize >= 1, "KPI events history size invalid. Minimum supported is 1.")
        precondition(requestTimeoutMs >= 1, "KPI request timeout invalid. Minimum supported is 1.")

        return KPI(
            kpiClientStateProvider: kpiClientStateProvider,
            kpiSendEventMode: kpiSendEventMode,
            certificate: certificate,
            requestFormat: requestFormat,
            preferenceName: preferenceName,
            userAgent: userAgent,
            isLoggingEnabled: isLoggingEnabled,
            httpLogLevel: httpLogLevel,
            eventTimeRoundGranularity: eventTimeRoundGranularity,
            eventTimeSendGranularity: eventTimeSendGranularity,
            eventsBatchSize: eventsBatchSize,
            eventsHistorySize: eventsHistorySize,
            requestTimeoutMs: requestTimeoutMs
        )
    }
}
