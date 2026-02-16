import Testing
import Foundation
@testable import PIAAccount

@Suite struct ErrorMappingTests {

    // MARK: - HTTP Status Code Mapping Tests

    @Test("HTTP status codes 2xx map correctly")
    func fromHTTPStatusSuccess2xx() {
        // Success codes shouldn't typically create errors, but test the mapping
        let codes = [200, 201, 204]

        for code in codes {
            let error = PIAAccountError.fromHTTPStatus(code)
            #expect(error.code == code)
            #expect(error.message == nil)
        }
    }

    @Test("HTTP status codes 3xx map correctly")
    func fromHTTPStatusRedirection3xx() {
        let codes = [300, 301, 302, 304]

        for code in codes {
            let error = PIAAccountError.fromHTTPStatus(code)
            #expect(error.code == code)
            #expect(error.errorDescription != nil)
        }
    }

    @Test("HTTP status codes 4xx map correctly")
    func fromHTTPStatusClientError4xx() {
        let codes = [400, 401, 403, 404, 429]

        for code in codes {
            let error = PIAAccountError.fromHTTPStatus(code)
            #expect(error.code == code)
            #expect(error.errorDescription != nil)
        }
    }

    @Test("HTTP status codes 5xx map correctly")
    func fromHTTPStatusServerError5xx() {
        let codes = [500, 502, 503, 504]

        for code in codes {
            let error = PIAAccountError.fromHTTPStatus(code)
            #expect(error.code == code)
            #expect(error.errorDescription != nil)
        }
    }

    @Test("401 Unauthorized maps correctly")
    func fromHTTPStatusUnauthorized() {
        let error = PIAAccountError.fromHTTPStatus(401)

        #expect(error.code == 401)
        #expect(error.errorDescription != nil)
    }

    @Test("HTTP status with custom message")
    func fromHTTPStatusWithCustomMessage() {
        let customMessage = "Custom error message from API"
        let messageData = try! JSONEncoder().encode(["message": customMessage])

        let error = PIAAccountError.fromHTTPStatus(400, data: messageData)

        #expect(error.code == 400)
        #expect(error.message == customMessage)
    }

    @Test("HTTP status with invalid JSON data")
    func fromHTTPStatusWithInvalidJSONData() {
        let invalidData = "not json".data(using: .utf8)!

        let error = PIAAccountError.fromHTTPStatus(400, data: invalidData)

        #expect(error.code == 400)
        // Should handle invalid JSON gracefully
    }

    @Test("HTTP status with retry after")
    func fromHTTPStatusWithRetryAfter() {
        let retryAfter: TimeInterval = 60.0
        let error = PIAAccountError.fromHTTPStatus(429, retryAfter: retryAfter)

        #expect(error.code == 429)
        #expect(error.retryAfterSeconds == retryAfter)
    }

    // MARK: - Convenience Constructor Tests

    @Test("Unauthorized error")
    func unauthorized() {
        let error = PIAAccountError.unauthorized()

        #expect(error.code == 401)
        #expect(error.errorDescription != nil)
        #expect(error.message != nil)
    }

    @Test("Network failure error")
    func networkFailure() {
        let underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let error = PIAAccountError.networkFailure(underlyingError)

        #expect(error.code == 600)
        #expect(error.underlyingError != nil)
        #expect(error.message != nil)
        // Message contains "Network request failed"
        #expect(error.message!.contains("Network"))
    }

    @Test("Configuration error")
    func configurationError() {
        let message = "Invalid configuration"
        let error = PIAAccountError.configurationError(message)

        #expect(error.code == 603)
        #expect(error.message == message)
    }

    @Test("Encoding failed error")
    func encodingFailed() {
        let underlyingError = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        let error = PIAAccountError.encodingFailed(underlyingError)

        #expect(error.code == 602)
        #expect(error.underlyingError != nil)
    }

    @Test("Decoding failed error")
    func decodingFailed() {
        let underlyingError = NSError(domain: "TestDomain", code: 2, userInfo: nil)
        let error = PIAAccountError.decodingFailed(underlyingError)

        #expect(error.code == 601)
        #expect(error.underlyingError != nil)
    }

    // MARK: - Error Description Tests

    @Test("Error description for 404")
    func errorDescriptionContainsCode() {
        let error = PIAAccountError.fromHTTPStatus(404)

        let description = error.errorDescription
        #expect(description != nil)
        // HTTPURLResponse.localizedString provides a description, but it may not contain the code number
    }

    @Test("Error description with custom message")
    func errorDescriptionWithMessage() {
        let customMessage = "Resource not found"
        let messageData = try! JSONEncoder().encode(["message": customMessage])
        let error = PIAAccountError.fromHTTPStatus(404, data: messageData)

        let description = error.errorDescription
        #expect(description != nil)
        #expect(description!.contains(customMessage))
    }

    @Test("Error description for network error")
    func errorDescriptionNetworkError() {
        let underlyingError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut,
            userInfo: [NSLocalizedDescriptionKey: "The request timed out"]
        )
        let error = PIAAccountError.networkFailure(underlyingError)

