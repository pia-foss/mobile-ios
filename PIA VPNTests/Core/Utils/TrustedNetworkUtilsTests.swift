import PIALibrary
import Testing

@testable import PIA_VPN

extension ClientPreferencesTests {

    @Suite(.serialized)
    struct TrustedNetworkUtilsTests {

        @Test func unknownSSIDOnWiFiFollowsSecureWiFiRule() {
            applyRules(protectedWiFi: .alwaysDisconnect, cellular: .alwaysConnect)
            defer { resetRules() }

            #expect(TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: true, hasCellular: true))
        }

        @Test func unknownSSIDOnWiFiIgnoresCellularRule() {
            applyRules(protectedWiFi: .alwaysConnect, cellular: .alwaysDisconnect)
            defer { resetRules() }

            #expect(!TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: true, hasCellular: true))
        }

        @Test func offWiFiFollowsCellularRule() {
            applyRules(protectedWiFi: .alwaysConnect, cellular: .alwaysDisconnect)
            defer { resetRules() }

            #expect(TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: false, hasCellular: true))
        }

        @Test func offWiFiWithoutCellularIsNeverTrusted() {
            applyRules(protectedWiFi: .alwaysDisconnect, cellular: .alwaysDisconnect)
            defer { resetRules() }

            #expect(!TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: false, hasCellular: false))
            #expect(TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: true, hasCellular: false))
        }

        @Test func knownSSIDFollowsItsOwnRule() {
            applyRules(protectedWiFi: .alwaysConnect, cellular: .alwaysConnect, ssidRules: ["Home": .alwaysDisconnect])
            defer { resetRules() }

            #expect(TrustedNetworkUtils.isTrustedNetwork(ssid: "Home", isOnWiFi: true, hasCellular: true))
            #expect(!TrustedNetworkUtils.isTrustedNetwork(ssid: "Office", isOnWiFi: true, hasCellular: true))
        }

        @Test func disabledAutomationIsNeverTrusted() {
            applyRules(protectedWiFi: .alwaysDisconnect, cellular: .alwaysDisconnect, enabled: false)
            defer { resetRules() }

            #expect(!TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: true, hasCellular: true))
            #expect(!TrustedNetworkUtils.isTrustedNetwork(ssid: nil, isOnWiFi: false, hasCellular: true))
        }

        private func applyRules(
            protectedWiFi: NMTRules,
            cellular: NMTRules,
            ssidRules: [String: NMTRules] = [:],
            enabled: Bool = true
        ) {
            let preferences = Client.preferences.editable()
            preferences.nmtRulesEnabled = enabled
            preferences.nmtGenericRules = [
                NMTType.protectedWiFi.rawValue: protectedWiFi.rawValue,
                NMTType.openWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
                NMTType.cellular.rawValue: cellular.rawValue
            ]
            preferences.nmtTrustedNetworkRules = ssidRules.mapValues(\.rawValue)
            preferences.commit()
        }

        private func resetRules() {
            let preferences = Client.preferences.editable()
            preferences.reset()
            preferences.commit()
        }
    }
}
