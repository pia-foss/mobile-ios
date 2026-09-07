import Foundation

protocol SignupInformationDataCoverterType: Sendable {
    func callAsFunction(signup: Signup) -> Data?
}
