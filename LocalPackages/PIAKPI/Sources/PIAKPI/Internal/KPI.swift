import Foundation

actor KPI: KPIAPI {
    private let tag = "KPI"

    private let kpiClientStateProvider: any KPIClientStateProvider
    private let kpiSendEventMode: KPISendEventsMode
    private let certificate: String?
    private let requestFormat: KPIRequestFormat
    private let userAgent: String?
    private let httpLogLevel: KPIHttpLogLevel
    private let eventTimeRoundGranularity: KTimeUnit
    private let eventTimeSendGranularity: KTimeUnit
    private let eventsBatchSize: Int
    private let eventsHistorySize: Int
    private let requestTimeoutMs: Int64

    private let logger: KPILogger
    private let persistency: KPIPersistence
    private let eventUtils: KPIEventUtils

    private var batchedEvents: [KPIEvent] = []
    private var sampleEvents: [KPIEvent] = []
    private var started = false

    private let encoder = JSONEncoder()

    init(
        kpiClientStateProvider: any KPIClientStateProvider,
        kpiSendEventMode: KPISendEventsMode,
        certificate: String?,
        requestFormat: KPIRequestFormat,
        preferenceName: String,
        userAgent: String?,
        isLoggingEnabled: Bool,
        httpLogLevel: KPIHttpLogLevel,
        eventTimeRoundGranularity: KTimeUnit,
        eventTimeSendGranularity: KTimeUnit,
        eventsBatchSize: Int,
        eventsHistorySize: Int,
        requestTimeoutMs: Int64
    ) {
        self.kpiClientStateProvider = kpiClientStateProvider
        self.kpiSendEventMode = kpiSendEventMode
        self.certificate = certificate
        self.requestFormat = requestFormat
        self.userAgent = userAgent
        self.httpLogLevel = httpLogLevel
        self.eventTimeRoundGranularity = eventTimeRoundGranularity
        self.eventTimeSendGranularity = eventTimeSendGranularity
        self.eventsBatchSize = eventsBatchSize
        self.eventsHistorySize = eventsHistorySize
        self.requestTimeoutMs = requestTimeoutMs

        let logger = KPILogger(isLoggingEnabled: { isLoggingEnabled })
        self.logger = logger
        self.persistency = KPIPersistence(preferenceName: preferenceName, logger: logger)
        self.eventUtils = KPIEventUtils(
            kpiPersistency: persistency,
            projectToken: kpiClientStateProvider.projectToken()
        )
    }

    func start() {
        batchedEvents = persistency.events()
        sampleEvents = persistency.sampleEvents()
        started = true
    }

    func stop() throws {
        batchedEvents = []
        sampleEvents = []
        persistency.clearAll()
        started = false
    }

    func submit(event: KPIClientEvent) async throws {
        let endpoints = kpiClientStateProvider.kpiEndpoints()

        if endpoints.isEmpty {
            throw KPIError(description: "No available endpoints to perform the request.")
        }
        if !started {
            throw KPIError(description: "KPI has not been started. Event discarded.")
        }

        let adapted = eventUtils.adaptEvent(event)
        persistAndQueueEvent(adapted)

        let shouldSendEvents: Bool
        switch kpiSendEventMode {
        case .perEvent: shouldSendEvents = true
        case .perBatch: shouldSendEvents = batchedEvents.count >= eventsBatchSize
        }

        if shouldSendEvents {
            try await sendEvents(endpoints: endpoints)
            clearPersistedAndQueuedEvents()
        }
    }

    func flush() async throws {
        let endpoints = kpiClientStateProvider.kpiEndpoints()
        try await sendEvents(endpoints: endpoints)
        clearPersistedAndQueuedEvents()
    }

    func recentEvents() -> [String] {
        var result: [String] = []
        for event in sampleEvents {
            result.append("EventName: \(event.eventName) ")
            result.append("EventToken: \(kpiClientStateProvider.projectToken()) ")
            for (key, value) in event.eventProperties {
                let line = "EventProperties.\(key.snakeToPascalCase()): \(value) "
                result.append(line.trimmingCharacters(in: .whitespaces))
            }
            result.append("")
        }
        return result
    }

    private func sendEvents(endpoints: [KPIEndpoint]) async throws {
        var error: KPIError? = nil

        if endpoints.isEmpty {
            error = KPIError(description: "No available endpoints to perform the request.")
        }
        if !started {
            error = KPIError(description: "KPI has not been started. Events will not be sent.")
        }

        let events: [KPIEvent]
        switch kpiSendEventMode {
        case .perEvent, .perBatch:
            events = batchedEvents
            batchedEvents = []
        }

        if events.isEmpty {
            error = KPIError(description: "There are no events in queue. Skipping request.")
        }

        if error == nil {
            for endpoint in endpoints {
                if endpoint.usePinnedCertificate, (certificate?.isEmpty ?? true) {
                    error = KPIError(description: "No available certificate for pinning purposes")
                    continue
                }

                error = nil

                let pinnedEndpoint: (host: String, commonName: String)?
                if endpoint.usePinnedCertificate, let commonName = endpoint.certificateCommonName {
                    pinnedEndpoint = (endpoint.endpoint, commonName)
                } else {
                    pinnedEndpoint = nil
                }

                let config = KPIHttpRequestConfig(
                    logLevel: httpLogLevel,
                    userAgent: userAgent,
                    certificate: endpoint.usePinnedCertificate ? certificate : nil,
                    pinnedEndpoint: pinnedEndpoint,
                    requestTimeoutMs: requestTimeoutMs
                )

                let urlString = "https://\(endpoint.endpoint)"
                var headers: [String: String] = [:]
                let body: Data

                do {
                    switch requestFormat {
                    case .kape:
                        if let token = kpiClientStateProvider.kpiAuthToken() {
                            headers["Authorization"] = "Token \(token)"
                        }
                        headers["Content-Type"] = "application/json"
                        body = try KPIPlatformUtils.encodeWithKapeFormat(
                            events: events,
                            eventTimeRoundGranularity: eventTimeRoundGranularity,
                            eventTimeSendGranularity: eventTimeSendGranularity,
                            encoder: encoder
                        )
                    case .elastic:
                        headers["Content-Type"] = "application/x-www-form-urlencoded"
                        body = try KPIPlatformUtils.encodeWithElasticFormat(
                            events: events,
                            eventRoundTimeGranularity: eventTimeRoundGranularity,
                            eventSendTimeGranularity: eventTimeSendGranularity,
                            encoder: encoder
                        )
                    }
                } catch {
                    let description = (error as? KPIError)?.description ?? String(describing: error)
                    batchedEvents.append(contentsOf: events)
                    throw KPIError(description: description)
                }

                let (response, throwable) = await KPIHttpClient.post(
                    urlString: urlString,
                    body: body,
                    headers: headers,
                    config: config
                )

                if let response {
                    if KPIUtils.isErrorStatusCode(response.statusCode) {
                        error = KPIError(description: "\(response.description) (\(response.statusCode))")
                    }
                }
                if let throwable {
                    let message: String
                    if let kpiError = throwable as? KPIError {
                        message = kpiError.description
                    } else if let httpError = throwable as? KPIHttpError {
                        message = httpError.description
                    } else {
                        message = (throwable as NSError).localizedDescription
                    }
                    error = KPIError(description: "\(message) (600)")
                }

                if error == nil {
                    break
                }
            }

            if let error {
                batchedEvents.append(contentsOf: events)
                throw error
            }
        } else if let error {
            throw error
        }
    }

    private func persistAndQueueEvent(_ event: KPIEvent) {
        persistency.persistEvent(event, eventHistorySize: eventsHistorySize)

        batchedEvents.append(event)

        if sampleEvents.count >= eventsHistorySize, !sampleEvents.isEmpty {
            sampleEvents.removeFirst()
        }
        sampleEvents.append(event)
    }

    private func clearPersistedAndQueuedEvents() {
        persistency.clearBatchedEvents()
        batchedEvents = []
    }
}
