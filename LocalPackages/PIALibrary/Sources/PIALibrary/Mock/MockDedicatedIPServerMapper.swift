import Foundation

final class MockDedicatedIPServerMapper: DedicatedIPServerMapperType {
    func map(dedicatedIps: [DedicatedIPInformation]) -> Result<[Server], ClientError> {
        return .success([])
    }
}
