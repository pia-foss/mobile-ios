import Testing
import Foundation
@testable import PIAAccount

@Suite struct KeychainStorageTests {
    var storage: KeychainStorage
    var testService: String

    init() {
        // Use unique service identifier for each test to avoid conflicts
        testService = "com.pia.test.\(UUID().uuidString)"
        storage = KeychainStorage(service: testService)
    }

    // MARK: - Basic CRUD Tests

    @Test("Set and get data from keychain")
    func setAndGet() throws {
        let testKey = "testKey"
        let testData = "Hello, Keychain!".data(using: .utf8)!

        // Set data
        try storage.set(testData, forKey: testKey)

        // Get data back
        let retrievedData = try storage.get(forKey: testKey)

        #expect(retrievedData == testData)
    }

    @Test("Get non-existent key returns nil")
    func getNonExistentKey() throws {
        let nonExistentKey = "nonExistent"

        let retrievedData = try storage.get(forKey: nonExistentKey)

        #expect(retrievedData == nil)
    }

    @Test("Update existing key with new data")
    func updateExistingKey() throws {
        let testKey = "updateKey"
        let initialData = "Initial".data(using: .utf8)!
        let updatedData = "Updated".data(using: .utf8)!

        // Set initial data
        try storage.set(initialData, forKey: testKey)

        // Update with new data
        try storage.set(updatedData, forKey: testKey)

        // Verify updated data
        let retrievedData = try storage.get(forKey: testKey)
        #expect(retrievedData == updatedData)
    }

    @Test("Check if key exists")
    func exists() throws {
        let testKey = "existsKey"
        let testData = "Test".data(using: .utf8)!

        // Initially should not exist
        #expect(!(try storage.exists(forKey: testKey)))

        // Set data
        try storage.set(testData, forKey: testKey)

        // Now should exist
        #expect(try storage.exists(forKey: testKey))
    }

    @Test("Delete key removes data")
    func delete() throws {
        let testKey = "deleteKey"
        let testData = "Delete me".data(using: .utf8)!

        // Set data
        try storage.set(testData, forKey: testKey)
        #expect(try storage.exists(forKey: testKey))

        // Delete data
        try storage.delete(forKey: testKey)

        // Verify deleted
        #expect(!(try storage.exists(forKey: testKey)))
        #expect(try storage.get(forKey: testKey) == nil)
    }

    @Test("Delete non-existent key does not throw")
    func deleteNonExistentKey() throws {
        let nonExistentKey = "nonExistent"

        // Deleting non-existent key should not throw
        try storage.delete(forKey: nonExistentKey)
    }

    @Test("Clear all removes all keys")
    func clearAll() throws {
        let key1 = "key1"
        let key2 = "key2"
        let key3 = "key3"
        let testData = "Data".data(using: .utf8)!

        // Set multiple items
        try storage.set(testData, forKey: key1)
        try storage.set(testData, forKey: key2)
        try storage.set(testData, forKey: key3)

        // Verify all exist
        #expect(try storage.exists(forKey: key1))
        #expect(try storage.exists(forKey: key2))
        #expect(try storage.exists(forKey: key3))

        // Clear all
        try storage.clearAll()

        // Verify all deleted
        let exists1 = try storage.exists(forKey: key1)
        let exists2 = try storage.exists(forKey: key2)
        let exists3 = try storage.exists(forKey: key3)

        #expect(!exists1)
        #expect(!exists2)
        #expect(!exists3)
    }

    // MARK: - Codable Tests

    @Test("Set and get Codable object")
    func setAndGetCodable() throws {
        struct TestModel: Codable, Equatable {
            let id: Int
            let name: String
            let active: Bool
        }

        let testKey = "codableKey"
        let testModel = TestModel(id: 123, name: "Test", active: true)

        // Set Codable object
        try storage.set(testModel, forKey: testKey)

        // Get Codable object back
        let retrievedModel = try storage.get(TestModel.self, forKey: testKey)

        #expect(retrievedModel == testModel)
    }

    @Test("Get non-existent Codable returns nil")
    func getCodableNonExistent() throws {
        struct TestModel: Codable {
            let value: String
        }

        let nonExistentKey = "nonExistent"

        let retrievedModel = try storage.get(TestModel.self, forKey: nonExistentKey)

        #expect(retrievedModel == nil)
    }

    @Test("Codable with complex nested types")
    func codableWithComplexTypes() throws {
        struct NestedModel: Codable, Equatable {
            let value: String
        }

        struct ComplexModel: Codable, Equatable {
            let stringValue: String
            let intValue: Int
            let doubleValue: Double
            let arrayValue: [String]
            let nested: NestedModel
        }

        let testKey = "complexKey"
        let testModel = ComplexModel(
            stringValue: "test",
            intValue: 42,
            doubleValue: 3.14,
            arrayValue: ["a", "b", "c"],
            nested: NestedModel(value: "nested")
        )

        try storage.set(testModel, forKey: testKey)
        let retrieved = try storage.get(ComplexModel.self, forKey: testKey)

        #expect(retrieved == testModel)
    }

    // MARK: - Isolation Tests

    @Test("Service isolation keeps data separate")
    func serviceIsolation() throws {
        let testKey = "sharedKey"
        let data1 = "Service 1".data(using: .utf8)!
        let data2 = "Service 2".data(using: .utf8)!

        // Create two storages with different services
        let storage1 = KeychainStorage(service: "com.pia.test.service1")
        let storage2 = KeychainStorage(service: "com.pia.test.service2")

        // Set data in both with same key
        try storage1.set(data1, forKey: testKey)
        try storage2.set(data2, forKey: testKey)

        // Verify data is isolated
        let retrieved1 = try storage1.get(forKey: testKey)
        let retrieved2 = try storage2.get(forKey: testKey)

        #expect(retrieved1 == data1)
        #expect(retrieved2 == data2)
        #expect(retrieved1 != retrieved2)

        // Clean up
        try storage1.clearAll()
        try storage2.clearAll()
    }

    // MARK: - Edge Cases

    @Test("Store and retrieve empty data")
    func emptyData() throws {
        let testKey = "emptyKey"
        let emptyData = Data()

        try storage.set(emptyData, forKey: testKey)
        let retrieved = try storage.get(forKey: testKey)

        #expect(retrieved == emptyData)
    }

    @Test("Store and retrieve large data (1MB)")
    func largeData() throws {
        let testKey = "largeKey"
        // Create 1MB of data
        let largeData = Data(repeating: 0x42, count: 1_024 * 1_024)

        try storage.set(largeData, forKey: testKey)
        let retrieved = try storage.get(forKey: testKey)

        #expect(retrieved == largeData)
    }

    @Test("Keys with special characters")
    func specialCharactersInKey() throws {
        let specialKeys = [
            "key.with.dots",
            "key-with-dashes",
            "key_with_underscores",
            "key with spaces",
            "key/with/slashes"
        ]
        let testData = "Test".data(using: .utf8)!

        for key in specialKeys {
            try storage.set(testData, forKey: key)
            let retrieved = try storage.get(forKey: key)
            #expect(retrieved == testData)
            try storage.delete(forKey: key)
        }
    }
}
