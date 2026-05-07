import Foundation

struct KPIEventsRequestPayload: Encodable {
    let events: [KPIEvent]
}

enum KPIPlatformUtils {
    static func encodeWithKapeFormat(
        events: [KPIEvent],
        eventTimeRoundGranularity: KTimeUnit,
        eventTimeSendGranularity: KTimeUnit,
        encoder: JSONEncoder
    ) throws -> Data {
        let sendEvents: [KPIEvent] = events.map { event in
            KPIEvent(
                aggregatedId: event.aggregatedId,
                uniqueId: event.uniqueId,
                eventCountry: event.eventCountry,
                eventName: event.eventName,
                eventProperties: event.eventProperties,
                eventTime: adjustSendTime(
                    eventTime: event.eventTime,
                    eventRoundTimeGranularity: eventTimeRoundGranularity,
                    eventSendTimeGranularity: eventTimeSendGranularity
                ),
                eventToken: event.eventToken
            )
        }
        let payload = KPIEventsRequestPayload(events: sendEvents)
        return try encoder.encode(payload)
    }

    static func encodeWithElasticFormat(
        events: [KPIEvent],
        eventRoundTimeGranularity: KTimeUnit,
        eventSendTimeGranularity: KTimeUnit,
        encoder: JSONEncoder
    ) throws -> Data {
        let elasticEvents: [ElasticEvent] = events.map { event in
            ElasticEvent(
                event: event.eventName,
                properties: createElasticProperties(
                    event: event,
                    eventRoundTimeGranularity: eventRoundTimeGranularity,
                    eventSendTimeGranularity: eventSendTimeGranularity
                )
            )
        }
        let json = try encoder.encode(elasticEvents)
        let base64 = json.base64EncodedString()
        guard let body = "data=\(base64)".data(using: .utf8) else {
            throw KPIError(description: "cannot encode elastic body to utf8")
        }
        return body
    }

    private static func createElasticProperties(
        event: KPIEvent,
        eventRoundTimeGranularity: KTimeUnit,
        eventSendTimeGranularity: KTimeUnit
    ) -> [String: String] {
        var properties = event.eventProperties
        properties["time"] = String(
            adjustSendTime(
                eventTime: event.eventTime,
                eventRoundTimeGranularity: eventRoundTimeGranularity,
                eventSendTimeGranularity: eventSendTimeGranularity
            )
        )
        properties["token"] = event.eventToken
        if let country = event.eventCountry {
            properties["country"] = country
        }
        return properties
    }

    private static func adjustSendTime(
        eventTime: Int64,
        eventRoundTimeGranularity: KTimeUnit,
        eventSendTimeGranularity: KTimeUnit
    ) -> Int64 {
        let timeInMilliSeconds = eventTime
        return eventSendTimeGranularity.convert(
            eventRoundTimeGranularity.convert(timeInMilliSeconds, from: .milliseconds),
            from: eventRoundTimeGranularity
        )
    }
}

struct ElasticEvent: Codable, Sendable, Equatable {
    let event: String
    let properties: [String: String]
}
