
import Foundation

protocol EndpointManagerType {
    func availableEndpoints() -> [PinningEndpoint]
}


extension EndpointManager: EndpointManagerType {}
