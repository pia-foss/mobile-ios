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

    @Test("censored countries get the censorship order", arguments: ["CN", "IR", "RU", "DE"])
    func censoredCountries(code: String) {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: code))
        #expect(Self.isCensorshipOrder(order))
    }

    @Test("the country code is matched case-insensitively", arguments: ["cn", "Ir", "rU"])
    func caseInsensitive(code: String) {
        let order = PIAEndpointRepository().peckingOrder(for: Self.state(countryCode: code))
        #expect(Self.isCensorshipOrder(order))
    }

    @Test("uncensored countries keep the normal order", arguments: ["US", "BR", "GB"])
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

    private static func labels(_ order: [PIAEndpointRepository.PeckingStep]) -> [String] {
        order.map { step in
            switch step.kind {
            case .wireGuard(let amnezia): return amnezia ? "awg" : "wg"
            case .openVPN(let transport): return "ovpn-\(transport.rawValue)"
            }
        }
    }

    @Test("the censorship order tries amnezia, then OpenVPN TCP, then plain wireguard before UDP")
    func censorshipOrderShape() {
        let order = PIAEndpointRepository.censorshipPeckingOrder
        #expect(Self.labels(order) == ["awg", "ovpn-tcp", "wg", "ovpn-udp"])
    }

    @Test("the normal order falls back to amnezia last")
    func normalOrderShape() {
        let order = PIAEndpointRepository.normalPeckingOrder
        #expect(Self.labels(order) == ["wg", "ovpn-udp", "ovpn-tcp", "awg"])
    }

    @Test("amnezia steps use the amnezia port")
    func amneziaStepsUseAmneziaPort() {
        let orders = [
            PIAEndpointRepository.normalPeckingOrder, PIAEndpointRepository.censorshipPeckingOrder
        ]
        for step in orders.flatMap({ $0 }) {
            guard case .wireGuard(true) = step.kind else { continue }
            #expect(step.port == PIAEndpointRepository.amneziaPort)
        }
    }
}
