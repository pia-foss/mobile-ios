import Foundation

protocol EndpointManagerType: Sendable {
    func availableEndpoints() -> [PinningEndpoint]
}

extension EndpointManager: EndpointManagerType {}
