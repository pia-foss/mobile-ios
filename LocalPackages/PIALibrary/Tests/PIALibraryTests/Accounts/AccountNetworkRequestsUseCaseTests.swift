
import XCTest
import NWHttpConnection
@testable import PIALibrary



class AccountNetworkRequestsUseCaseTests: XCTestCase {
    class Fixture {
        var connectionMock1 = NWHttpConnectionMock()
        var connectionMock2 = NWHttpConnectionMock()
        
        static let successResponse = NetworkRequestResponseMock(statusCode: 200, dataFormat: .jsonData, data: nil)
        
        func stubConnectionResponse(_ response: NWHttpConnectionDataResponseType, on connection: NWHttpConnectionMock) {
            connection.connectionResponse = response
        }
        
        func stubConnectionError(_ error: NWHttpConnection.NWHttpConnectionError, on connection: NWHttpConnectionMock) {
            connection.connectionError = error
        }
    }
    
    var fixture: Fixture!
    var sut: NetworkRequestClient!
    
    override func setUp() {
        fixture = Fixture()
    }
    
    override func tearDown() {
        fixture = nil
        sut = nil
    }
    
    private func instantiateSut() {
        
    }
    
}
