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

    func test_targetServer_reResolvesLastConnectedRegion_afterReload() throws {
        guard let serverProvider = Client.providers.serverProvider as? DefaultServerProvider else {
            return XCTFail("Expected the real DefaultServerProvider")
        }

        // GIVEN a bundle with more than one server, and a persisted "last connected" region
        // that isn't the first server in the bundle
        let serversJSON = bundledServersJSON()
        Client.configuration.bundledServersJSON = serversJSON
        serverProvider.loadLocalJSON(fromJSON: serversJSON)
        let allServers = serverProvider.currentServers
        let lastConnected = try XCTUnwrap(allServers.dropFirst().first, "fixture needs at least 2 servers")
        XCTAssertNotEqual(lastConnected.identifier, allServers.first?.identifier)
        Client.database.plain.lastConnectedRegion = lastConnected

        // AND the cache is empty again (e.g. right after logout, before the daemon re-downloads)
        serverProvider.currentServers = []
        XCTAssertTrue(serverProvider.currentServers.isEmpty)

        // WHEN resolving targetServer, which reloads the bundle
        let resolved = try serverProvider.targetServer

        // THEN it re-resolves the persisted last-connected region instead of returning an
        // arbitrary server from the freshly-reloaded cache
        XCTAssertEqual(resolved.identifier, lastConnected.identifier)
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
