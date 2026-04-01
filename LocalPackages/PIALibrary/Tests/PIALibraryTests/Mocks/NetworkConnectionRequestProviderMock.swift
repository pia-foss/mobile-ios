
import Foundation
import NWHttpConnection
@testable import PIALibrary


class NetworkConnectionRequestProviderMock: NetworkConnectionRequestProviderType {
    
    var makeNetworkRequestConnectionCalledAttempt = 0
    var makeNetworkRequestConnectionWithPinningEndpoint: PinningEndpoint?
    var makeNetworkRequestConnectionWithConfiguration: NetworkRequestConfigurationType?
    var makeNetworkRequestConnectionResults = [NWHttpConnection.NWHttpConnectionType]()
    
    func makeNetworkRequestConnection(for endpoint: PIALibrary.PinningEndpoint, with configuration: PIALibrary.NetworkRequestConfigurationType) -> NWHttpConnection.NWHttpConnectionType? {
        
        makeNetworkRequestConnectionCalledAttempt += 1
        makeNetworkRequestConnectionWithPinningEndpoint = endpoint
        makeNetworkRequestConnectionWithConfiguration = configuration
        
        guard makeNetworkRequestConnectionResults.count >= makeNetworkRequestConnectionCalledAttempt else { return nil
        }
        
        return makeNetworkRequestConnectionResults[makeNetworkRequestConnectionCalledAttempt - 1]
        
    }
    
    
}
