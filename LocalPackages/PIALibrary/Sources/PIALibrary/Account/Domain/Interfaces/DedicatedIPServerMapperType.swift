
import Foundation

protocol DedicatedIPServerMapperType {
    func map(dedicatedIps: [DedicatedIPInformation]) -> Result<[Server], ClientError>
}
