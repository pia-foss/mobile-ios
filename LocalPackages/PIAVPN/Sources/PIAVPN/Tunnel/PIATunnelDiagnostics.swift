import Foundation
import KapeVPN_PacketTunnel
import NWHttpConnection
import Network

/// Formatting helpers for tunnel logs. Never feed secrets in without `redact`.
enum PIATunnelDiagnostics {

    static func describe(_ error: Error) -> String {
        switch error {
        case let error as PacketTunnelError:
            return describe(error)
        case let error as NWHttpConnectionError:
            return describe(error)
        case let error as NWError:
            return describe(error)
        case is NWHttpConnectionResponseError:
            return "no response (connection closed or timed out)"
        case is CancellationError:
            return "cancelled"
        case let error as URLError:
            return describe(error as NSError)
        default:
            if type(of: error) is NSError.Type {
                return describe(error as NSError)
            }
            return "\(type(of: error)).\(error)"
        }
    }

    /// Coarse failure category, so a report can be scanned for timeouts vs auth vs everything else.
    static func failureReason(for error: Error) -> String {
        switch error {
        case is CancellationError:
            return "cancelled"
        case let error as PacketTunnelError:
            switch error {
            case .connectionTimeout: return "timeout"
            case .authenticationFailed(let underlying): return underlying.map { failureReason(for: $0) } ?? "authentication"
            case .connectFailed(let underlying): return underlying.map { failureReason(for: $0) } ?? "connect"
            case .setupFailed: return "setup"
            default: return "\(error)"
            }
        case is NWHttpConnectionError, is NWHttpConnectionResponseError:
            return "key exchange"
        default:
            // `KapeWireGuardTunnelError` is internal to the SDK.
            let text = "\(error)"
            if text.contains("firstHandshakeFailed") { return "handshake timeout" }
            if text.contains("dnsResolutionFailure") { return "dns" }
            return "other"
        }
    }

    static func redact(_ text: String, secrets: [String]) -> String {
        secrets
            .filter { !$0.isEmpty }
            .flatMap { [$0, $0.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)].compactMap { $0 } }
            .reduce(text) { $0.replacingOccurrences(of: $1, with: "<redacted>") }
    }

    /// A JSON object body as sorted `key=value` pairs.
    static func payload(_ data: Data, redacting secrets: [String]) -> String {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "\(data.count) byte(s), body is not a JSON object"
        }

        let text =
            object
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\(String(describing: $0.value))" }
            .joined(separator: ", ")
        return redact(text, secrets: secrets)
    }

    static func elapsedMs(since start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }

    private static func describe(_ error: PacketTunnelError) -> String {
        switch error {
        case .authenticationFailed(let underlying):
            return "authenticationFailed(\(underlying.map { describe($0) } ?? "no underlying error"))"
        case .connectFailed(let underlying):
            return "connectFailed(\(underlying.map { describe($0) } ?? "no underlying error"))"
        default:
            return "\(error)"
        }
    }

    private static func describe(_ error: NWHttpConnectionError) -> String {
        switch error {
        case .badURL:
            // The URL carries the token.
            return "badURL"
        case .connection(let error):
            return "connection(\(describe(error)))"
        case .wait(let error):
            return "wait(\(describe(error)))"
        case .send(let error):
            return "send(\(describe(error)))"
        case .receive(let error):
            return "receive(\(error.map { describe($0) } ?? "no error"))"
        case .negativeTimeout, .timeoutOutOfBounds:
            return "\(error)"
        case .unknown(let error):
            return "unknown(\(describe(error)))"
        }
    }

    private static func describe(_ error: NWError) -> String {
        switch error {
        case .posix(let code):
            return "posix \(code.rawValue) \(String(cString: strerror(code.rawValue)))"
        case .dns(let code):
            return "dns \(code)"
        case .tls(let status):
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "unknown"
            return "tls \(status) \(message)"
        default:
            return "\(error)"
        }
    }

    private static func describe(_ error: NSError) -> String {
        var text = "\(error.domain) \(error.code): \(error.localizedDescription)"
        if let underlying = error.userInfo[NSUnderlyingErrorKey] as? Error {
            text += " ← \(describe(underlying))"
        }
        return text
    }
}
