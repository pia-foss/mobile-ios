import Foundation

struct KPIEventUtils {
    private let kpiPersistency: any IKPIPersistency
    private let projectToken: String
    private let clock: () -> Date

    init(
        kpiPersistency: any IKPIPersistency,
        projectToken: String,
        clock: @escaping () -> Date = { Date() }
    ) {
        self.kpiPersistency = kpiPersistency
        self.projectToken = projectToken
        self.clock = clock
    }

    func adaptEvent(_ event: KPIClientEvent) -> KPIEvent {
        KPIEvent(
            aggregatedId: aggregatedIdentifier(),
            uniqueId: UUID().uuidString,
            eventCountry: event.eventCountry,
            eventName: event.eventName,
            eventProperties: event.eventProperties,
            eventTime: Int64((event.eventInstant.timeIntervalSince1970 * 1000.0).rounded()),
            eventToken: projectToken
        )
    }

    private func aggregatedIdentifier() -> String {
        var identifier = kpiPersistency.identifier() ?? newAggregatedIdentifier()

        if let createdAt = Self.makeISO8601Formatter().date(from: identifier.createdAt) {
            let now = clock()
            if !Self.utcCalendar.isDate(now, inSameDayAs: createdAt) {
                identifier = newAggregatedIdentifier()
                kpiPersistency.clearAll()
            }
        }

        kpiPersistency.persistIdentifier(identifier)
        return identifier.aggregatedId
    }

    private func newAggregatedIdentifier() -> KPIEventIdentifier {
        KPIEventIdentifier(
            aggregatedId: UUID().uuidString,
            createdAt: Self.makeISO8601Formatter().string(from: clock())
        )
    }

    private static func makeISO8601Formatter() -> ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
}
