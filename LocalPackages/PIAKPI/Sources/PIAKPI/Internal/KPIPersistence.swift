import Foundation

protocol IKPIPersistency {
    func persistIdentifier(_ identifier: KPIEventIdentifier)
    func identifier() -> KPIEventIdentifier?
    func persistEvent(_ event: KPIEvent, eventHistorySize: Int)
    func events() -> [KPIEvent]
    func sampleEvents() -> [KPIEvent]
    func clearBatchedEvents()
    func clearAll()
}

final class KPIPersistence: IKPIPersistency {
    static let batchedEventsKey = "pia.kpi.batched_events.v1"
    static let sampleEventsKey = "pia.kpi.sample_events.v1"
    static let aggregatedIdKey = "pia.kpi.aggregated_id.v1"

    private let tag = "KPIPersistence"
    private let defaults: UserDefaults?
    private let logger: KPILogger
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(preferenceName: String, logger: KPILogger) {
        self.defaults = UserDefaults(suiteName: preferenceName)
        self.logger = logger
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    private var isValid: Bool { defaults != nil }

    func persistIdentifier(_ identifier: KPIEventIdentifier) {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return
        }
        do {
            let data = try encoder.encode(identifier)
            defaults.set(data, forKey: Self.aggregatedIdKey)
        } catch {
            logger.logError(tag: tag, message: String(describing: error))
        }
    }

    func identifier() -> KPIEventIdentifier? {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return nil
        }
        guard let data = defaults.data(forKey: Self.aggregatedIdKey) else {
            return nil
        }
        do {
            return try decoder.decode(KPIEventIdentifier.self, from: data)
        } catch {
            defaults.removeObject(forKey: Self.aggregatedIdKey)
            return nil
        }
    }

    func persistEvent(_ event: KPIEvent, eventHistorySize: Int) {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return
        }

        var batched = events()
        batched.append(event)
        do {
            defaults.set(try encoder.encode(batched), forKey: Self.batchedEventsKey)
        } catch {
            logger.logError(tag: tag, message: String(describing: error))
        }

        var recent = sampleEvents()
        if recent.count > eventHistorySize, !recent.isEmpty {
            recent.removeFirst()
        }
        recent.append(event)
        do {
            defaults.set(try encoder.encode(recent), forKey: Self.sampleEventsKey)
        } catch {
            logger.logError(tag: tag, message: String(describing: error))
        }
    }

    func events() -> [KPIEvent] {
        persistedEvents(forKey: Self.batchedEventsKey)
    }

    func sampleEvents() -> [KPIEvent] {
        persistedEvents(forKey: Self.sampleEventsKey)
    }

    func clearBatchedEvents() {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return
        }
        defaults.removeObject(forKey: Self.batchedEventsKey)
    }

    func clearAll() {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return
        }
        defaults.removeObject(forKey: Self.batchedEventsKey)
        defaults.removeObject(forKey: Self.sampleEventsKey)
    }

    private func persistedEvents(forKey key: String) -> [KPIEvent] {
        guard let defaults, isValid else {
            logger.logDebug(tag: tag, message: "KPIPreferences are invalid")
            return []
        }
        guard let data = defaults.data(forKey: key), !data.isEmpty else {
            logger.logDebug(tag: tag, message: "KPIPreferences: no data for key '\(key)'")
            return []
        }
        do {
            return try decoder.decode([KPIEvent].self, from: data)
        } catch {
            defaults.removeObject(forKey: key)
            return []
        }
    }
}
