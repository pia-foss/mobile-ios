import Foundation

/// The device's egress IP as an unrelated third party sees it.
///
/// PIA's own `vpnIP` is whatever its connectivity checker reports after talking to PIA's endpoint,
/// so it describes what PIA believes. ipify knows nothing about PIA, which is the point: when the
/// two disagree, traffic is not leaving where the app thinks it is.
///
/// IPv4 only — `api.ipify.org` resolves to an A record, so this says nothing about an IPv6 leak.
/// Debug-menu only; the shipping connectivity path does not contact third parties.
enum IpifyAddress {
    private static let endpoint = URL(string: "https://api.ipify.org?format=json")!

    /// Matches the tunnel-log timeout: long enough for a slow tunnel, short enough that the row
    /// resolves while the menu is still open.
    private static let timeout: TimeInterval = 5

    private struct Response: Decodable {
        let ip: String
    }

    /// `nil` when the lookup fails — offline, blocked, or timed out.
    static func current() async -> String? {
        // Never served from cache: a cached answer would still show the pre-connect IP after the
        // tunnel came up, which is the exact discrepancy this row exists to catch.
        let request = URLRequest(
            url: endpoint,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeout
        )

        guard
            let (data, response) = try? await URLSession.shared.data(for: request),
            (response as? HTTPURLResponse)?.statusCode == 200,
            let decoded = try? JSONDecoder().decode(Response.self, from: data)
        else {
            return nil
        }

        return decoded.ip
    }
}
