import Testing
import Foundation
@testable import PIAAccount

@Suite struct RequestBuilderTests {
    let testURL = URL(string: "https://example.com/api/test")!

    // MARK: - HTTP Method Tests

    @Test("Build GET request")
    func buildHTTPMethodGET() {
        let request = RequestBuilder.build(url: testURL, method: .get)

        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
    }

    @Test("Build POST request")
    func buildHTTPMethodPOST() {
        let body = RequestBuilder.BodyType.formEncoded(["key": "value"])
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: body)

        #expect(request.httpMethod == "POST")
        #expect(request.httpBody != nil)
    }

    @Test("Build DELETE request")
    func buildHTTPMethodDELETE() {
        let request = RequestBuilder.build(url: testURL, method: .delete)

        #expect(request.httpMethod == "DELETE")
    }

    // MARK: - Form-Encoded Body Tests

    @Test("Form-encoded body with single parameter")
    func buildFormEncodedBodySingleParam() {
        let formParams = ["username": "testuser"]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams))

        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")

        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            #expect(bodyString == "username=testuser")
        } else {
            Issue.record("Failed to decode form body")
        }
    }

    @Test("Form-encoded body with multiple parameters")
    func buildFormEncodedBodyMultipleParams() {
        let formParams = [
            "username": "testuser",
            "password": "testpass",
            "email": "test@example.com"
        ]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams))

        guard let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) else {
            Issue.record("Failed to decode form body")
            return
        }

        // Parse the form data (order may vary)
        let components = bodyString.split(separator: "&")
        #expect(components.count == 3)

        // Verify all parameters are present
        #expect(bodyString.contains("username=testuser"))
        #expect(bodyString.contains("password=testpass"))
        #expect(bodyString.contains("email=test%40example.com")) // @ should be percent-encoded
    }

    @Test("Form-encoded body with special characters")
    func buildFormEncodedBodySpecialCharacters() {
        let formParams = [
            "text": "hello world",
            "special": "!@#$%^&*()",
            "unicode": "こんにちは"
        ]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams))

        guard let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) else {
            Issue.record("Failed to decode form body")
            return
        }

        // Space should be percent-encoded as %20
        #expect(bodyString.contains("hello%20world"))

        // Special characters should be percent-encoded
        #expect(bodyString.contains("special="))

        // Unicode should be percent-encoded
        #expect(bodyString.contains("unicode="))
    }

    @Test("Form-encoded body with empty value")
    func buildFormEncodedBodyEmptyValue() {
        let formParams = ["key": ""]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams))

        guard let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) else {
            Issue.record("Failed to decode form body")
            return
        }

        #expect(bodyString == "key=")
    }

    @Test("Form-encoded body with empty dictionary")
    func buildFormEncodedBodyEmptyDict() {
        let formParams: [String: String] = [:]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams))

        guard let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) else {
            Issue.record("Failed to decode form body")
            return
        }

        #expect(bodyString.isEmpty)
    }

    // MARK: - JSON Body Tests

    @Test("Build request with JSON body")
    func buildJSONBody() throws {
        struct TestData: Codable {
            let key: String
            let number: Int
        }
        let testData = TestData(key: "value", number: 42)
        let jsonData = try JSONEncoder().encode(testData)
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .json(jsonData))

        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.httpBody == jsonData)
    }

    @Test("JSON body with empty data")
    func buildJSONBodyEmptyData() {
        let emptyData = Data()
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .json(emptyData))

        #expect(request.httpBody == emptyData)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("JSON body with complex structure")
    func buildJSONBodyComplexStructure() throws {
        struct TestModel: Codable {
            let string: String
            let number: Int
            let array: [String]
            let nested: NestedModel

            struct NestedModel: Codable {
                let value: String
            }
        }

        let model = TestModel(
            string: "test",
            number: 123,
            array: ["a", "b", "c"],
            nested: TestModel.NestedModel(value: "nested")
        )

        let jsonData = try JSONEncoder().encode(model)
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .json(jsonData))

        #expect(request.httpBody == jsonData)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    // MARK: - Header Tests

    @Test("Build request with custom headers")
    func buildCustomHeaders() {
        let headers = [
            "Authorization": "Bearer test-token",
            "X-Custom-Header": "custom-value"
        ]
        let request = RequestBuilder.build(url: testURL, method: .get, headers: headers)

        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(request.value(forHTTPHeaderField: "X-Custom-Header") == "custom-value")
    }

    @Test("Headers with body type")
    func buildHeadersWithBody() {
        let headers = ["Authorization": "Bearer token"]
        let formParams = ["key": "value"]
        let request = RequestBuilder.build(url: testURL, method: .post, bodyType: .formEncoded(formParams), headers: headers)

        // Custom headers should be present
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")

        // Content-Type should be set by body type
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
    }

    @Test("Empty headers")
    func buildEmptyHeaders() {
        let request = RequestBuilder.build(url: testURL, method: .get, headers: [:])

        // Should have no custom headers (only defaults if any)
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(request.value(forHTTPHeaderField: "X-Custom") == nil)
    }

    // MARK: - URL Tests

    @Test("URL with query parameters")
    func buildURLWithQueryParameters() {
        let urlWithQuery = URL(string: "https://example.com/api/test?param1=value1&param2=value2")!
        let request = RequestBuilder.build(url: urlWithQuery, method: .get)

        #expect(request.url?.absoluteString == urlWithQuery.absoluteString)
        #expect(request.url?.query == "param1=value1&param2=value2")
    }

    @Test("URL with fragment")
    func buildURLWithFragment() {
        let urlWithFragment = URL(string: "https://example.com/api/test#fragment")!
        let request = RequestBuilder.build(url: urlWithFragment, method: .get)

        #expect(request.url?.absoluteString == urlWithFragment.absoluteString)
    }

    // MARK: - No Body Tests

    @Test("GET request with no body type")
    func buildNoBodyTypeGET() {
        let request = RequestBuilder.build(url: testURL, method: .get)

        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    @Test("DELETE request with no body type")
    func buildNoBodyTypeDELETE() {
        let request = RequestBuilder.build(url: testURL, method: .delete)

        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    }

    // MARK: - Complete Request Tests

    @Test("Complete POST request with form-encoded body")
    func buildCompleteRequestPOSTFormEncoded() {
        let formParams = ["username": "user", "password": "pass"]
        let headers = ["Authorization": "Bearer token", "X-Api-Version": "1.0"]
        let request = RequestBuilder.build(
            url: testURL,
            method: .post,
            bodyType: .formEncoded(formParams),
            headers: headers
        )

        #expect(request.url == testURL)
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
        #expect(request.value(forHTTPHeaderField: "X-Api-Version") == "1.0")
    }

    @Test("Complete POST request with JSON body")
    func buildCompleteRequestPOSTJSON() throws {
        let jsonData = try JSONEncoder().encode(["key": "value"])
        let headers = ["Authorization": "Bearer token"]
        let request = RequestBuilder.build(
            url: testURL,
            method: .post,
            bodyType: .json(jsonData),
            headers: headers
        )

        #expect(request.url == testURL)
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody == jsonData)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }

    @Test("Complete GET request with headers")
    func buildCompleteRequestGETWithHeaders() {
        let headers = ["Authorization": "Bearer token"]
        let request = RequestBuilder.build(
            url: testURL,
            method: .get,
            headers: headers
        )

        #expect(request.url == testURL)
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
    }

    // MARK: - URL Encoded Helper Tests

    @Test("URL encoded data with simple string")
    func urlEncodedDataSimpleString() {
        let params = ["key": "value"]
        let data = params.urlEncodedData()

        #expect(data != nil)
        if let string = String(data: data!, encoding: .utf8) {
            #expect(string == "key=value")
        }
    }

    @Test("URL encoded data with special characters")
    func urlEncodedDataSpecialCharactersEncoding() {
        let testCases = [
            ("space", "hello world", "hello%20world"),
            ("at", "test@example.com", "test%40example.com"),
            ("plus", "1+1=2", "1%2B1%3D2"),
            ("ampersand", "a&b", "a%26b"),
            ("equals", "x=y", "x%3Dy")
        ]

        for (name, input, expectedEncoded) in testCases {
            let params = ["key": input]
            guard let data = params.urlEncodedData(),
                  let encoded = String(data: data, encoding: .utf8) else {
                Issue.record("Failed to encode \(name)")
                continue
            }

            #expect(encoded.contains(expectedEncoded))
        }
    }

    @Test("URL encoded data is order independent")
    func urlEncodedDataOrderIndependent() {
        let params1 = ["a": "1", "b": "2", "c": "3"]
        let params2 = ["c": "3", "a": "1", "b": "2"]

        let data1 = params1.urlEncodedData()
        let data2 = params2.urlEncodedData()

        // Both should be valid encodings (order may differ but content is same)
        #expect(data1 != nil)
        #expect(data2 != nil)

        if let string1 = String(data: data1!, encoding: .utf8),
           let string2 = String(data: data2!, encoding: .utf8) {
            // Both strings should contain all parameters
            for param in ["a=1", "b=2", "c=3"] {
                #expect(string1.contains(param))
                #expect(string2.contains(param))
            }
        }
    }
}
