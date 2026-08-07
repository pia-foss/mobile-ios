import CFNetwork
import Foundation
import NetworkExtension

/// What the device's VPN is doing, and whether PIA owns it.
///
/// Neither half can be answered alone. NetworkExtension only ever exposes the configurations this
/// app created, so it identifies our tunnel — and its transitions — but is blind to a VPN installed
/// by another app. The tunnel interfaces see every VPN on the device but carry no ownership
/// information, since PIA's own tunnel appears among them identically. Reading both and checking
/// ours first is what separates "PIA" from "somebody else".
struct VPNConnectionState: Equatable {
    static let unknown = VPNConnectionState(profileState: .unavailable, isTunnelActive: false)

    let profileState: VPNProfileState
    let isTunnelActive: Bool

    static func current() async -> VPNConnectionState {
        VPNConnectionState(
            profileState: await PIAProfiles.currentState(),
            isTunnelActive: TunnelInterfaces.areActive
        )
    }

    /// Device-level, so a tunnel owned by another app still reads as connected.
    var status: String {
        switch profileState {
        case .connected, .connecting, .reasserting, .disconnecting:
            profileState.displayName
        case .disconnected, .unavailable:
            isTunnelActive ? VPNProfileState.connected.displayName : VPNProfileState.disconnected.displayName
        }
    }

    /// "Not PIA" means a tunnel is carrying traffic that isn't ours; which app owns it is not
    /// knowable, since an app can only see the VPN configurations it created.
    var connectedVia: String {
        if profileState.isCarryingTraffic {
            return "PIA"
        }
        return isTunnelActive ? "Not PIA" : "---"
    }
}

/// State of the VPN profiles installed by *this* app.
enum VPNProfileState: Equatable {
    case connected
    case connecting
    case reasserting
    case disconnecting
    case disconnected
    /// No profile of ours is installed, or its configuration could not be loaded.
    case unavailable

    var displayName: String {
        switch self {
        case .connected: "connected"
        case .connecting: "connecting"
        case .reasserting: "reasserting"
        case .disconnecting: "disconnecting"
        case .disconnected: "disconnected"
        case .unavailable: "unavailable"
        }
    }

    /// Whether a tunnel of ours is carrying traffic. `reasserting` counts: the tunnel is up and
    /// re-establishing after a network change, not gone.
    var isCarryingTraffic: Bool {
        self == .connected || self == .reasserting
    }
}

// MARK: - Sources

/// Reads PIA's own profiles first-hand, so the menu reports what the system believes rather than
/// what the library's daemon last recorded.
private enum PIAProfiles {

    static func currentState() async -> VPNProfileState {
        var states: [VPNProfileState] = []

        // Covers the OpenVPN and WireGuard Network Extensions.
        if let managers = try? await NETunnelProviderManager.loadAllFromPreferences() {
            states.append(contentsOf: managers.map { state(of: $0.connection.status) })
        }

        // Covers IKEv2, which uses the personal VPN configuration instead of a tunnel provider.
        let personalVPN = NEVPNManager.shared()
        if (try? await personalVPN.loadFromPreferences()) != nil {
            states.append(state(of: personalVPN.connection.status))
        }

        // Several profiles can be installed at once, so the liveliest one describes the device.
        return states.max { priority(of: $0) < priority(of: $1) } ?? .unavailable
    }

    private static func state(of status: NEVPNStatus) -> VPNProfileState {
        switch status {
        case .connected: .connected
        case .connecting: .connecting
        case .reasserting: .reasserting
        case .disconnecting: .disconnecting
        case .disconnected: .disconnected
        case .invalid: .unavailable
        @unknown default: .unavailable
        }
    }

    private static func priority(of state: VPNProfileState) -> Int {
        switch state {
        case .connected: 5
        case .reasserting: 4
        case .connecting: 3
        case .disconnecting: 2
        case .disconnected: 1
        case .unavailable: 0
        }
    }
}

/// Detects a tunnel from the network interfaces, which is the only way to see a VPN installed by
/// another app. `NWPath`'s `.other` interface type was tried first and proved unreliable.
private enum TunnelInterfaces {

    // `utun` is deliberately absent from the interface scan: iOS keeps unnumbered `utun` devices up
    // for Handoff, AirPlay and Personal Hotspot, so their mere existence proves nothing. Inside
    // `__SCOPED__` they are meaningful, because that dictionary only lists interfaces that
    // currently carry network configuration — which a tunnel does only while established.
    private static let scopedPrefixes = ["tap", "tun", "ppp", "ipsec", "utun"]
    private static let interfacePrefixes = ["tap", "tun", "ppp", "ipsec"]

    static var areActive: Bool {
        hasScopedTunnel || hasRunningTunnel
    }

    private static var hasScopedTunnel: Bool {
        guard
            let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
            let scoped = settings["__SCOPED__"] as? [String: Any]
        else {
            return false
        }

        return scoped.keys.contains { name in
            scopedPrefixes.contains { name.hasPrefix($0) }
        }
    }

    // Catches the protocols some clients bring up without registering scoped proxy settings.
    private static var hasRunningTunnel: Bool {
        var addresses: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addresses) == 0, let first = addresses else {
            return false
        }
        defer { freeifaddrs(addresses) }

        return sequence(first: first, next: { $0.pointee.ifa_next })
            .contains { interface in
                let flags = Int32(interface.pointee.ifa_flags)
                guard flags & IFF_UP == IFF_UP, flags & IFF_RUNNING == IFF_RUNNING else {
                    return false
                }

                let name = String(cString: interface.pointee.ifa_name)
                return interfacePrefixes.contains { name.hasPrefix($0) }
            }
    }
}
