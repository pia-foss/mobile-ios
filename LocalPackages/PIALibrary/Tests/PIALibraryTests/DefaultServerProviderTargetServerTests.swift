import XCTest

@testable import PIALibrary

class DefaultServerProviderTargetServerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Client.database = Client.Database(group: "group.com.privateinternetaccess").truncate()
    }

    override func tearDown() {
        Client.configuration.bundledServersJSON = nil
        super.tearDown()
    }

    func test_targetServer_reloadsBundledServers_whenCacheIsEmpty() throws {
        // GIVEN an empty cache (no preferred/best/last-connected server either) and a
        // bundled servers JSON available
        Client.configuration.bundledServersJSON = bundledServersJSON()
        XCTAssertTrue(Client.providers.serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which would otherwise throw noServersAvailable
        let server = try Client.providers.serverProvider.targetServer

        // THEN it self-heals from the bundle instead of throwing
        XCTAssertNotNil(server)
        XCTAssertFalse(Client.providers.serverProvider.currentServers.isEmpty)
    }

    func test_targetServer_stillThrows_whenNoBundledServersJSONAvailable() {
        // GIVEN an empty cache and no bundled servers JSON configured
        Client.configuration.bundledServersJSON = nil
        XCTAssertTrue(Client.providers.serverProvider.currentServers.isEmpty)

        // WHEN/THEN resolving targetServer still throws noServersAvailable
        XCTAssertThrowsError(try Client.providers.serverProvider.targetServer) { error in
            XCTAssertEqual(error as? ClientError, ClientError.noServersAvailable)
        }
    }

    private func bundledServersJSON() -> Data {
        let testBundle = Bundle(for: DefaultServerProviderTargetServerTests.self)
        // The Xcode-native SPM integration nests package test resources inside a
        // "PIALibrary_PIALibraryTests.bundle" sub-bundle rather than the test bundle root.
        let candidateBundles = [
            testBundle,
            testBundle.url(forResource: "PIALibrary_PIALibraryTests", withExtension: "bundle")
                .flatMap(Bundle.init(url:))
        ].compactMap { $0 }
        guard let url = candidateBundles.compactMap({ $0.url(forResource: "server", withExtension: "json") }).first
        else {
            fatalError("Could not find bundled regions fixture")
        }
        return try! Data(contentsOf: url)
    }
}
