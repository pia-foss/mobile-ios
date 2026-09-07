import Foundation

final class MockRenewDedicatedIPUseCase: RenewDedicatedIPUseCaseType {
    func callAsFunction(dipToken: String, completion: @escaping Completion) {}
}
