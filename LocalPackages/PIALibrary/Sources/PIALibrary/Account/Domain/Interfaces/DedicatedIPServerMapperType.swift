import Foundation

protocol DedicatedIPServerMapperType: Sendable {
    func map(dedicatedIps: [DedicatedIPInformation]) -> Result<[Server], ClientError>
}
