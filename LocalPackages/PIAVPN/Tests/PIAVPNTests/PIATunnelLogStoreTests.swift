import Foundation
import Testing

@testable import PIAVPN

// EXPERIMENT: disabled to check whether this suite is what stalls PIAVPNTests on CI. Do not merge.
@Suite("Tunnel log persistence", .disabled("CI stall experiment"))
struct PIATunnelLogStoreTests {

    private static let marker = "new tunnel process; lines above are restored from the previous one"

    /// A fresh file URL in its own temporary directory, so tests need no App Group entitlement.
    private func makeFileURL() throws -> (URL, directory: URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PIATunnelLogStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return (directory.appendingPathComponent("last_tunnel.log"), directory)
    }

    private func persisted(at url: URL) -> String? {
        try? String(contentsOf: url, encoding: .utf8)
    }

    @Test("flush persists every appended line, in order")
    func flushPersists() throws {
        let (url, directory) = try makeFileURL()
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = PIATunnelLogStore(fileURL: url, flushDelay: .seconds(60))
        store.append("first")
        store.append("second")
        store.flush()

        #expect(persisted(at: url) == "first\nsecond")
    }

    @Test("appends are persisted without an explicit flush once the debounce elapses")
    func debouncedWrite() async throws {
        let (url, directory) = try makeFileURL()
        defer { try? FileManager.default.removeItem(at: directory) }

        let store = PIATunnelLogStore(fileURL: url, flushDelay: .milliseconds(10))
        store.append("only")

        for _ in 0..<200 where persisted(at: url) == nil {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(persisted(at: url) == "only")
    }

    @Test("a new store restores the persisted log and marks where it took over")
    func restoresPreviousProcess() throws {
        let (url, directory) = try makeFileURL()
        defer { try? FileManager.default.removeItem(at: directory) }

        let previous = PIATunnelLogStore(fileURL: url, flushDelay: .seconds(60))
        previous.append("failed handshake")
        previous.flush()

        let next = PIATunnelLogStore(fileURL: url, flushDelay: .seconds(60))
        next.append("connecting again")

        let lines = next.snapshot().components(separatedBy: "\n")
        #expect(lines.count == 3)
        #expect(lines.first == "failed handshake", "the earlier failure must survive the relaunch")
        #expect(lines[1].hasSuffix(Self.marker))
        #expect(lines.last == "connecting again")
    }

    @Test("restoring keeps only the newest lines that fit, marker included")
    func restoreIsBounded() throws {
        let (url, directory) = try makeFileURL()
        defer { try? FileManager.default.removeItem(at: directory) }
        try (1...10).map(String.init).joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)

        let store = PIATunnelLogStore(fileURL: url, maxEntries: 4, flushDelay: .seconds(60))

        let lines = store.snapshot().components(separatedBy: "\n")
        #expect(Array(lines.prefix(3)) == ["8", "9", "10"])
        #expect(lines.count == 4)
    }

    @Test("the buffer stays bounded as lines are appended")
    func appendIsBounded() throws {
        let store = PIATunnelLogStore(fileURL: nil, maxEntries: 3)
        for line in ["1", "2", "3", "4", "5"] {
            store.append(line)
        }

        #expect(store.snapshot() == "3\n4\n5")
    }

    @Test("without a file the store keeps working in memory")
    func inMemoryOnly() {
        let store = PIATunnelLogStore(fileURL: nil)
        store.append("line")
        store.flush()

        #expect(store.snapshot() == "line")
    }
}
