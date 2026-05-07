import Foundation

public enum KPISendEventsMode: Sendable {
    case perEvent
    case perBatch
}

public enum KPIRequestFormat: Sendable {
    case elastic
    case kape
}

public enum KPIHttpLogLevel: Sendable {
    case all
    case headers
    case body
    case info
    case none
}

public enum KTimeUnit: Sendable {
    case nanoseconds
    case microseconds
    case milliseconds
    case seconds
    case minutes
    case hours
    case days

    public func convert(_ sourceDuration: Int64, from sourceUnit: KTimeUnit) -> Int64 {
        switch self {
        case .nanoseconds: return sourceUnit.toNanos(sourceDuration)
        case .microseconds: return sourceUnit.toMicros(sourceDuration)
        case .milliseconds: return sourceUnit.toMillis(sourceDuration)
        case .seconds: return sourceUnit.toSeconds(sourceDuration)
        case .minutes: return sourceUnit.toMinutes(sourceDuration)
        case .hours: return sourceUnit.toHours(sourceDuration)
        case .days: return sourceUnit.toDays(sourceDuration)
        }
    }

    public func toNanos(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration
        case .microseconds: return Self.scale(duration, magnitude: Self.microsecondInNanoseconds, overflow: Int64.max / Self.microsecondInNanoseconds)
        case .milliseconds: return Self.scale(duration, magnitude: Self.millisecondInNanoseconds, overflow: Int64.max / Self.millisecondInNanoseconds)
        case .seconds: return Self.scale(duration, magnitude: Self.secondInNanoseconds, overflow: Int64.max / Self.secondInNanoseconds)
        case .minutes: return Self.scale(duration, magnitude: Self.minuteInNanoseconds, overflow: Int64.max / Self.minuteInNanoseconds)
        case .hours: return Self.scale(duration, magnitude: Self.hourInNanoseconds, overflow: Int64.max / Self.hourInNanoseconds)
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds, overflow: Int64.max / Self.dayInNanoseconds)
        }
    }

    public func toMicros(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.microsecondInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration
        case .milliseconds: return Self.scale(duration, magnitude: Self.millisecondInNanoseconds / Self.microsecondInNanoseconds, overflow: Int64.max / (Self.millisecondInNanoseconds / Self.microsecondInNanoseconds))
        case .seconds: return Self.scale(duration, magnitude: Self.secondInNanoseconds / Self.microsecondInNanoseconds, overflow: Int64.max / (Self.secondInNanoseconds / Self.microsecondInNanoseconds))
        case .minutes: return Self.scale(duration, magnitude: Self.minuteInNanoseconds / Self.microsecondInNanoseconds, overflow: Int64.max / (Self.minuteInNanoseconds / Self.microsecondInNanoseconds))
        case .hours: return Self.scale(duration, magnitude: Self.hourInNanoseconds / Self.microsecondInNanoseconds, overflow: Int64.max / (Self.hourInNanoseconds / Self.microsecondInNanoseconds))
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds / Self.microsecondInNanoseconds, overflow: Int64.max / (Self.dayInNanoseconds / Self.microsecondInNanoseconds))
        }
    }

    public func toMillis(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.millisecondInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration / (Self.millisecondInNanoseconds / Self.microsecondInNanoseconds)
        case .milliseconds: return duration
        case .seconds: return Self.scale(duration, magnitude: Self.secondInNanoseconds / Self.millisecondInNanoseconds, overflow: Int64.max / (Self.secondInNanoseconds / Self.millisecondInNanoseconds))
        case .minutes: return Self.scale(duration, magnitude: Self.minuteInNanoseconds / Self.millisecondInNanoseconds, overflow: Int64.max / (Self.minuteInNanoseconds / Self.millisecondInNanoseconds))
        case .hours: return Self.scale(duration, magnitude: Self.hourInNanoseconds / Self.millisecondInNanoseconds, overflow: Int64.max / (Self.hourInNanoseconds / Self.millisecondInNanoseconds))
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds / Self.millisecondInNanoseconds, overflow: Int64.max / (Self.dayInNanoseconds / Self.millisecondInNanoseconds))
        }
    }

    public func toSeconds(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.secondInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration / (Self.secondInNanoseconds / Self.microsecondInNanoseconds)
        case .milliseconds: return duration / (Self.secondInNanoseconds / Self.millisecondInNanoseconds)
        case .seconds: return duration
        case .minutes: return Self.scale(duration, magnitude: Self.minuteInNanoseconds / Self.secondInNanoseconds, overflow: Int64.max / (Self.minuteInNanoseconds / Self.secondInNanoseconds))
        case .hours: return Self.scale(duration, magnitude: Self.hourInNanoseconds / Self.secondInNanoseconds, overflow: Int64.max / (Self.hourInNanoseconds / Self.secondInNanoseconds))
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds / Self.secondInNanoseconds, overflow: Int64.max / (Self.dayInNanoseconds / Self.secondInNanoseconds))
        }
    }

    public func toMinutes(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.minuteInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration / (Self.minuteInNanoseconds / Self.microsecondInNanoseconds)
        case .milliseconds: return duration / (Self.minuteInNanoseconds / Self.millisecondInNanoseconds)
        case .seconds: return duration / (Self.minuteInNanoseconds / Self.secondInNanoseconds)
        case .minutes: return duration
        case .hours: return Self.scale(duration, magnitude: Self.hourInNanoseconds / Self.minuteInNanoseconds, overflow: Int64.max / (Self.hourInNanoseconds / Self.minuteInNanoseconds))
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds / Self.minuteInNanoseconds, overflow: Int64.max / (Self.dayInNanoseconds / Self.minuteInNanoseconds))
        }
    }

    public func toHours(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.hourInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration / (Self.hourInNanoseconds / Self.microsecondInNanoseconds)
        case .milliseconds: return duration / (Self.hourInNanoseconds / Self.millisecondInNanoseconds)
        case .seconds: return duration / (Self.hourInNanoseconds / Self.secondInNanoseconds)
        case .minutes: return duration / (Self.hourInNanoseconds / Self.minuteInNanoseconds)
        case .hours: return duration
        case .days: return Self.scale(duration, magnitude: Self.dayInNanoseconds / Self.hourInNanoseconds, overflow: Int64.max / (Self.dayInNanoseconds / Self.hourInNanoseconds))
        }
    }

    public func toDays(_ duration: Int64) -> Int64 {
        switch self {
        case .nanoseconds: return duration / (Self.dayInNanoseconds / Self.nanosecondInNanoseconds)
        case .microseconds: return duration / (Self.dayInNanoseconds / Self.microsecondInNanoseconds)
        case .milliseconds: return duration / (Self.dayInNanoseconds / Self.millisecondInNanoseconds)
        case .seconds: return duration / (Self.dayInNanoseconds / Self.secondInNanoseconds)
        case .minutes: return duration / (Self.dayInNanoseconds / Self.minuteInNanoseconds)
        case .hours: return duration / (Self.dayInNanoseconds / Self.hourInNanoseconds)
        case .days: return duration
        }
    }

    private static let nanosecondInNanoseconds: Int64 = 1
    private static let microsecondInNanoseconds: Int64 = 1_000
    private static let millisecondInNanoseconds: Int64 = 1_000_000
    private static let secondInNanoseconds: Int64 = 1_000_000_000
    private static let minuteInNanoseconds: Int64 = 60_000_000_000
    private static let hourInNanoseconds: Int64 = 3_600_000_000_000
    private static let dayInNanoseconds: Int64 = 86_400_000_000_000

    private static func scale(_ duration: Int64, magnitude: Int64, overflow: Int64) -> Int64 {
        if duration > overflow { return .max }
        if duration < -overflow { return .min }
        return duration * magnitude
    }
}
