
import Foundation

class MockDedicatedIPServerMapper: DedicatedIPServerMapperType {
    func map(dedicatedIps: [DedicatedIPInformation]) -> Result<[Server], ClientError> {
        return .success([])
    }
}
