import Foundation
import NWHttpConnection

enum NWHttpConnectionResponseError: Error {
    case noResponse
}

extension NWHttpConnectionType {
    func singleResponse() async throws -> NWHttpConnectionDataResponseType {
        try await withCheckedThrowingContinuation { continuation in
            let resumer = SingleResumer(continuation)
            do {
                try connect(
                    requestHandler: { error, response in
                        if let error {
                            resumer.resume(with: .failure(error))
                        } else if let response {
                            resumer.resume(with: .success(response))
                        } else {
                            resumer.resume(with: .failure(NWHttpConnectionResponseError.noResponse))
                        }
                    },
                    completion: {
                        resumer.resume(with: .failure(NWHttpConnectionResponseError.noResponse))
                    })
            } catch {
                resumer.resume(with: .failure(error))
            }
        }
    }
}

private final class SingleResumer<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Error>?

    init(_ continuation: CheckedContinuation<T, Error>) {
        self.continuation = continuation
    }

    func resume(with result: Result<T, Error>) {
        lock.lock()
        let pending = continuation
        continuation = nil
        lock.unlock()

        pending?.resume(with: result)
    }
}
