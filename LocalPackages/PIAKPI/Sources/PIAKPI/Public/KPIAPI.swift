import Foundation

public protocol KPIAPI: Sendable {
    func start() async
    func stop() async throws
    func submit(event: KPIClientEvent) async throws
    func flush() async throws
    func recentEvents() async -> [String]
}
