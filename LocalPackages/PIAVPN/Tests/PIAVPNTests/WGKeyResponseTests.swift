import Foundation
import KapeVPN_PacketTunnel
import Testing

@testable import PIAVPN

@Suite("WireGuard key-exchange response decoding")
struct WGKeyResponseTests {

    // As captured from /add-awg-key on 173.239.198.22:1338.
    private static let amneziaResponse = """
        {
          "status": "OK",
          "server_key": "oXPMKaVt7GxdAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
          "server_port": 1338,
          "server_ip": "173.239.198.22",
          "server_vip": "10.176.0.1",
          "peer_ip": "10.176.0.2",
          "peer_pubkey": "pMsTjVyuhKcVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
          "dns_servers": ["10.0.0.243", "10.0.0.242"],
          "obfuscation": {
            "s1": 5, "s2": 3, "jc": 5, "jmin": 25, "jmax": 100,
            "h1": 1234567891, "h2": 1234567892, "h3": 1234567893, "h4": 1234567894
          }
        }
        """

    private static let plainResponse = """
        {
          "status": "OK",
          "server_key": "oXPMKaVt7GxdAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
          "peer_ip": "10.176.0.2",
          "dns_servers": ["10.0.0.243"]
        }
        """

    private static func decode(_ json: String) throws -> WGKeyResponse {
        try JSONDecoder().decode(WGKeyResponse.self, from: Data(json.utf8))
    }

    @Test("the awg response decodes its obfuscation parameters")
    func decodesObfuscation() throws {
        let response = try Self.decode(Self.amneziaResponse)
        let obfuscation = try #require(response.obfuscation)

        #expect(obfuscation.s1 == 5)
        #expect(obfuscation.s2 == 3)
        #expect(obfuscation.jc == 5)
        #expect(obfuscation.jmin == 25)
        #expect(obfuscation.jmax == 100)
        #expect(obfuscation.h1 == 1_234_567_891)
        #expect(obfuscation.h2 == 1_234_567_892)
        #expect(obfuscation.h3 == 1_234_567_893)
        #expect(obfuscation.h4 == 1_234_567_894)
    }

    @Test("obfuscation maps onto WireguardObfuscation.amnezia in the right order")
    func mapsToWireguardObfuscation() throws {
        let response = try Self.decode(Self.amneziaResponse)
        let mapped = try #require(response.obfuscation).asWireguardObfuscation

        if case .amnezia(let s1, let s2, let jc, let jmin, let jmax, let h1, let h2, let h3, let h4) = mapped {
            #expect([s1, s2, jc, jmin, jmax] == [5, 3, 5, 25, 100])
            #expect([h1, h2, h3, h4] == [1_234_567_891, 1_234_567_892, 1_234_567_893, 1_234_567_894])
        } else {
            Issue.record("expected .amnezia, got \(mapped)")
        }
    }

    @Test("fields with no consumer do not break the decode")
    func toleratesUnusedFields() throws {
        let response = try Self.decode(Self.amneziaResponse)

        #expect(response.status == "OK")
        #expect(response.peer_ip == "10.176.0.2")
        #expect(response.dns_servers == ["10.0.0.243", "10.0.0.242"])
        #expect(response.peer_pubkey?.isEmpty == false)
    }

    @Test("a plain addKey response still decodes, with no obfuscation")
    func plainResponseHasNoObfuscation() throws {
        let response = try Self.decode(Self.plainResponse)

        #expect(response.obfuscation == nil)
        #expect(response.peer_pubkey == nil)
        #expect(response.status == "OK")
    }
}
