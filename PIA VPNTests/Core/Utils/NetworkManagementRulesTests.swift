import PIALibrary
import Testing

@testable import PIA_VPN

extension ClientPreferencesTests {
    @Suite(.serialized)
    struct NetworkManagementRulesTests {

        /// Restored after each test instead of resetting every preference, which would wipe what other
        /// tests rely on.
        private let originalGenericRules = Client.preferences.nmtGenericRules
        private let originalTrustedNetworkRules = Client.preferences.nmtTrustedNetworkRules
        private let originalAvailableNetworks = Client.preferences.availableNetworks

        @Test func rulesListGenericRulesInDisplayOrderThenNetworksByName() {
            applyRules(networkRules: ["Office": .alwaysConnect, "Cafe": .alwaysDisconnect])
            defer { resetRules() }

            #expect(
                NetworkManagementRules(isMacCatalyst: false).rules() == [
                    .init(type: .protectedWiFi, ssid: nil, rule: .alwaysConnect),
                    .init(type: .openWiFi, ssid: nil, rule: .alwaysDisconnect),
                    .init(type: .cellular, ssid: nil, rule: .retainState),
                    .init(type: .trustedNetwork, ssid: "Cafe", rule: .alwaysDisconnect),
                    .init(type: .trustedNetwork, ssid: "Office", rule: .alwaysConnect)
                ]
            )
        }

        @Test func macCatalystOnlyListsSecureWiFi() {
            applyRules(networkRules: ["Office": .alwaysConnect])
            defer { resetRules() }

            let rules = NetworkManagementRules(isMacCatalyst: true)

            #expect(rules.rules() == [.init(type: .protectedWiFi, ssid: nil, rule: .alwaysConnect)])
            #expect(!rules.canAddNetworks)
        }

        @Test func availableNetworksSkipNetworksWithRulesAndAddTheCurrentOne() {
            applyRules(networkRules: ["Home": .alwaysDisconnect], availableNetworks: ["Home", "Cafe"])
            defer { resetRules() }

            #expect(NetworkManagementRules(currentWiFiNetwork: { "Office" }).availableNetworks() == ["Cafe", "Office"])
        }

        @Test func currentNetworkIsNotOfferedTwiceOrWhenItHasARule() {
            applyRules(networkRules: ["Home": .alwaysDisconnect], availableNetworks: ["Cafe"])
            defer { resetRules() }

            #expect(NetworkManagementRules(currentWiFiNetwork: { "Cafe" }).availableNetworks() == ["Cafe"])
            #expect(NetworkManagementRules(currentWiFiNetwork: { "Home" }).availableNetworks() == ["Cafe"])
            #expect(NetworkManagementRules(currentWiFiNetwork: { nil }).availableNetworks() == ["Cafe"])
        }

        @Test func settingAGenericRuleKeepsTheOthers() {
            applyRules()
            defer { resetRules() }

            NetworkManagementRules().setRule(.alwaysDisconnect, for: .cellular)

            #expect(Client.preferences.nmtGenericRules[NMTType.cellular.rawValue] == NMTRules.alwaysDisconnect.rawValue)
            #expect(Client.preferences.nmtGenericRules[NMTType.protectedWiFi.rawValue] == NMTRules.alwaysConnect.rawValue)
            #expect(Client.preferences.nmtGenericRules[NMTType.openWiFi.rawValue] == NMTRules.alwaysDisconnect.rawValue)
        }

        @Test func trustedNetworkIsNotAGenericRule() {
            applyRules()
            defer { resetRules() }

            NetworkManagementRules().setRule(.alwaysConnect, for: .trustedNetwork)

            #expect(Client.preferences.nmtGenericRules[NMTType.trustedNetwork.rawValue] == nil)
        }

        @Test func networkRulesAreAddedChangedAndRemoved() {
            applyRules()
            defer { resetRules() }
            let rules = NetworkManagementRules()

            rules.setRule(.alwaysConnect, forNetwork: "Home")
            #expect(Client.preferences.nmtTrustedNetworkRules == ["Home": NMTRules.alwaysConnect.rawValue])

            rules.setRule(.retainState, forNetwork: "Home")
            #expect(Client.preferences.nmtTrustedNetworkRules == ["Home": NMTRules.retainState.rawValue])

            rules.removeNetwork("Home")
            #expect(Client.preferences.nmtTrustedNetworkRules.isEmpty)
        }

        private func applyRules(networkRules: [String: NMTRules] = [:], availableNetworks: [String] = []) {
            let preferences = Client.preferences.editable()
            preferences.nmtGenericRules = [
                NMTType.cellular.rawValue: NMTRules.retainState.rawValue,
                NMTType.protectedWiFi.rawValue: NMTRules.alwaysConnect.rawValue,
                NMTType.openWiFi.rawValue: NMTRules.alwaysDisconnect.rawValue
            ]
            preferences.nmtTrustedNetworkRules = networkRules.mapValues(\.rawValue)
            preferences.availableNetworks = availableNetworks
            preferences.commit()
        }

        private func resetRules() {
            let preferences = Client.preferences.editable()
            preferences.nmtGenericRules = originalGenericRules
            preferences.nmtTrustedNetworkRules = originalTrustedNetworkRules
            preferences.availableNetworks = originalAvailableNetworks
            preferences.commit()
        }
    }
}
