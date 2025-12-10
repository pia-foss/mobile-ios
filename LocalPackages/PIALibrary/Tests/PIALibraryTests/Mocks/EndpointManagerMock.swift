
import Foundation
@testable import PIALibrary

class EndpointManagerMock: EndpointManagerType {
    
    var availableEndpointsCalledAttempt = 0
    var availableEndpointsResult = [PinningEndpoint]()
    func availableEndpoints() -> [PinningEndpoint] {
        availableEndpointsCalledAttempt += 1
        return availableEndpointsResult
    }
}