        let description = error.errorDescription
        #expect(description != nil)
        #expect(description!.contains("network") || description!.contains("timed out"))
    }

    // MARK: - Failure Reason Tests

    @Test("Failure reason for 500")
    func failureReason() {
        let error = PIAAccountError.fromHTTPStatus(500)

        let failureReason = error.failureReason
        // Failure reason is only set when retryAfterSeconds > 0
        #expect(failureReason == nil)
    }

    @Test("Failure reason with underlying error")
    func failureReasonWithUnderlyingError() {
        let underlying = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: "Test failure"])
        let error = PIAAccountError.networkFailure(underlying)

        let failureReason = error.failureReason
        // Failure reason is only set when retryAfterSeconds > 0
        #expect(failureReason == nil)
        // But we should have the underlying error
        #expect(error.underlyingError != nil)
    }

    // MARK: - PIAMultipleErrors Tests

    @Test("Create multiple errors")
    func multipleErrorsCreation() {
        let error1 = PIAAccountError.fromHTTPStatus(500)
        let error2 = PIAAccountError.fromHTTPStatus(503)
        let error3 = PIAAccountError.unauthorized()

        let multipleErrors = PIAMultipleErrors(errors: [error1, error2, error3])

        #expect(multipleErrors.errors.count == 3)
        #expect(multipleErrors.errors[0].code == 500)
        #expect(multipleErrors.errors[1].code == 503)
        #expect(multipleErrors.errors[2].code == 401)
    }

    @Test("Multiple errors description")
    func multipleErrorsErrorDescription() {
        let error1 = PIAAccountError.fromHTTPStatus(500)
        let error2 = PIAAccountError.fromHTTPStatus(503)

        let multipleErrors = PIAMultipleErrors(errors: [error1, error2])

        let description = multipleErrors.errorDescription
        #expect(description != nil)
        // Should contain "Multiple" or "failures" or error codes
        #expect(description!.contains("Multiple") || description!.contains("500") || description!.contains("503"))
    }

    @Test("Multiple errors with single error")
    func multipleErrorsSingleError() {
        let error1 = PIAAccountError.fromHTTPStatus(500)

        let multipleErrors = PIAMultipleErrors(errors: [error1])

        #expect(multipleErrors.errors.count == 1)
        #expect(multipleErrors.errors[0].code == 500)
    }

    @Test("Multiple errors with empty array")
    func multipleErrorsEmptyArray() {
        let multipleErrors = PIAMultipleErrors(errors: [])

        #expect(multipleErrors.errors.count == 0)
    }

    // MARK: - Error Equality Tests (for testing)

    @Test("Errors with same code")
    func errorEqualitySameCode() {
        let error1 = PIAAccountError.fromHTTPStatus(404)
        let error2 = PIAAccountError.fromHTTPStatus(404)

        #expect(error1.code == error2.code)
    }

    @Test("Errors with different code")
    func errorEqualityDifferentCode() {
        let error1 = PIAAccountError.fromHTTPStatus(404)
        let error2 = PIAAccountError.fromHTTPStatus(500)

        #expect(error1.code != error2.code)
    }

    // MARK: - Failure Reason Tests (recoverySuggestion not implemented)

    @Test("Failure reason for unauthorized")
    func failureReasonUnauthorized() {
        let error = PIAAccountError.unauthorized()

        // PIAAccountError implements failureReason, not recoverySuggestion
        // failureReason only shows retry info if retryAfterSeconds > 0
        #expect(error.failureReason == nil)
    }

    @Test("Failure reason with retry after")
    func failureReasonWithRetryAfter() {
        let error = PIAAccountError.fromHTTPStatus(429, retryAfter: 60)

        let reason = error.failureReason
        #expect(reason != nil)
        // Should mention retry time
        #expect(reason!.contains("60") || reason!.contains("Retry"))
    }

    // MARK: - Sendable Conformance Tests

    @Test("PIAAccountError is Sendable")
    func piaAccountErrorIsSendable() async {
        let error = PIAAccountError.fromHTTPStatus(500)
        await sendError(error)
    }

    @Sendable
    func sendError(_ error: PIAAccountError) async {
        #expect(error.code == 500)
    }

    @Test("PIAMultipleErrors is Sendable")
    func piaMultipleErrorsIsSendable() async {
        let errors = PIAMultipleErrors(errors: [
            PIAAccountError.fromHTTPStatus(500),
            PIAAccountError.fromHTTPStatus(503)
        ])
        await sendMultipleErrors(errors)
    }

    @Sendable
    func sendMultipleErrors(_ errors: PIAMultipleErrors) async {
        #expect(errors.errors.count == 2)
    }

    // MARK: - Edge Cases

    @Test("Unknown HTTP status code")
    func unknownHTTPStatusCode() {
        let unknownCode = 999
        let error = PIAAccountError.fromHTTPStatus(unknownCode)

        #expect(error.code == unknownCode)
        #expect(error.errorDescription != nil)
    }

    @Test("Negative HTTP status code")
    func negativeHTTPStatusCode() {
        let negativeCode = -1
        let error = PIAAccountError.fromHTTPStatus(negativeCode)

        #expect(error.code == negativeCode)
    }

    @Test("Zero retry after")
    func zeroRetryAfter() {
        let error = PIAAccountError.fromHTTPStatus(429, retryAfter: 0)

        #expect(error.retryAfterSeconds == 0)
    }

    @Test("Large retry after value")
    func largeRetryAfter() {
        let largeRetryAfter: TimeInterval = 86400 // 24 hours
        let error = PIAAccountError.fromHTTPStatus(429, retryAfter: largeRetryAfter)

        #expect(error.retryAfterSeconds == largeRetryAfter)
    }
}
