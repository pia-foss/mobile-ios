import Testing

// Suites mutating the global Client.preferences must not run in parallel with each other.
@Suite(.serialized)
enum ClientPreferencesTests {}
