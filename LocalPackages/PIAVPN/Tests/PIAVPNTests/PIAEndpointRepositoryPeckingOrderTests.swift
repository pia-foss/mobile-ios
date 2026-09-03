import Foundation
import KapeVPN_PacketTunnel
import PIALibrary
import Testing

@testable import PIAVPN

@Suite("Pecking order selection by country")
struct PIAEndpointRepositoryPeckingOrderTests {

    private static func state(countryCode: String?) -> PIATunnelSharedState.State {
        var state = PIATunnelSharedState.read()
        state.geoCountryCode = countryCode
        return state
    }

    private static func isCensorshipOrder(_ order: [PIAEndpointRepository.PeckingStep]) -> Bool {
        guard case .wireGuard(let amnezia) = order.first?.kind else { return false }
        return amnezia
    }

    @Test("censored countries get the censorship order", arguments: ["CN", "IR", "RU"])
    func censoredCountries(code: String) {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: code))
        #expect(Self.isCensorshipOrder(order))
    }

    @Test("the country code is matched case-insensitively", arguments: ["cn", "Ir", "rU"])
    func caseInsensitive(code: String) {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: code))
        #expect(Self.isCensorshipOrder(order))
    }

    @Test("uncensored countries keep the normal order", arguments: ["US", "DE", "BR", "GB"])
    func uncensoredCountries(code: String) {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: code))
        #expect(!Self.isCensorshipOrder(order))
    }

    @Test("an unresolved country keeps the normal order")
    func unknownCountry() {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: nil))
        #expect(!Self.isCensorshipOrder(order))
        #expect(order.count == PIAEndpointRepository.normalPeckingOrder.count)
    }

    @Test("the censorship order tries amnezia, then plain wireguard, then OpenVPN TCP before UDP")
    func censorshipOrderShape() {
        let order = PIAEndpointRepository.censorshipPeckingOrder
        let labels: [String] = order.map { step in
            switch step.kind {
            case .wireGuard(let amnezia): return amnezia ? "awg" : "wg"
            case .openVPN(let transport): return "ovpn-\(transport.rawValue)"
            }
        }
        #expect(labels == ["awg", "wg", "ovpn-tcp", "ovpn-udp"])
    }

    @Test("the normal order never contains an amnezia step")
    func normalOrderShape() {
        let hasAmnezia = PIAEndpointRepository.normalPeckingOrder.contains { step in
            if case .wireGuard(let amnezia) = step.kind { return amnezia }
            return false
        }
        #expect(!hasAmnezia)
    }
}
