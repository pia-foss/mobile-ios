import Foundation

public protocol KPIClientStateProvider: Sendable {
    func kpiEndpoints() -> [KPIEndpoint]
    func kpiAuthToken() -> String?
    func projectToken() -> String
}
